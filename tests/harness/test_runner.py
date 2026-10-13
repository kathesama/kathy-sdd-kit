import sys
import tempfile
import time
import unittest
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[2] / 'tools'))
from sdd_harness.runner import execute


class RunnerTests(unittest.TestCase):
    def test_descendant_cannot_write_after_timeout_or_parent_exit(self):
        for parent_sleep in (0, 5):
            with self.subTest(parent_sleep=parent_sleep), tempfile.TemporaryDirectory() as tmp:
                root = Path(tmp)
                (root / 'child.py').write_text('import time\nfrom pathlib import Path\ntime.sleep(0.8)\nPath("late.txt").write_text("escaped")\n')
                (root / 'parent.py').write_text('import subprocess,sys,time\nsubprocess.Popen([sys.executable,"child.py"])\nprint("child-started", flush=True)\ntime.sleep('+str(parent_sleep)+')\n')
                result = execute([sys.executable, 'parent.py'], root, timeout=0.3)
                self.assertIn('child-started', result['stdout'])
                time.sleep(1)
                self.assertFalse((root / 'late.txt').exists(), 'Descendant survived cleanup')

    def test_captures_real_exit_and_literal_argument(self):
        result = execute([sys.executable, '-c', 'import sys; print(sys.argv[1]); sys.exit(3)', '$(echo nope); literal'], Path.cwd())
        self.assertEqual(result['exit_code'], 3)
        self.assertEqual(result['outcome'], 'failed')
        self.assertIn('$(echo nope); literal', result['stdout'])

    def test_output_is_bounded_and_secret_redacted(self):
        result = execute([sys.executable, '-c', 'print("token=secret-value"); print("x"*200000)'], Path.cwd())
        self.assertLessEqual(len(result['stdout'].encode()), 65536)
        self.assertNotIn('secret-value', result['stdout'])
        self.assertEqual(result['outcome'], 'passed')

    def test_timeout_is_unknown_not_red(self):
        started = time.monotonic()
        result = execute([sys.executable, '-c', 'import time; time.sleep(20)'], Path.cwd(), timeout=0.2)
        self.assertEqual(result['outcome'], 'unknown')
        self.assertLess(time.monotonic() - started, 5)
        self.assertIn('timeout', result['stderr'])

    def test_rejects_shell_string_and_invalid_timeout(self):
        for argv, timeout in [('echo hello', 1), (['sh', '-c', 'echo hello'], 1), (['echo'], True), ([], 1)]:
            with self.subTest(argv=argv), self.assertRaises(ValueError):
                execute(argv, Path.cwd(), timeout=timeout)
