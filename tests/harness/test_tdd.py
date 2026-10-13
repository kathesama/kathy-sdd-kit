"""Behavior-specific RED and stable tests are necessary for test-first evidence."""
import copy
import hashlib
import unittest
from test_evidence import record
from sdd_harness.evidence import qualify_pair


def pair():
    red = record()
    red['output_digest'] = hashlib.sha256(red['output'].encode()).hexdigest()
    green = copy.deepcopy(red)
    green.update(phase='green', operation='op-2', started=3.0, finished=4.0,
                 exit_code=0, outcome='passed', source_digest='d'*64,
                 output='test_behavior OK')
    green['output_digest'] = hashlib.sha256(green['output'].encode()).hexdigest()
    return red, green


class TDDTests(unittest.TestCase):
    def test_valid_behavior_pair(self):
        self.assertTrue(qualify_pair(*pair()))

    def test_green_only_is_not_tdd(self):
        red, green = pair()
        red.update(exit_code=0, outcome='passed')
        with self.assertRaises(ValueError):
            qualify_pair(red, green)

    def test_test_change_requires_new_red(self):
        red, green = pair()
        green['test_digest'] = 'e'*64
        with self.assertRaises(ValueError):
            qualify_pair(red, green)

    def test_unrelated_failure_is_not_red(self):
        red, green = pair()
        red['output'] = 'ImportError: missing dependency'
        red['output_digest'] = hashlib.sha256(red['output'].encode()).hexdigest()
        with self.assertRaises(ValueError):
            qualify_pair(red, green)

    def test_retrospective_and_cross_member_pairs_rejected(self):
        for field, value in [('retrospective', True), ('member', 'OTHER-1'),
                             ('started', 0.5), ('kind', 'manual'), ('plan_digest', 'f'*64)]:
            red, green = pair()
            green[field] = value
            with self.subTest(field=field), self.assertRaises(ValueError):
                qualify_pair(red, green)
