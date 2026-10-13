"""Pure, bounded state transitions. The controller owns persistence."""
import copy
import uuid
from .evidence import digest, exact, identifier, number, qualify_pair, qualify_red, validate_record, validate_command


class BudgetError(ValueError):
    """No further mutation is authorized within the approved limits."""


def validate_plan(plan: dict) -> None:
    exact(plan, {'schema', 'anchor', 'specs', 'tasks', 'budgets'})
    if type(plan['schema']) is not int or plan['schema'] != 1:
        raise ValueError('Unsupported plan contract')
    identifier(plan['anchor'])
    exact(plan['budgets'], {'attempts', 'operations', 'seconds'})
    if any(type(v) is not int or v <= 0 for v in plan['budgets'].values()):
        raise ValueError('Budgets must be positive integers, never booleans')
    if not isinstance(plan['tasks'], list) or not plan['tasks'] or not isinstance(plan['specs'], list):
        raise ValueError('Expected task and spec lists')
    seen = set()
    for task in plan['tasks']:
        exact(task, {'id', 'member', 'ac', 'mode', 'check', 'argv', 'cwd', 'tests', 'sources', 'identity', 'failure', 'timeout'})
        for key in ('id', 'member', 'ac', 'check'):
            identifier(task[key])
        if task['id'] in seen:
            raise ValueError('Duplicate task identity')
        seen.add(task['id'])
        if task['mode'] not in ('test-first', 'characterization', 'non-executable'):
            raise ValueError('Invalid task applicability')
        validate_command(task['argv'])
        number(task['timeout'], positive=True)
        if task['timeout'] > plan['budgets']['seconds']:
            raise ValueError('Check timeout exceeds run budget')
        if not isinstance(task['identity'], str) or not task['identity'] or not isinstance(task['failure'], str):
            raise ValueError('Missing test/review identity')
        if task['mode'] == 'test-first' and not task['failure']:
            raise ValueError('Missing expected failure')
        for field in ('tests', 'sources'):
            value = task[field]
            if not isinstance(value, list) or not value or not all(isinstance(p, str) and p for p in value) or len(set(value)) != len(value):
                raise ValueError('Missing or duplicate test/source file identities')


def initialize(plan: dict, approval: dict, now: float) -> dict:
    validate_plan(plan)
    number(now)
    exact(approval, {'schema', 'decision', 'role', 'source', 'plan_digest'})
    if type(approval['schema']) is not int or approval['schema'] != 1 or approval['decision'] != 'approve' or approval['role'] != 'human':
        raise ValueError('Explicit human approve required')
    if not isinstance(approval['source'], str) or not approval['source'].strip() or approval['plan_digest'] != digest(plan):
        raise ValueError('Missing decision source or changed approved plan')
    return dict(schema=1, run=uuid.uuid4().hex, plan_digest=digest(plan), status='active',
                started=now, last_time=now, revision=0, used=0, pending=None,
                tasks={t['id']: {'stage': 'pending', 'attempts': 0, 'records': []} for t in plan['tasks']})


def guard(state: dict, plan: dict, now: float) -> None:
    validate_plan(plan)
    exact(state, {'schema', 'run', 'plan_digest', 'status', 'started', 'last_time', 'revision', 'used', 'pending', 'tasks'})
    if state['schema'] != 1 or state['plan_digest'] != digest(plan) or set(state['tasks']) != {t['id'] for t in plan['tasks']}:
        raise ValueError('Changed plan or corrupt state')
    identifier(state['run'])
    number(now)
    number(state['started'])
    number(state['last_time'])
    if now < state['last_time'] or state['last_time'] < state['started']:
        raise ValueError('Clock regression; recovery required')
    for key in ('used', 'revision'):
        if type(state[key]) is not int or state[key] < 0:
            raise ValueError('Corrupt state counters')
    if state['status'] not in ('active', 'blocked', 'interrupted', 'exhausted', 'complete'):
        raise ValueError('Corrupt run status')
    for item in state['tasks'].values():
        exact(item, {'stage', 'attempts', 'records'})
        if item['stage'] not in ('pending', 'red-observed', 'implementing', 'green-observed', 'verified') or type(item['attempts']) is not int or item['attempts'] < 0 or not isinstance(item['records'], list):
            raise ValueError('Corrupt task state')
    if now - state['started'] >= plan['budgets']['seconds'] or state['used'] >= plan['budgets']['operations'] or state['status'] == 'exhausted':
        raise BudgetError('Approved run budget exhausted')


def active_task(state: dict, plan: dict) -> dict | None:
    return next((t for t in plan['tasks'] if state['tasks'][t['id']]['stage'] != 'verified'), None)


def begin(state: dict, plan: dict, phase: str, task: str, now: float) -> dict:
    guard(state, plan, now)
    if state['pending'] is not None or state['status'] != 'active':
        raise ValueError('Explicit recovery required before another operation')
    current = active_task(state, plan)
    if current is None or current['id'] != task:
        raise ValueError('Only the active member/task may advance')
    item = state['tasks'][task]
    if item['attempts'] >= plan['budgets']['attempts']:
        raise BudgetError('Approved task attempt budget exhausted')
    allowed = {'red': ('pending', 'red-observed', 'green-observed'), 'green': ('red-observed',), 'verify': ('green-observed',)}
    if current['mode'] == 'non-executable':
        allowed = {'verify': ('pending',)}
    if phase not in allowed or item['stage'] not in allowed[phase]:
        raise ValueError('Invalid transition: RED precedes implementation and GREEN')
    updated = copy.deepcopy(state)
    updated['pending'] = {'operation': uuid.uuid4().hex, 'task': task, 'phase': phase,
                          'previous': item['stage'], 'started': now}
    if phase == 'green':
        updated['tasks'][task]['stage'] = 'implementing'
    updated['tasks'][task]['attempts'] += 1
    updated['used'] += 1
    updated['revision'] += 1
    updated['last_time'] = now
    return updated


def finish(state: dict, plan: dict, record: dict) -> dict:
    validate_record(record)
    pending = state['pending']
    if not pending:
        raise ValueError('No pending operation')
    task = next(t for t in plan['tasks'] if t['id'] == pending['task'])
    expected = dict(run=state['run'], operation=pending['operation'], task=task['id'], member=task['member'],
                    ac=task['ac'], check=task['check'], phase=pending['phase'], plan_digest=state['plan_digest'])
    if any(record[key] != value for key, value in expected.items()) or record['started'] < pending['started']:
        raise ValueError('Evidence identity does not match pending operation')
    if record['argv'] != task['argv'] or record['cwd'] != task['cwd'] or record['test_identity'] != task['identity'] or record['expected_failure'] != task['failure']:
        raise ValueError('Evidence check differs from approved check')
    updated = copy.deepcopy(state)
    item = updated['tasks'][task['id']]
    phase = pending['phase']
    try:
        if task['mode'] == 'non-executable':
            if record['kind'] != 'manual' or record['outcome'] != 'passed':
                raise ValueError('Named manual review required')
        elif phase == 'red' and task['mode'] == 'test-first':
            qualify_red(record)
        else:
            if record['kind'] != 'machine' or record['outcome'] != 'passed' or record['retrospective']:
                raise ValueError('Passing original runner observation required')
            prior_phase = 'red' if phase == 'green' else 'green'
            prior = next((r for r in reversed(item['records']) if r['phase'] == prior_phase and
                          r['outcome'] == ('failed' if prior_phase == 'red' and task['mode'] == 'test-first' else 'passed')), None)
            if phase == 'green' and task['mode'] == 'test-first':
                qualify_pair(prior, record)
            elif prior and (record['test_digest'] != prior['test_digest'] or record['started'] < prior['finished']):
                raise ValueError('Changed characterization test or chronology')
        item['stage'] = {'red': 'red-observed', 'green': 'green-observed', 'verify': 'verified'}[phase]
        updated['status'] = 'active'
    except ValueError:
        item['stage'] = pending['previous']
        updated['status'] = 'blocked'
    item['records'].append(record)
    updated['pending'] = None
    updated['revision'] += 1
    updated['last_time'] = record['finished']
    return updated


def close(state: dict, plan: dict, now: float) -> dict:
    guard(state, plan, now)
    if state['pending'] or state['status'] != 'active' or active_task(state, plan):
        raise ValueError('Uncovered required work prevents closure')
    updated = copy.deepcopy(state)
    updated.update(status='complete', used=state['used']+1, revision=state['revision']+1, last_time=now)
    return updated
