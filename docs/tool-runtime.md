# Tool Runtime Guide

The kit tools are POSIX `sh` scripts. They are invoked with `sh` so consuming
repositories do not need Node, TypeScript, or package installation just to run
the SDD gate.

## Supported Runtimes

| Environment | Invocation |
|---|---|
| macOS / Linux | `sh .sdd-kit/tools/<tool>.sh ...` |
| Git Bash on Windows | `sh .sdd-kit/tools/<tool>.sh ...` |
| PowerShell with Git for Windows | `& 'C:\Program Files\Git\bin\sh.exe' .sdd-kit/tools/<tool>.sh ...` |
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
```

When editing the kit repository itself, run from the kit root:

```bash
sh tools/resolve-ticket-workspace.sh {TICKET}
sh tools/validate-impl-spec.sh {TICKET}
sh tools/validate-pr-content.sh {TICKET}
```

## Windows Notes

Do not rely on direct script execution from PowerShell:

```powershell
.\.sdd-kit\tools\validate-impl-spec.sh JAP-160
```

Use Git Bash or call Git's `sh.exe` explicitly:

```powershell
& 'C:\Program Files\Git\bin\sh.exe' .sdd-kit/tools/validate-impl-spec.sh JAP-160
```

If Git is installed in a non-default path, locate `sh.exe` with:

```powershell
where.exe sh
```

or open Git Bash and run the normal `sh .sdd-kit/tools/...` command.
