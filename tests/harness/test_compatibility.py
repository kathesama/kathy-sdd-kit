"""Compatibility checks exercise public shell entrypoints without Git access."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
SH = shutil.which('sh') if os.name != 'nt' else r'C:\Program Files\Git\bin\sh.exe'


class CompatibilityTests(unittest.TestCase):
    def test_engineering_validator_checks_new_skill_identity(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            shutil.copytree(ROOT / 'ai-specs', root / 'ai-specs', ignore=shutil.ignore_patterns('__pycache__'))
            shutil.copytree(ROOT / '.cursor/rules', root / '.cursor/rules')
            (root / 'tools').mkdir()
            for name in ('AGENTS.md', 'CLAUDE.md', 'CODEX.md', 'README.md'):
                shutil.copyfile(ROOT / name, root / name)
            for name in ('validate-engineering-rules.sh', 'sync-codex-skills.sh'):
                shutil.copyfile(ROOT / 'tools' / name, root / 'tools' / name)
            # Exposure linking is validated separately against the real kit.
            (root / 'tools/sync-agent-skills.sh').write_text('#!/bin/sh\n# .agents/skills\nexit 0\n')
            skill = root / 'ai-specs/skills/run-sdd-harness/SKILL.md'
            skill.write_text(skill.read_text().replace('name: run-sdd-harness', 'name: wrong-identity'))
            result = subprocess.run([SH, '-c', 'PATH=/usr/bin:/bin; export PATH; sh tools/validate-engineering-rules.sh'], cwd=root, capture_output=True, text=True, timeout=90)
            self.assertNotEqual(result.returncode, 0, 'New harness skills must be registered for validation')
            self.assertIn('name: run-sdd-harness', result.stdout + result.stderr)

    def test_contract_one_pr_requires_tdd_review_traceability(self):
        parent = ROOT / '.ai-specs/changes'
        parent.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory(dir=parent) as folder:
            source = ROOT / 'examples/pr-content/valid'
            for file in source.glob('*.md'):
                Path(folder, file.name).write_text(file.read_text(encoding='utf-8'), encoding='utf-8')
            spec = Path(folder, 'PRX-200-implementation-spec.md')
            spec.write_text(spec.read_text() + '\nSDD Evidence Contract: 1\n', encoding='utf-8')
            result = subprocess.run([SH, '-c', 'PATH=/usr/bin:/bin; export PATH; sh tools/validate-pr-content.sh "$1"', 'check', Path(folder, 'PR-PRX-200.md').as_posix()], cwd=ROOT, capture_output=True, text=True, timeout=90)
            self.assertNotEqual(result.returncode, 0, 'Contract-1 PR must trace TDD and design review')
            self.assertIn('TDD', result.stdout + result.stderr)
            import re
            ids = sorted(set(re.findall(r'^\| (AC-\d+) \|', spec.read_text(), re.M)))
            table = '\n## TDD and Design Evidence\n| AC | Applicability | Evidence | Design review |\n|---|---|---|---|\n'
            table += '\n'.join(f'| {ac} | test-first | Not Covered: original RED unavailable | SRP reviewed |' for ac in ids)
            for name in ('QA-PRX-200.md', 'REVIEW-PRX-200.md', 'PR-PRX-200.md'):
                file = Path(folder, name)
                file.write_text(file.read_text() + table + '\n', encoding='utf-8')
            result = subprocess.run([SH, '-c', 'PATH=/usr/bin:/bin; export PATH; sh tools/validate-pr-content.sh "$1"', 'check', Path(folder, 'PR-PRX-200.md').as_posix()], cwd=ROOT, capture_output=True, text=True, timeout=90)
            self.assertNotEqual(result.returncode, 0, 'Passing reports cannot hide missing TDD evidence')
            for name in ('QA-PRX-200.md', 'REVIEW-PRX-200.md', 'PR-PRX-200.md'):
                file = Path(folder, name)
                file.write_text(file.read_text().replace('Not Covered: original RED unavailable', 'Observed: synthetic structural fixture RED/GREEN reference'), encoding='utf-8')
            result = subprocess.run([SH, '-c', 'PATH=/usr/bin:/bin; export PATH; sh tools/validate-pr-content.sh "$1"', 'check', Path(folder, 'PR-PRX-200.md').as_posix()], cwd=ROOT, capture_output=True, text=True, timeout=90)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)


    def test_valid_new_contract_and_companion_mismatch(self):
        with tempfile.TemporaryDirectory() as folder:
            source = ROOT / 'examples/backend-ticket/JAP-100'
            import re
            for file in source.glob('*.md'):
                text = file.read_text(encoding='utf-8')
                ids = sorted(set(re.findall(r'^\| (AC-\d+) \|', text, re.M)))
                table = '\n## Execution Contract\nSDD Evidence Contract: 1\n### TDD and Design Contract\n| AC | Applicability | Test identity | Expected RED | Design review | Reason |\n|---|---|---|---|---|---|\n'
                table += '\n'.join(f'| {ac} | test-first | test_{ac} | expected assertion | SRP | behavior |' for ac in ids)
                Path(folder, file.name).write_text(text + table + '\n', encoding='utf-8')
            argv = [SH, '-c', 'PATH=/usr/bin:/bin; export PATH; sh tools/validate-impl-spec.sh "$1"', 'check', Path(folder, 'JAP-100-impl-backend.md').as_posix()]
            result = subprocess.run(argv, cwd=ROOT, capture_output=True, text=True, timeout=90)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            companion = Path(folder, 'JAP-100-implementation-spec.md')
            companion.write_text(companion.read_text().replace('expected assertion', 'different assertion'), encoding='utf-8')
            result = subprocess.run(argv, cwd=ROOT, capture_output=True, text=True, timeout=90)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn('TDD contract mapping mismatch', result.stdout + result.stderr)

    def test_new_contract_rejects_missing_tdd_mapping(self):
        with tempfile.TemporaryDirectory() as folder:
            source = ROOT / 'examples/backend-ticket/JAP-100'
            for file in source.glob('*.md'):
                Path(folder, file.name).write_text(file.read_text(encoding='utf-8') + '\nSDD Evidence Contract: 1\n', encoding='utf-8')
            result = subprocess.run(
                [SH, '-c', 'PATH=/usr/bin:/bin; export PATH; sh tools/validate-impl-spec.sh "$1"',
                 'check', Path(folder, 'JAP-100-impl-backend.md').as_posix()],
                cwd=ROOT, capture_output=True, text=True, timeout=90)
            self.assertNotEqual(result.returncode, 0, 'Contract 1 must reject absent TDD mapping')
            self.assertIn('TDD', result.stdout + result.stderr)

    def test_explicit_ticket_never_probes_git(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            marker = root / 'git-called'
            shim = root / 'git'
            shim.write_text('#!/bin/sh\nprintf called > "$PROBE_MARKER"\n', encoding='utf-8')
            shim.chmod(0o755)
            env = dict(os.environ, PROBE_MARKER=marker.as_posix(), SHIM=root.as_posix())
            result = subprocess.run(
                [SH, '-c', 'PATH=/usr/bin:/bin; if command -v cygpath >/dev/null; then SHIM=$(cygpath -u "$SHIM"); fi; PATH="$SHIM:$PATH"; export PATH; sh tools/resolve-ticket-workspace.sh TASK-42'],
                cwd=ROOT, env=env, capture_output=True, text=True, timeout=30)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(json.loads(result.stdout)['ticket'], 'TASK-42')
            self.assertFalse(marker.exists(), 'Explicit ticket must not invoke Git')
            self.assertIsNone(json.loads(result.stdout)['branchName'])


if __name__ == '__main__':
    unittest.main()
