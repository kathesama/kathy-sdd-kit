# Adopting SDD Kit In An Existing Repository

This guide is for teams adding `kathy-sdd-kit` to a repository that already has
code, conventions, and delivery habits. The goal is to introduce traceable
spec-driven delivery without replacing the repository's local engineering
judgment.

## Adoption Principles

- Keep the kit mounted at `.sdd-kit/`.
- Keep ticket work artifacts local under `.ai-specs/changes/{TICKET}/`.
- Preserve project-specific rules in root files.
- Use validators for structure and evidence consistency.
- Keep QA and code review as separate quality gates.
- Do not commit local ticket artifacts unless the project explicitly chooses to.

## Recommended Rollout

### 1. Add The Kit

Use a submodule when the project should receive kit updates:

```bash
git submodule add https://github.com/kathesama/kathy-sdd-kit .sdd-kit
```

For experiments, a direct clone is acceptable:

```bash
git clone https://github.com/kathesama/kathy-sdd-kit .sdd-kit
```

### 2. Add Agent Entrypoints

Copy the starter `AGENTS.md` only if the repository does not already have one:

```bash
cp .sdd-kit/AGENTS.md ./AGENTS.md
```

If root `AGENTS.md` already exists, merge the SDD sections manually. Preserve
project-specific rules such as security policy, ticket policy, build commands,
or code ownership constraints.

For Claude Code, do not replace root `CLAUDE.md`. Add the kit include:

```md
## SDD Kit

@.sdd-kit/CLAUDE.md
```

### 3. Decide The Ticket Policy

Define how `{TICKET}` is resolved in this repository.

Examples:

```md
## Project Ticket Policy

For this repository, `{TICKET}` must be the Jira issue key, e.g. `JAP-160`.
If the user says "task 160", resolve it to `JAP-160` before creating artifacts.
```

or:

```md
## Project Ticket Policy

For this repository, `{TICKET}` is the GitHub issue key `GH-{number}`.
```

Keep this policy in root `AGENTS.md`, `CLAUDE.md`, or project docs.

### 4. Prepare Local Workspace

Ticket artifacts are local working evidence:

```text
.ai-specs/changes/{TICKET}/
```

The folder may be created by the agent when the first ticket starts. Teams may
also add `.ai-specs/` to `.gitignore` if they want to keep all ticket artifacts
local.

### 5. Copy Or Keep The PR Template

If the project wants SDD-generated PR content, copy the starter template:

```bash
mkdir -p .github
cp .sdd-kit/.github/pull_request_template.md .github/pull_request_template.md
```

If the repository already has a PR template, keep it and let `write-pr-report`
preserve its structure.

### 6. Run One Pilot Ticket

Pick a small backend or frontend task.

Expected flow:

1. Resolve `{TICKET}`.
2. Read parent and child work items.
3. Generate plan/spec/changelog.
4. Run `validate-impl-spec.sh`.
5. Stop for `approve`, `change`, or `deny`.
6. Implement only after approval.
7. Run QA and code review.
8. Generate PR content.
9. Run `validate-pr-content.sh`.

The pilot should test the workflow, not just the code.

## Operating Model

### What The Kit Owns

- SDD artifact structure.
- Planning and approval gate.
- Related work item mapping.
- Structural AC coverage validation.
- PR content evidence validation.
- Reusable standards, agent behavior discipline, optional engineering rule packs, and skills.

### What The Project Owns

- Architecture decisions.
- Security policy.
- Ticket key policy.
- Build and test commands.
- Code ownership.
- Release process.
- Whether local SDD artifacts are committed.

## Updating The Kit

When updating `.sdd-kit`, first move the consuming repository to the desired
kit revision, then review root entrypoints.

For projects that installed the kit as a submodule:

```bash
git submodule update --remote .sdd-kit
git status --short
git diff --submodule
```

If the project pins the kit to a specific commit instead of the remote branch,
update it explicitly:

```bash
git -C .sdd-kit fetch
git -C .sdd-kit checkout <kit-commit>
git status --short
git diff --submodule
```

Then commit the submodule pointer change in the consuming repository according
to that repository's normal review process. Do not edit files directly inside
`.sdd-kit/` in the consuming repository unless the task is explicitly to test or
debug the kit. Make durable kit changes in the `kathy-sdd-kit` source
repository, then update the submodule pointer here.

For projects that installed the kit as a direct clone instead of a submodule:

```bash
git -C .sdd-kit pull --ff-only
```

After the kit revision is updated, review root entrypoints:

1. Review `.sdd-kit/AGENTS.md` against root `AGENTS.md`.
2. Preserve project-specific override sections.
3. Confirm root `CLAUDE.md` still includes `.sdd-kit/CLAUDE.md` when Claude Code is used.
4. Review `.github/pull_request_template.md` only if the project wants to adopt starter template changes.

Do not blindly overwrite root `AGENTS.md` or root `CLAUDE.md`.

## Common Adoption Risks

| Risk | Mitigation |
|---|---|
| Agents skip subtasks | `Related Work Items` is mandatory and validated |
| Agents start coding before plan approval | Planning gate requires explicit `approve` |
| PR content invents test/CI evidence | `validate-pr-content.sh` checks local evidence |
| Agents overgeneralize or make drive-by changes | `agent-behavior-standards.mdc` requires simple, surgical, verifiable work |
| Architecture or data risks are missed | `select-engineering-rules` loads task-scoped rule packs |
| Project rules are overwritten | Preserve local override sections in root files |
| SDD artifacts create repo noise | Keep `.ai-specs/changes/` local and summarize in `PR-{TICKET}.md` |

## Done Criteria For Adoption

The kit is adopted when:

- Root `AGENTS.md` activates `.sdd-kit/CODEX.md`.
- Root `CLAUDE.md` includes `.sdd-kit/CLAUDE.md` if Claude Code is used.
- Agent behavior standards and optional engineering rule packs are visible in the planning context.
- The project ticket policy is documented.
- A pilot ticket has passed planning, approval, QA, review, PR content generation, and PR content validation.
- The team agrees whether `.ai-specs/changes/` remains local or is handled by another evidence store.
