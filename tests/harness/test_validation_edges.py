"""Negative input, persistence and recovery cases at public boundaries."""
import copy
import json
from pathlib import Path
import tempfile
import time
import unittest
from unittest.mock import patch
from test_cli import fixture
from test_evidence import record
from test_state import plan, approval
from test_tdd import pair
from sdd_harness.evidence import digest, load_json, within, file_digest, validate_record, qualify_pair, converge
from sdd_harness.state import initialize, begin, guard, finish, close
from sdd_harness.cli import dispatch, read_state, atomic_write, semantic, main


class ValidationEdges(unittest.TestCase):
    def test_check_mutating_declared_source_is_unknown(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            folder, p = fixture(root)
            (root / 'test.py').write_text('from pathlib import Path\nprint("test_behavior")\nPath("app.py").write_text("value = 1\\n")\nassert False, "expected behavior"\n')
            dispatch('init', root, 'TASK-1')
            state = dispatch('red', root, 'TASK-1', 'task-1')
            self.assertEqual(state['status'], 'blocked')
            self.assertEqual(state['tasks']['task-1']['records'][-1]['outcome'], 'unknown')

    def test_changed_pending_output_cannot_be_reconciled(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            folder, p = fixture(root)
            dispatch('init', root, 'TASK-1')
            with patch('sdd_harness.cli.finish', side_effect=RuntimeError('crash before commit')):
                with self.assertRaises(RuntimeError):
                    dispatch('red', root, 'TASK-1', 'task-1')
            next((folder / 'output').iterdir()).write_text('changed')
            with self.assertRaises(ValueError):
                dispatch('resume', root, 'TASK-1')

    def test_valid_checksum_does_not_hide_evidence_disagreement(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            folder, p = fixture(root)
            dispatch('init', root, 'TASK-1')
            dispatch('red', root, 'TASK-1', 'task-1')
            file = next((folder / 'evidence').iterdir())
            saved = read_state(file)
            saved['source_digest'] = 'f'*64
            atomic_write(file, saved)
            with self.assertRaises(ValueError):
                dispatch('green', root, 'TASK-1', 'task-1')

    def test_characterization_and_manual_review(self):
        for mode in ('characterization', 'non-executable'):
            with tempfile.TemporaryDirectory() as tmp:
                root = Path(tmp)
                folder, p = fixture(root)
                p['tasks'][0]['mode'] = mode
                for name in ('plan.md', 'spec.md'):
                    file = root / name
                    file.write_text(file.read_text().replace('test-first', mode))
                p['specs'][0]['semantic_digest'] = digest(semantic((root / 'plan.md').read_text()))
                (root / 'app.py').write_text('value = 1\n')
                if mode == 'non-executable':
                    (root / 'review.json').write_text(json.dumps(dict(kind='manual', observer='reviewer', source='review:AC-01', verdict='passed')))
                    p['tasks'][0]['tests'] = ['review.json']
                (folder / 'approved-plan.json').write_text(json.dumps(p))
                (folder / 'approval.json').write_text(json.dumps(approval(p)))
                dispatch('init', root, 'TASK-1')
                if mode == 'characterization':
                    dispatch('red', root, 'TASK-1', 'task-1')
                    (root / 'app.py').write_text('value = int("1")\n')
                    dispatch('green', root, 'TASK-1', 'task-1')
                self.assertEqual(dispatch('verify', root, 'TASK-1', 'task-1')['status'], 'active')
                dispatch('close', root, 'TASK-1')
                with self.assertRaises(ValueError):
                    dispatch('resume', root, 'TASK-1')

    def test_canonical_mapping_rejections(self):
        replacements = [('SDD Evidence Contract: 1', ''),
                        ('## Related Work Items', '## Omitted'),
                        ('### TDD and Design Contract', '### Omitted'),
                        ('| SRP | behavior |', '| SRP | |'),
                        ('| AC-01 | test-first', '| AC-02 | test-first'),
                        ('| test_behavior |', '| different_test |')]
        for old, new in replacements:
            with self.subTest(old=old), tempfile.TemporaryDirectory() as tmp:
                root = Path(tmp)
                folder, p = fixture(root)
                for name in ('plan.md', 'spec.md'):
                    file = root / name
                    file.write_text(file.read_text().replace(old, new))
                p['specs'][0]['semantic_digest'] = digest(semantic((root / 'plan.md').read_text()))
                (folder / 'approved-plan.json').write_text(json.dumps(p))
                (folder / 'approval.json').write_text(json.dumps(approval(p)))
                with self.assertRaises(ValueError):
                    dispatch('init', root, 'TASK-1')

    def test_empty_duplicate_specs_and_wrong_anchor(self):
        for mutation in ('empty', 'duplicate', 'anchor'):
            with tempfile.TemporaryDirectory() as tmp:
                root = Path(tmp)
                folder, p = fixture(root)
                if mutation == 'empty':
                    p['specs'] = []
                elif mutation == 'duplicate':
                    p['specs'].append(copy.deepcopy(p['specs'][0]))
                else:
                    p['anchor'] = 'OTHER-1'
                (folder / 'approved-plan.json').write_text(json.dumps(p))
                (folder / 'approval.json').write_text(json.dumps(approval(p)))
                with self.assertRaises(ValueError):
                    dispatch('init', root, 'TASK-1')

    def test_completion_rows_do_not_change_approval(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            folder, p = fixture(root)
            dispatch('init', root, 'TASK-1')
            for name in ('plan.md', 'spec.md'):
                file = root / name
                file.write_text(file.read_text().replace('Not Covered', 'Partial'))
            self.assertEqual(dispatch('status', root, 'TASK-1')['status'], 'active')

    def test_record_field_matrix(self):
        cases = {'schema': [True, 2], 'ac': ['', '../AC'], 'test_digest': ['wrong'],
                 'phase': ['implement'], 'outcome': ['success'], 'retrospective': ['false'],
                 'observer': [1, 'agent'], 'argv': ['python', [], ['']],
                 'finished': [0.0], 'duration': [5], 'exit_code': [True, 0, None]}
        for key, values in cases.items():
            for value in values:
                item = record()
                item[key] = value
                with self.subTest(key=key, value=value), self.assertRaises(ValueError):
                    validate_record(item)
        for kind in ('manual', 'inference', 'assertion'):
            item = record()
            item.update(kind=kind, observer='named-reviewer')
            self.assertEqual(validate_record(item)['kind'], kind)

    def test_json_and_path_edges(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            path = root / 'x.json'
            for value in ('{"a": 1, "a": 2}', '{"a": NaN}'):
                path.write_text(value)
                with self.assertRaises(ValueError):
                    load_json(path)
            for value in ('../outside', 'C:/outside', 'a\\b', ''):
                with self.assertRaises(ValueError):
                    within(root, value)
            for files in ([], ['x.json', 'x.json']):
                with self.assertRaises(ValueError):
                    file_digest(root, files)

    def test_plan_and_state_input_matrix(self):
        mutations = [('schema', 2), ('tasks', []), ('specs', None)]
        for key, value in mutations:
            p = plan()
            p[key] = value
            with self.assertRaises(ValueError):
                initialize(p, approval(p), 1)
        for key, value in [('mode', 'guess'), ('timeout', 1900), ('identity', ''), ('failure', ''), ('tests', []), ('id', '../bad')]:
            p = plan()
            p['tasks'][0][key] = value
            with self.subTest(key=key), self.assertRaises(ValueError):
                initialize(p, approval(p), 1)
        p = plan()
        p['tasks'].append(copy.deepcopy(p['tasks'][0]))
        with self.assertRaises(ValueError):
            initialize(p, approval(p), 1)
        p = plan()
        state = initialize(p, approval(p), 100)
        for key, value in [('schema', 2), ('used', -1), ('status', 'waived'), ('last_time', 102), ('plan_digest', 'x')]:
            changed = copy.deepcopy(state)
            changed[key] = value
            with self.subTest(key=key), self.assertRaises(ValueError):
                guard(changed, p, 101)
        changed = copy.deepcopy(state)
        changed['tasks']['task-1']['stage'] = 'waived'
        with self.assertRaises(ValueError):
            guard(changed, p, 101)

    def test_blocked_pending_and_task_budget(self):
        p = plan()
        state = initialize(p, approval(p), 100)
        state['status'] = 'blocked'
        with self.assertRaises(ValueError):
            begin(state, p, 'red', 'task-1', 101)
        state['status'] = 'active'
        state['tasks']['task-1']['attempts'] = 3
        with self.assertRaises(ValueError):
            begin(state, p, 'red', 'task-1', 101)
        with self.assertRaises(ValueError):
            finish(state, p, record())

    def test_pair_wrong_phase_unknown_and_same_operation(self):
        for key, value in [('phase', 'verify'), ('outcome', 'unknown'), ('operation', 'op-1')]:
            red, green = pair()
            green[key] = value
            with self.subTest(key=key), self.assertRaises(ValueError):
                qualify_pair(red, green)
        red, green = pair()
        red['expected_failure'] = ''
        with self.assertRaises(ValueError):
            qualify_pair(red, green)
        with self.assertRaises(ValueError):
            converge([('TASK-1', 'AC-01')], [dict(member='TASK-1', ac='AC-01', location='', status='covered', evidence='claim')])

    def test_resume_abandoned_operation_keeps_attempt(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            folder, p = fixture(root)
            dispatch('init', root, 'TASK-1')
            with patch('sdd_harness.cli.execute', side_effect=OSError('interrupted launch')):
                with self.assertRaises(OSError):
                    dispatch('red', root, 'TASK-1', 'task-1')
            with self.assertRaises(ValueError):
                dispatch('red', root, 'TASK-1', 'task-1')
            with self.assertRaises(ValueError):
                dispatch('resume', root, 'TASK-1')
            state = dispatch('resume', root, 'TASK-1', reason='Inspected side effects; no replay')
            self.assertEqual(state['tasks']['task-1']['attempts'], 1)
            self.assertIsNone(state['pending'])
            self.assertEqual(state['used'], 2)

    def test_resume_reconciles_captured_operation_without_replay(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            folder, p = fixture(root)
            dispatch('init', root, 'TASK-1')
            with patch('sdd_harness.cli.finish', side_effect=RuntimeError('crash before commit')):
                with self.assertRaises(RuntimeError):
                    dispatch('red', root, 'TASK-1', 'task-1')
            with patch('sdd_harness.cli.execute', side_effect=AssertionError('must not replay')):
                state = dispatch('resume', root, 'TASK-1')
            self.assertEqual(state['tasks']['task-1']['stage'], 'red-observed')
            self.assertEqual(state['tasks']['task-1']['attempts'], 1)

    def test_budget_exhaustion_persists_and_status_stays_readonly(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            folder, p = fixture(root)
            state = dispatch('init', root, 'TASK-1')
            state['used'] = 30
            atomic_write(folder / 'state.json', state)
            for operation in ('red', 'green', 'verify', 'resume', 'close'):
                with self.subTest(operation=operation), self.assertRaises(ValueError):
                    dispatch(operation, root, 'TASK-1', 'task-1')
            before = (folder / 'state.json').read_bytes()
            self.assertEqual(dispatch('status', root, 'TASK-1')['status'], 'exhausted')
            self.assertEqual(before, (folder / 'state.json').read_bytes())

    def test_evidence_and_output_tampering_block_mutation(self):
        for target in ('evidence', 'output'):
            with tempfile.TemporaryDirectory() as tmp:
                root = Path(tmp)
                folder, p = fixture(root)
                dispatch('init', root, 'TASK-1')
                dispatch('red', root, 'TASK-1', 'task-1')
                next((folder / target).iterdir()).write_text('tampered')
                with self.assertRaises(ValueError):
                    dispatch('green', root, 'TASK-1', 'task-1')

    def test_duplicate_init_unknown_operation_and_main_errors(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            folder, p = fixture(root)
            dispatch('init', root, 'TASK-1')
            with self.assertRaises(ValueError):
                dispatch('init', root, 'TASK-1')
            with self.assertRaises(ValueError):
                dispatch('waive', root, 'TASK-1')
            with patch('sys.argv', ['sdd-harness', 'status', 'TASK-1', '--root', str(root)]), patch('builtins.print'):
                self.assertEqual(main(), 0)
            with patch('sys.argv', ['sdd-harness', 'close', 'TASK-1', '--root', str(root)]), patch('builtins.print'):
                self.assertEqual(main(), 1)
