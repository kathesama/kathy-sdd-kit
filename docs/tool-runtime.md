# Tool Runtime Guide

The kit tools are POSIX `sh` scripts. They are invoked with `sh` so consuming
repositories do not need Node, TypeScript, or package installation just to run
the SDD gate.

## Supported Runtimes

| Environment | Invocation |
|---|---|
| macOS / Linux | `sh .sdd-kit/tools/<tool>.sh ...` |
| Git Bash on Windows | `sh .sdd-kit/tools/<tool>.sh ...` |
| PowerShell with Git for Windows | Prefer `& 'C:\Program Files\Git\bin\sh.exe' .sdd-kit/tools/<tool>.sh ...` when stdout/stderr must be captured |
| WSL | `sh .sdd-kit/tools/<tool>.sh ...` from the WSL-mounted repository path |

## Required Tools

- Git, because the kit is normally installed as a submodule or clone.
- A POSIX-compatible `sh`.
- Standard POSIX utilities used by the scripts: `awk`, `sed`, `grep`, `sort`,
  `uniq`, `mktemp`, `wc`, `basename`, `dirname`.

Git for Windows provides the required shell and utilities through Git Bash.

## Common Commands

```bash
sh .sdd-kit/tools/resolve-ticket-workspace.sh {TICKET}
sh .sdd-kit/tools/validate-impl-spec.sh {TICKET}
sh .sdd-kit/tools/validate-pr-content.sh {TICKET}
sh .sdd-kit/tools/validate-engineering-rules.sh
```

When editing the kit repository itself, run from the kit root:

```bash
sh tools/resolve-ticket-workspace.sh {TICKET}
sh tools/validate-impl-spec.sh {TICKET}
sh tools/validate-pr-content.sh {TICKET}
sh tools/validate-engineering-rules.sh
```

## Windows Notes

PowerShell may be able to execute `.sh` scripts directly when the file
association is configured:

```powershell
.\.sdd-kit\tools\validate-impl-spec.sh JAP-160
```

This can be convenient for local use, and the process exit code may still be
valid. However, stdout/stderr can be routed through the associated application
instead of the current PowerShell pipeline, which makes tool output hard to
capture in agents, CI, or wrapper scripts.

When output must be captured reliably, use Git Bash or call Git's `sh.exe`
explicitly:

```powershell
& 'C:\Program Files\Git\bin\sh.exe' .sdd-kit/tools/validate-impl-spec.sh JAP-160
```

If Git is installed in a non-default path, locate `sh.exe` with:

```powershell
where.exe sh
```

or open Git Bash and run the normal `sh .sdd-kit/tools/...` command.

### CRLF Troubleshooting

The kit keeps shell scripts with LF line endings. If a consuming repository or
Windows checkout converts `.sh` files to CRLF, explicit Bash execution can fail
with errors such as:

```text
/usr/bin/env: 'sh\r': No such file or directory
set: -\r: invalid option
```

Normalize line endings in the checkout, or use an in-memory fallback when you
need to inspect output without editing files:

```powershell
bash.exe -lc "cd /mnt/d/projects/example && tr -d '\r' < .sdd-kit/tools/validate-impl-spec.sh | bash -s JAP-160"
```

Use the correct WSL path for the repository. This fallback is diagnostic only;
the preferred fix is keeping `.sh` files checked out with LF.
