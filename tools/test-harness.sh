#!/usr/bin/env sh
set -eu

script_dir=$(CDPATH= cd "$(dirname "$0")" && pwd)
cd "$script_dir/.."
python_bin=${PYTHON:-python}
output_dir=${SDD_TEST_OUTPUT_DIR:-.ai-specs/harness-checks}
mkdir -p "$output_dir"
export COVERAGE_FILE="$output_dir/.coverage"
export PYTHONDONTWRITEBYTECODE=1
"$python_bin" -m coverage run --branch --source=tools/sdd_harness -m unittest discover -s tests/harness -v
"$python_bin" -m coverage report -m
"$python_bin" -m coverage json -o "$output_dir/coverage.json"
"$python_bin" -c 'import json,sys; t=json.load(open(sys.argv[1]))["totals"]; line=t["covered_lines"]/t["num_statements"]; branch=t["covered_branches"]/t["num_branches"]; print("Line: %.2f%%; branch: %.2f%%" % (100*line,100*branch)); sys.exit(0 if min(line,branch)>=.9 else 1)' "$output_dir/coverage.json"
