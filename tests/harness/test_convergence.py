import unittest
from test_evidence import record
from sdd_harness.evidence import converge


class ConvergenceTests(unittest.TestCase):
    def test_missing_partial_contradicting_unrequested_and_dedup(self):
        required = [('TASK-1', 'AC-01'), ('TASK-1', 'AC-02'), ('TASK-1', 'AC-03')]
        observations = [dict(member='TASK-1', ac='AC-02', location='app.py:1', status='partial', evidence='review: missing branch'),
                        dict(member='TASK-1', ac='AC-03', location='app.py:2', status='contradicting', evidence='test contradicts contract'),
                        dict(member='TASK-1', ac='AC-99', location='extra.py:1', status='covered', evidence='unapproved behavior')]
        findings = converge(required, observations + observations)
        self.assertEqual({f['type'] for f in findings}, {'missing', 'partial', 'contradicting', 'unrequested'})
        self.assertEqual(len(findings), 4)
        self.assertEqual(findings, converge(required, observations))

    def test_no_gap_has_no_findings(self):
        self.assertEqual(converge([('TASK-1', 'AC-01')], [dict(member='TASK-1', ac='AC-01', location='test.py:1', status='covered', evidence='observed verifier result')]), [])
