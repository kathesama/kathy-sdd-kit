"""Pure contract validation; these digests are integrity checks, not signatures."""
import hashlib
import json
import math
import re
from pathlib import Path
from typing import Any

FIELDS = frozenset('schema run member task ac check operation phase kind observer argv cwd '
                   'test_digest source_digest plan_digest started finished duration exit_code '
                   'test_identity expected_failure output output_digest outcome retrospective'.split())


def validate_command(argv: list[str]) -> None:
    if not isinstance(argv, list) or not argv or not all(isinstance(a, str) and a and '\0' not in a for a in argv):
        raise ValueError('Expected nonempty argument vector')
    executable = Path(argv[0]).stem.lower()
    if executable in ('sh', 'bash', 'zsh', 'cmd', 'powershell', 'pwsh') and any(
        arg.lower() in ('-c', '/c', '-command', '-encodedcommand', '-ec') for arg in argv[1:]):
        raise ValueError('Inline shell code is not an approved script argument')


def digest(value: Any) -> str:
    data = value if isinstance(value, bytes) else json.dumps(
        value, sort_keys=True, separators=(',', ':'), allow_nan=False).encode()
    return hashlib.sha256(data).hexdigest()


def exact(value: dict, fields: set | frozenset) -> None:
    if not isinstance(value, dict) or set(value) != fields:
        raise ValueError('Unknown or missing contract fields')


def number(value: Any, *, positive: bool = False) -> None:
    if type(value) not in (int, float) or not math.isfinite(value) or value < 0 or (positive and value == 0):
        raise ValueError('Expected finite nonnegative number')


def identifier(value: Any) -> None:
    if not isinstance(value, str) or not re.fullmatch(r'[A-Za-z0-9][A-Za-z0-9_-]{0,79}', value):
        raise ValueError('Invalid identity')


def load_json(path: Path) -> dict:
    def pairs(items):
        result = {}
        for key, value in items:
            if key in result:
                raise ValueError('Duplicate JSON key')
            result[key] = value
        return result
    def invalid(value):
        raise ValueError('Nonfinite JSON number')
    return json.loads(path.read_text(encoding='utf-8'), object_pairs_hook=pairs, parse_constant=invalid)


def within(root: Path, relative: str) -> Path:
    if not isinstance(relative, str) or not relative or '\\' in relative:
        raise ValueError('Expected portable relative path')
    path = Path(relative)
    if path.is_absolute() or '..' in path.parts or ':' in relative:
        raise ValueError('Path traversal or absolute path')
    resolved = (root / path).resolve()
    if not resolved.is_relative_to(root.resolve()):
        raise ValueError('Path escapes approved root')
    return resolved


def file_digest(root: Path, files: list[str]) -> str:
    if not isinstance(files, list) or not files or len(set(files)) != len(files):
        raise ValueError('Expected unique explicit file paths')
    return digest({name: digest(within(root, name).read_bytes()) for name in sorted(files)})


def validate_record(record: dict) -> dict:
    exact(record, FIELDS)
    if type(record['schema']) is not int or record['schema'] != 1:
        raise ValueError('Unsupported evidence version')
    for key in ('run', 'member', 'task', 'ac', 'check', 'operation'):
        identifier(record[key])
    for key in ('test_digest', 'source_digest', 'plan_digest', 'output_digest'):
        if not isinstance(record[key], str) or not re.fullmatch('[a-f0-9]{64}', record[key]):
            raise ValueError('Invalid digest')
    if record['kind'] not in ('machine', 'manual', 'inference', 'assertion'):
        raise ValueError('Unknown evidence kind')
    if record['phase'] not in ('red', 'green', 'verify') or record['outcome'] not in ('passed', 'failed', 'unknown'):
        raise ValueError('Invalid phase or outcome')
    if type(record['retrospective']) is not bool:
        raise ValueError('Invalid retrospective flag')
    for key in ('observer', 'cwd', 'test_identity', 'expected_failure', 'output'):
        if not isinstance(record[key], str):
            raise ValueError('Expected string field')
    if not isinstance(record['argv'], list) or not all(isinstance(arg, str) and arg and '\0' not in arg for arg in record['argv']):
        raise ValueError('Invalid argv')
    if record['kind'] == 'machine' and (record['observer'] != 'runner' or not record['argv']):
        raise ValueError('Machine evidence must be runner observed')
    for key in ('started', 'finished', 'duration'):
        number(record[key])
    if record['finished'] < record['started'] or abs(record['finished'] - record['started'] - record['duration']) > 0.01:
        raise ValueError('Inconsistent chronology')
    code = record['exit_code']
    if code is not None and type(code) is not int:
        raise ValueError('Invalid exit code')
    if record['outcome'] == 'passed' and code != 0 or record['outcome'] == 'failed' and (code is None or code == 0):
        raise ValueError('Outcome contradicts exit status')
    if digest(record['output'].encode()) != record['output_digest']:
        raise ValueError('Changed output')
    return record


def qualify_red(red: dict) -> None:
    validate_record(red)
    if red['phase'] != 'red' or red['kind'] != 'machine' or red['retrospective'] or red['outcome'] != 'failed':
        raise ValueError('Expected original runner-observed RED')
    if not red['test_identity'] or not red['expected_failure'] or any(
        marker in red['output'] for marker in ('SyntaxError:', 'ImportError:', 'ModuleNotFoundError:', 'command not found')):
        raise ValueError('Unrelated setup failure cannot qualify as RED')
    if red['test_identity'] not in red['output'] or red['expected_failure'] not in red['output']:
        raise ValueError('RED does not match expected test assertion')


def qualify_pair(red: dict, green: dict) -> bool:
    qualify_red(red)
    validate_record(green)
    keys = ('run', 'member', 'task', 'ac', 'check', 'test_digest', 'plan_digest', 'argv', 'cwd', 'test_identity', 'expected_failure')
    if any(red[key] != green[key] for key in keys):
        raise ValueError('TDD identity or test content changed; new RED required')
    if green['phase'] != 'green' or green['kind'] != 'machine' or green['retrospective'] or green['outcome'] != 'passed':
        raise ValueError('Expected original runner-observed GREEN')
    if red['finished'] > green['started'] or red['operation'] == green['operation']:
        raise ValueError('Invalid TDD chronology')
    return True


def converge(required, observations):
    """Normalize source-linked reviewer observations; never infer code semantics."""
    required = set(tuple(pair) for pair in required)
    for member, ac in required:
        identifier(member)
        identifier(ac)
    findings = {}
    observed = set()
    for observation in observations:
        exact(observation, {'member', 'ac', 'location', 'status', 'evidence'})
        pair = (observation['member'], observation['ac'])
        identifier(pair[0])
        identifier(pair[1])
        if observation['status'] not in ('covered', 'missing', 'partial', 'contradicting') or not observation['location'] or not observation['evidence']:
            raise ValueError('Source-linked convergence observation required')
        observed.add(pair)
        gap = observation['status'] if pair in required else 'unrequested'
        if gap != 'covered':
            key = digest([*pair, gap, observation['location']])
            findings[key] = dict(id=key, member=pair[0], ac=pair[1], type=gap,
                                 location=observation['location'], evidence=observation['evidence'])
    for pair in required - observed:
        key = digest([*pair, 'missing', 'approved-plan'])
        findings[key] = dict(id=key, member=pair[0], ac=pair[1], type='missing', location='approved-plan', evidence='No observation supplied')
    return [findings[key] for key in sorted(findings)]
