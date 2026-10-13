"""Filesystem and command-line boundary; all mutation passes the same guards."""
import argparse
from contextlib import contextmanager
import json
import os
from pathlib import Path
import re
import tempfile
import time
from .evidence import digest, exact, file_digest, identifier, load_json, validate_record, within
from .runner import execute
from .state import BudgetError, active_task, begin, close, finish, guard, initialize, validate_plan


@contextmanager
def exclusive(folder):
    lock = folder / 'writer.lock'
    descriptor = os.open(lock, os.O_CREAT | os.O_EXCL | os.O_WRONLY, 0o600)
    try:
        os.write(descriptor, json.dumps({'pid': os.getpid(), 'created': time.time()}).encode())
        os.fsync(descriptor)
        yield
    finally:
        os.close(descriptor)
        lock.unlink()


def atomic_write(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    data = json.dumps({'payload': value, 'digest': digest(value)}, sort_keys=True, indent=2, allow_nan=False)
    descriptor, name = tempfile.mkstemp(dir=path.parent, prefix='.pending-')
    try:
        with os.fdopen(descriptor, 'w', encoding='utf-8', newline='\n') as stream:
            stream.write(data + '\n')
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(name, path)
    finally:
        if os.path.exists(name):
            os.unlink(name)


def read_state(path):
    envelope = load_json(path)
    exact(envelope, {'payload', 'digest'})
    if digest(envelope['payload']) != envelope['digest']:
        raise ValueError('Corrupt persisted payload')
    return envelope['payload']


def semantic(text: str) -> str:
    lines = text.splitlines()
    kept = []
    skip = False
    for line in lines:
        if line.startswith('# '):
            continue
        if line.startswith('## '):
            skip = line == '## Completion Evidence'
        if not skip:
            kept.append(line.rstrip())
    return '\n'.join(kept).strip()


def bind_specs(root: Path, plan: dict) -> None:
    validate_plan(plan)
    if not plan['specs']:
        raise ValueError('Canonical plan/spec references required')
    required = set()
    members = set()
    related_members = set()
    for reference in plan['specs']:
        exact(reference, {'member', 'plan', 'spec', 'semantic_digest'})
        identifier(reference['member'])
        if reference['member'] in members:
            raise ValueError('Duplicate member spec')
        members.add(reference['member'])
        texts = [within(root, reference[key]).read_text(encoding='utf-8') for key in ('plan', 'spec')]
        if any(text.splitlines().count('SDD Evidence Contract: 1') != 1 for text in texts):
            raise ValueError('Contract marker missing or changed; no legacy downgrade')
        projected = [semantic(text) for text in texts]
        if projected[0] != projected[1] or digest(projected[0]) != reference['semantic_digest']:
            raise ValueError('Canonical plan content changed or companions disagree')
        ac_section = re.search(r'^## Acceptance Criteria\n(.*?)(?=^## |\Z)', texts[0], re.M | re.S)
        mapping = re.search(r'^### TDD and Design Contract\n(.*?)(?=^#|\Z)', texts[0], re.M | re.S)
        if not ac_section or not mapping:
            raise ValueError('Missing AC or TDD mapping')
        related = re.search(r'^## Related Work Items\n(.*?)(?=^## |\Z)', texts[0], re.M | re.S)
        if not related:
            raise ValueError('Missing Related Work Items')
        for line in related[1].split('### ')[0].splitlines():
            cells = [cell.strip() for cell in line.split('|')[1:-1]]
            if len(cells) == 5 and cells[3] == 'In scope':
                related_members.add(cells[0])
        # The TDD subsection can be nested inside Acceptance Criteria.
        ids = re.findall(r'^\| (AC-\d+) \|', ac_section[1].split('### ')[0], re.M)
        rows = [line.split('|')[1:-1] for line in mapping[1].splitlines() if re.match(r'^\| AC-\d+ \|', line)]
        mapped = {}
        for row in rows:
            row = [cell.strip() for cell in row]
            if len(row) != 6 or not all(row) or row[0] in mapped:
                raise ValueError('Invalid or duplicate TDD mapping')
            mapped[row[0]] = row
        if not ids or len(ids) != len(set(ids)) or set(ids) != set(mapped):
            raise ValueError('Every AC needs one TDD mapping')
        for ac in ids:
            required.add((reference['member'], ac))
        for task in (t for t in plan['tasks'] if t['member'] == reference['member']):
            row = mapped.get(task['ac'])
            if not row or (task['mode'], task['identity'], task['failure']) != (row[1], row[2], row[3]):
                raise ValueError('Task does not derive from approved TDD mapping')
    if plan['anchor'] not in members or not related_members.issubset(members) or {(t['member'], t['ac']) for t in plan['tasks']} != required:
        raise ValueError('Missing or unrequested member/AC task')
    for task in plan['tasks']:
        within(root, task['cwd'])
        file_digest(root, task['tests'])
        file_digest(root, task['sources'])


def fresh_records(root: Path, folder: Path, state: dict, plan: dict, *, closing=False) -> None:
    for task in plan['tasks']:
        records = state['tasks'][task['id']]['records']
        for record in records:
            validate_record(record)
            saved = read_state(within(folder, 'evidence/' + record['operation'] + '.json'))
            if saved != record:
                raise ValueError('Missing or altered operation evidence')
            output = within(folder, 'output/' + record['operation'] + '.txt').read_bytes()
            if digest(output) != record['output_digest']:
                raise ValueError('Missing or altered output evidence')
        if closing and (not records or records[-1]['source_digest'] != file_digest(root, task['sources']) or records[-1]['test_digest'] != file_digest(root, task['tests'])):
            raise ValueError('Final evidence stale against current source/tests')


def dispatch(command, root, ticket, task=None, reason=None):
    identifier(ticket)
    root = Path(root).resolve()
    folder = within(root, f'.ai-specs/changes/{ticket}/harness')
    plan = load_json(within(folder, 'approved-plan.json'))
    approval = load_json(within(folder, 'approval.json'))
    bind_specs(root, plan)
    if plan['anchor'] != ticket:
        raise ValueError('Wrong anchor')
    initial = initialize(plan, approval, time.time())
    state_path = within(folder, 'state.json')
    if command in ('status', 'next'):
        state = read_state(state_path)
        # Inspection stays available after deadline; validate using the initial
        # timestamp and report stored state, never silently reset counters.
        if state['plan_digest'] != digest(plan):
            raise ValueError('Changed plan')
        return state if command == 'status' else {'task': active_task(state, plan), 'pending': state['pending'], 'status': state['status']}
    with exclusive(folder):
        if command == 'init':
            if state_path.exists() or within(folder, 'evidence').exists() or within(folder, 'output').exists():
                raise ValueError('Run or orphan evidence already exists; inspect recovery, never reset budgets')
            atomic_write(state_path, initial)
            return initial
        state = read_state(state_path)
        fresh_records(root, folder, state, plan)
        try:
            guard(state, plan, time.time())
            if command == 'close':
                fresh_records(root, folder, state, plan, closing=True)
                state = close(state, plan, time.time())
            elif command == 'resume':
                if state['status'] == 'complete':
                    raise ValueError('Completed run cannot resume')
                pending = state['pending']
                if pending:
                    captured = within(folder, 'evidence/' + pending['operation'] + '.json')
                    if captured.exists():
                        record = read_state(captured)
                        output = within(folder, 'output/' + pending['operation'] + '.txt').read_bytes()
                        if digest(output) != record['output_digest']:
                            raise ValueError('Pending output integrity failure')
                        state = finish(state, plan, record)
                    elif reason:
                        state['tasks'][pending['task']]['stage'] = pending['previous']
                        atomic_write(within(folder, 'evidence/' + pending['operation'] + '-interrupted.json'),
                                     {'outcome': 'unknown', 'operation': pending['operation'], 'reason': reason})
                        state['pending'] = None
                        state['status'] = 'active'
                    else:
                        raise ValueError('Unknown pending operation: inspect side effects; supply recovery reason to abandon, never auto replay')
                elif state['status'] == 'blocked':
                    if not reason:
                        raise ValueError('Blocked check requires explicit recovery reason')
                    state['status'] = 'active'
                state['used'] += 1
                state['revision'] += 1
                state['last_time'] = time.time()
            elif command in ('red', 'green', 'verify'):
                state = begin(state, plan, command, task, time.time())
                atomic_write(state_path, state)  # Consume attempt before launch.
                selected = next(t for t in plan['tasks'] if t['id'] == task)
                test_hash = file_digest(root, selected['tests'])
                source_hash = file_digest(root, selected['sources'])
                remaining = plan['budgets']['seconds'] - (time.time()-state['started'])
                result = execute(selected['argv'], within(root, selected['cwd']), min(selected['timeout'], max(0.001, remaining)))
                output = result['stdout'] + '\n' + result['stderr']
                operation = state['pending']['operation']
                record = dict(schema=1, run=state['run'], member=selected['member'], task=task,
                              ac=selected['ac'], check=selected['check'], operation=operation,
                              phase=command, kind='machine', observer='runner', argv=selected['argv'],
                              cwd=selected['cwd'], test_digest=test_hash, source_digest=source_hash,
                              plan_digest=digest(plan), started=result['started'], finished=result['finished'],
                              duration=result['duration'], exit_code=result['exit_code'],
                              test_identity=selected['identity'], expected_failure=selected['failure'],
                              output=output, output_digest=digest(output.encode()), outcome=result['outcome'], retrospective=False)
                if test_hash != file_digest(root, selected['tests']) or source_hash != file_digest(root, selected['sources']):
                    record['outcome'] = 'unknown'
                if selected['mode'] == 'non-executable':
                    review = load_json(within(root, selected['tests'][0]))
                    exact(review, {'kind', 'observer', 'source', 'verdict'})
                    if review['kind'] != 'manual' or not review['observer'] or not review['source'] or review['verdict'] != 'passed':
                        raise ValueError('Named manual review evidence required')
                    record.update(kind='manual', observer=review['observer'])
                output_path = within(folder, 'output/' + operation + '.txt')
                output_path.parent.mkdir(parents=True, exist_ok=True)
                output_path.write_bytes(output.encode())
                atomic_write(within(folder, 'evidence/' + operation + '.json'), record)
                state = finish(state, plan, record)
            else:
                raise ValueError('Unknown operation')
        except BudgetError:
            state['status'] = 'exhausted'
            atomic_write(state_path, state)
            raise
        atomic_write(state_path, state)
        return state


def main() -> int:
    parser = argparse.ArgumentParser(description='Optional cooperative SDD evidence controller')
    parser.add_argument('command', choices=['init', 'status', 'next', 'red', 'green', 'verify', 'resume', 'close'])
    parser.add_argument('ticket')
    parser.add_argument('--root', type=Path, default=Path.cwd())
    parser.add_argument('--task')
    parser.add_argument('--reason', help='Explicit recovery note after inspecting interrupted side effects')
    args = parser.parse_args()
    try:
        result = dispatch(args.command, args.root, args.ticket, args.task, args.reason)
        print(json.dumps(result, indent=2, allow_nan=False))
        return 1 if result.get('status') in ('blocked', 'exhausted', 'interrupted') else 0
    except (ValueError, OSError, RuntimeError) as error:
        print('FAIL: ' + str(error))
        return 1
