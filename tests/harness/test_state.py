import copy
from pathlib import Path
import sys
import unittest
sys.path.insert(0, str(Path(__file__).resolve().parents[2] / 'tools'))
from sdd_harness.evidence import digest
from sdd_harness.state import initialize, begin, close


def plan():
    return {'schema': 1, 'anchor': 'TASK-1', 'specs': [], 'tasks': [
        {'id': 'task-1', 'member': 'TASK-1', 'ac': 'AC-01', 'mode': 'test-first',
         'check': 'check-1', 'argv': ['python', 'test.py'], 'cwd': '.',
         'tests': ['test.py'], 'sources': ['app.py'], 'identity': 'test_behavior',
         'failure': 'AssertionError: expected behavior', 'timeout': 120}],
        'budgets': {'attempts': 3, 'operations': 30, 'seconds': 1800}}


def approval(p):
    return {'schema': 1, 'decision': 'approve', 'role': 'human',
            'source': 'conversation:explicit-user-approve', 'plan_digest': digest(p)}


class StateTests(unittest.TestCase):
    def test_new_red_allowed_after_invalidated_green(self):
        p = plan()
        state = initialize(p, approval(p), 100)
        state['tasks']['task-1']['stage'] = 'red-observed'
        state = begin(state, p, 'red', 'task-1', 101)
        self.assertEqual(state['pending']['phase'], 'red')

    def test_rejects_agent_approval_or_changed_plan(self):
        p = plan()
        for key, value in [('role', 'agent'), ('decision', 'approved'), ('source', ''), ('plan_digest', '0'*64)]:
            a = approval(p)
            a[key] = value
            with self.subTest(key=key), self.assertRaises(ValueError):
                initialize(p, a, 100)

    def test_direct_green_cannot_skip_red(self):
        p = plan()
        state = initialize(p, approval(p), 100)
        with self.assertRaises(ValueError):
            begin(state, p, 'green', 'task-1', 101)

    def test_cannot_close_uncovered_required_work(self):
        p = plan()
        state = initialize(p, approval(p), 100)
        with self.assertRaises(ValueError):
            close(state, p, 101)

    def test_deadline_and_operation_budget_before_work(self):
        p = plan()
        state = initialize(p, approval(p), 100)
        with self.assertRaises(ValueError):
            begin(state, p, 'red', 'task-1', 1901)
        state['used'] = 30
        with self.assertRaises(ValueError):
            begin(state, p, 'red', 'task-1', 101)

    def test_cross_member_and_boolean_limits_rejected(self):
        p = plan()
        state = initialize(p, approval(p), 100)
        with self.assertRaises(ValueError):
            begin(state, p, 'red', 'other-task', 101)
        p['budgets']['attempts'] = True
        with self.assertRaises(ValueError):
            initialize(p, approval(p), 100)
