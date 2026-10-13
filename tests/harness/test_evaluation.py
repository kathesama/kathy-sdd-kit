import importlib.util
from pathlib import Path
import unittest
import sys
import tempfile
import copy
sys.path.insert(0, str(Path(__file__).resolve().parents[2] / 'tools'))
from sdd_harness.evidence import digest

spec = importlib.util.spec_from_file_location('evaluation', Path(__file__).resolve().parents[2] / 'tools/evaluate-sdd-harness.py')
evaluation = importlib.util.module_from_spec(spec)
spec.loader.exec_module(evaluation)


class EvaluationTests(unittest.TestCase):
    def test_independent_trial_receipts_safety_and_regression_gates(self):
        with tempfile.TemporaryDirectory() as tmp:
            rows = []
            for index, identity in enumerate(evaluation.IDS):
                trace = Path(tmp) / f'trace-{index}.json'
                trace.write_text('Synthetic unit fixture only: ' + identity)
                rows.append(dict(id=identity, status='passed', kind='live', first_pass=True,
                                 completed=True, omitted_ac=False, approval_bypass=False, false_covered=False,
                                 tdd_bypass=False, interventions=0, seconds=1, cost=None,
                                 trace=str(trace), trace_digest=digest(trace.read_bytes()), configuration_digest='a'*64))
            self.assertTrue(evaluation.evaluate(rows)['promotion'])
            self.assertEqual(evaluation.evaluate(rows)['metrics']['candidate']['all_trial_consistency'], 1.0)
            self.assertEqual(evaluation.evaluate(rows)['metrics']['candidate']['omitted_ac'], 0)
            costs = copy.deepcopy(rows)
            for row in costs:
                row['cost'] = 1
            costs[-1]['cost'] = 100
            self.assertTrue(evaluation.evaluate(costs)['promotion'], 'Cost tradeoff gate uses the approved median, not total cost')
            for key, value in [('approval_bypass', True), ('false_covered', True), ('tdd_bypass', True), ('completed', False)]:
                changed = copy.deepcopy(rows)
                changed[-1][key] = value
                self.assertFalse(evaluation.evaluate(changed)['promotion'])
            changed = copy.deepcopy(rows)
            for row in changed[30:]:
                row['seconds'] = 2
            self.assertFalse(evaluation.evaluate(changed)['promotion'])
            changed = copy.deepcopy(rows)
            changed[-1]['kind'] = 'static'
            with self.assertRaises(ValueError):
                evaluation.evaluate(changed)
            changed = copy.deepcopy(rows)
            changed[-1]['status'] = 'interrupted'
            with self.assertRaises(ValueError):
                evaluation.evaluate(changed)
            changed = copy.deepcopy(rows)
            changed[-1]['configuration_digest'] = 'b'*64
            with self.assertRaises(ValueError):
                evaluation.evaluate(changed)

    def test_missing_trials_never_promote(self):
        result = evaluation.evaluate([], 'Codex CLI not logged in')
        self.assertFalse(result['promotion'])
        self.assertEqual(len(result['results']), 60)
        self.assertTrue(all(r['status'] == 'unexecuted' for r in result['results']))
        self.assertTrue(all(r['cost'] is None for r in result['results']))
        self.assertIsNone(result['metrics']['candidate']['pass_at_1'])
        self.assertIsNone(result['metrics']['candidate']['all_trial_consistency'])

    def test_unknown_trial_id_rejected(self):
        with self.assertRaises(ValueError):
            evaluation.evaluate([{'id': 'invented'}])
