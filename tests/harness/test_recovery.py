import json
from pathlib import Path
import tempfile
import unittest
import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[2] / 'tools'))
from sdd_harness.cli import exclusive, atomic_write, read_state


class RecoveryTests(unittest.TestCase):
    def test_missing_state_with_existing_evidence_cannot_reset_budget(self):
        from test_cli import fixture
        from sdd_harness.cli import dispatch
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            workspace, p = fixture(root)
            dispatch('init', root, 'TASK-1')
            dispatch('red', root, 'TASK-1', 'task-1')
            (workspace / 'state.json').unlink()
            with self.assertRaises(ValueError):
                dispatch('init', root, 'TASK-1')

    def test_exclusive_writer_never_breaks_existing_lock(self):
        with tempfile.TemporaryDirectory() as folder:
            with exclusive(Path(folder)):
                with self.assertRaises((FileExistsError, ValueError)):
                    with exclusive(Path(folder)):
                        self.fail('Second writer entered')

    def test_atomic_state_roundtrip_and_integrity(self):
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder) / 'state.json'
            state = {'revision': 1, 'pending': {'operation': 'op-1'}}
            atomic_write(path, state)
            self.assertEqual(read_state(path), state)
            path.write_text('{"payload": {}, "digest": "wrong"}', encoding='utf-8')
            with self.assertRaises(ValueError):
                read_state(path)

    def test_corruption_is_not_empty_success_state(self):
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder) / 'state.json'
            path.write_text('broken', encoding='utf-8')
            with self.assertRaises(ValueError):
                read_state(path)
