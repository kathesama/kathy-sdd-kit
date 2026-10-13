"""Public operations must enforce approval, identity and chronology."""
import json
from pathlib import Path
import tempfile
import time
import unittest
from test_state import plan, approval
from sdd_harness.cli import dispatch
from sdd_harness.evidence import digest


def fixture(root):
    folder = root / '.ai-specs/changes/TASK-1/harness'
    folder.mkdir(parents=True)
    text = '''# Fixture
SDD Evidence Contract: 1
## Acceptance Criteria
| ID | Criterion | Validation Type | Source |
|---|---|---|---|
| AC-01 | Returns the expected behavior | automated_test | explicit |
## Related Work Items
| Key | Type | Status | Scope Decision | Plan Impact |
|---|---|---|---|---|
| TASK-1 | Parent | Ready | In scope | AC-01 |
### TDD and Design Contract
| AC | Applicability | Test identity | Expected RED | Design review | Reason |
|---|---|---|---|---|---|
| AC-01 | test-first | test_behavior | AssertionError: expected behavior | SRP | behavior |
## Completion Evidence
| AC-01 | Not Covered | Pending implementation |
'''
    (root / 'plan.md').write_text(text)
    (root / 'spec.md').write_text(text)
    (root / 'app.py').write_text('value = 0\n')
    (root / 'test.py').write_text('from app import value\nprint("test_behavior")\nassert value == 1, "expected behavior"\n')
    p = plan()
    import sys
    p['tasks'][0]['argv'] = [sys.executable, '-B', 'test.py']
    # Frozen semantic digest excludes only the title and Completion Evidence.
    semantic = '\n'.join(text.splitlines()[1:]).split('## Completion Evidence')[0].strip()
    p['specs'] = [{'member': 'TASK-1', 'plan': 'plan.md', 'spec': 'spec.md', 'semantic_digest': digest(semantic)}]
    (folder / 'approved-plan.json').write_text(json.dumps(p))
    (folder / 'approval.json').write_text(json.dumps(approval(p)))
    return folder, p


class CLITests(unittest.TestCase):
    def test_in_scope_child_cannot_disappear_from_projection(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            folder, p = fixture(root)
            for name in ('plan.md', 'spec.md'):
                file = root / name
                file.write_text(file.read_text().replace('### TDD', '| CHILD-1 | Child | Ready | In scope | AC-02 |\n### TDD'))
            from sdd_harness.cli import semantic
            p['specs'][0]['semantic_digest'] = digest(semantic((root / 'plan.md').read_text()))
            (folder / 'approved-plan.json').write_text(json.dumps(p))
            (folder / 'approval.json').write_text(json.dumps(approval(p)))
            with self.assertRaises(ValueError):
                dispatch('init', root, 'TASK-1')

    def test_retry_green_uses_qualifying_red_not_last_failed_result(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            folder, p = fixture(root)
            p['budgets']['attempts'] = 6
            (folder / 'approved-plan.json').write_text(json.dumps(p))
            (folder / 'approval.json').write_text(json.dumps(approval(p)))
            dispatch('init', root, 'TASK-1')
            dispatch('red', root, 'TASK-1', 'task-1')
            self.assertEqual(dispatch('green', root, 'TASK-1', 'task-1')['status'], 'blocked')
            dispatch('resume', root, 'TASK-1', reason='Inspect failed implementation; retry within approved scope')
            (root / 'app.py').write_text('value = 1\n')
            self.assertEqual(dispatch('green', root, 'TASK-1', 'task-1')['status'], 'active')

    def test_lifecycle_and_unchanged_status(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            folder, p = fixture(root)
            state = dispatch('init', root, 'TASK-1')
            self.assertEqual(state.get('status'), 'active')
            before = (folder / 'state.json').read_bytes()
            dispatch('next', root, 'TASK-1')
            self.assertEqual(before, (folder / 'state.json').read_bytes())
            with self.assertRaises(ValueError):
                dispatch('green', root, 'TASK-1', 'task-1')
            dispatch('red', root, 'TASK-1', 'task-1')
            (root / 'app.py').write_text('value = 1\n')
            dispatch('green', root, 'TASK-1', 'task-1')
            dispatch('verify', root, 'TASK-1', 'task-1')
            self.assertEqual(dispatch('close', root, 'TASK-1')['status'], 'complete')

    def test_missing_approval_and_changed_spec_block(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            folder, p = fixture(root)
            (folder / 'approval.json').unlink()
            with self.assertRaises((ValueError, FileNotFoundError)):
                dispatch('init', root, 'TASK-1')
            (folder / 'approval.json').write_text(json.dumps(approval(p)))
            dispatch('init', root, 'TASK-1')
            (root / 'plan.md').write_text('scope changed')
            with self.assertRaises(ValueError):
                dispatch('red', root, 'TASK-1', 'task-1')

    def test_source_change_after_verify_prevents_close(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            fixture(root)
            dispatch('init', root, 'TASK-1')
            dispatch('red', root, 'TASK-1', 'task-1')
            (root / 'app.py').write_text('value = 1\n')
            dispatch('green', root, 'TASK-1', 'task-1')
            dispatch('verify', root, 'TASK-1', 'task-1')
            (root / 'app.py').write_text('value = 2\n')
            with self.assertRaises(ValueError):
                dispatch('close', root, 'TASK-1')
