"""Evidence must fail closed even when a result claims success."""
import copy
import hashlib
from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / 'tools'))
from sdd_harness.evidence import validate_record


def record():
    return dict(schema=1, run='run-1', member='TASK-1', task='task-1', ac='AC-01',
                check='check-1', operation='op-1', phase='red', kind='machine',
                observer='runner', argv=['python', 'test.py'], cwd='.',
                test_digest='a'*64, source_digest='b'*64, plan_digest='c'*64,
                started=1.0, finished=2.0, duration=1.0, exit_code=1,
                test_identity='test_behavior', expected_failure='AssertionError: expected behavior',
                output='test_behavior AssertionError: expected behavior',
                output_digest=hashlib.sha256(b'test_behavior AssertionError: expected behavior').hexdigest(), outcome='failed', retrospective=False)


class EvidenceTests(unittest.TestCase):
    def test_rejects_unknown_field(self):
        item = record()
        item['self_approved'] = True
        with self.assertRaises(ValueError):
            validate_record(item)

    def test_rejects_missing_identity(self):
        item = record()
        del item['ac']
        with self.assertRaises(ValueError):
            validate_record(item)

    def test_rejects_nonfinite_timing(self):
        for value in [float('nan'), float('inf'), True, -1]:
            item = record()
            item['started'] = value
            with self.subTest(value=value), self.assertRaises(ValueError):
                validate_record(item)

    def test_rejects_unknown_kind(self):
        item = record()
        item['kind'] = 'verified-by-agent'
        with self.assertRaises(ValueError):
            validate_record(item)

    def test_rejects_changed_output(self):
        item = record()
        item['output'] = 'altered'
        with self.assertRaises(ValueError):
            validate_record(item)

    def test_valid_record(self):
        self.assertEqual(validate_record(record()), record())
