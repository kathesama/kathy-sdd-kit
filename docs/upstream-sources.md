# Upstream Source Audit

Last audited: 2026-07-04.

Targeted follow-up: 2026-09-09 for `github/spec-kit`,
`kathesama/claude-skills`, and `kathesama/everything-claude-code` only.
Other rows retain their July audit status. See the
[detailed review and harness adoption proposal](research/upstream-review-2026-09-09.md)
and [complete comparison commit inventory](research/upstream-commit-inventory-2026-09-09.json).
The research informed the approved `task-20260909-01` implementation. Mandatory
TDD is an explicit local product decision; it is not a claim that every upstream
enforces the same policy. The new controller is a standard-library implementation
of the approved contract, not imported upstream runtime code. Methodology and
attribution remain pinned to the detailed review and commit inventory above.
See [behavioral evaluation and promotion](harness-evaluation.md); research and
fixture tests do not establish agent performance or release readiness.

This file records which external repositories are treated as sources for
`kathy-sdd-kit`, which are candidate idea sources, and which should not be
imported directly.

## Incorporated Sources

| Repository | Audited revision | Local use | Current action |
|---|---|---|---|
| `LIDR-academy/ai-specs` | `d19d286e9895` | Original portable SDD/specboot structure, agent entrypoints, skills layout. | Keep as conceptual source; no direct sync this pass. |
| `LIDR-academy/manual-SDD` | `4ee81b81a248` | Manual SDD workflow inspiration and original enrich/report flow. | Keep as conceptual source; no direct sync this pass. |
| `github/spec-kit` | `86b7a01420a42` | Spec-driven workflow inspiration, gates, cross-artifact analysis concepts. | Reviewed 644 commits since `bba473c223dc` at metadata level, with focused source inspection. Adapt assess, requirements-quality review, convergence, durable workflow state, and evidence contracts selectively. v1.0.5 is the observed published release; September 9 per-step integration configuration is newer mainline work. |
| `ciembor/agent-rules-books` | `9c8763613514` | Optional engineering rule packs. | Added remaining local mini packs for Clean Code, Code Complete, DDD Distilled, Implementing DDD, and The Pragmatic Programmer. |
| `google-labs-code/design.md` | `ea4a3240d4c0` | Root `DESIGN.md` contract format and CLI validation/export concepts. | Updated design validation guidance for Tailwind v4, CSS custom properties, Tailwind v3, and DTCG export checks. |
| `forrestchang/andrej-karpathy-skills` | `2c606141936f` | Agent behavior and coding-discipline inspiration. | Already represented by agent behavior standards; no direct sync this pass. |
| `DietrichGebert/ponytail` | `40e50d9e0324` | Complexity minimization and debt-marker ideas. | Already represented by complexity review/debt harvest; no direct sync this pass. |
| `obra/superpowers` | `d884ae04edeb` | Skill workflow discipline, TDD, planning, verification, and skill-testing inspiration. | Candidate follow-up: evaluate skill-behavior tests/progress ledger ideas; no direct sync this pass. |
| `thedotmack/claude-mem` | `e02494852c99` | Persistent-memory concept reference. | Keep optional/external; do not embed runtime hooks or services in the kit. |

## Candidate Repositories

| Repository | Audited revision | Useful surface | Decision |
|---|---|---|---|
| `kathesama/everything-claude-code` | `d8409a4b08137` | Eval harness, agent-eval, bounded candidate evaluation, adapter compliance, language/runtime skills. | Reviewed 175 commits since `49128b5763b7` at metadata level, with focused source inspection. Adapt evidence and repeated-run evaluation; keep the alpha control plane external. The inspected `benchmark-methodology` is competitive-positioning guidance, not a coding-agent benchmark. |
| `kathesama/claude-skills` | `aa8d778811a5` | Agent harness manifest/plan/state controller and selective SDD-compatible skills. | Reviewed 91 commits since `1bd5b1a0b51c` at metadata level, with focused source inspection. Adapt bounded execution only after addressing self-attested verification, waiver authority, and direct-command budget enforcement. Defer SkillOpt-Sleep to a separate reviewed experiment. |
| `LIDR-academy/AI4Devs-LTI-extended` | `9ff9a8004eec` | OpenSpec skills, run-parallel-tasks, adversarial review, audit skills, sync-agent-symlinks. | Use as reference for OpenSpec/Jira examples; avoid direct import unless adapting to SDD paths. |
| `Hainrixz/claude-webkit` | `6f80d25d855d` | Frontend/design/web skills and web design guidelines. | Candidate only for frontend visual QA/design review improvements. |
| `nextlevelbuilder/ui-ux-pro-max-skill` | `4baa399d00da` | UI/UX skill, design-system skill, brand/design/slides guidance, searchable design database. | Candidate only for optional UI-design review lens; avoid importing large design database. |
| `shanraisshan/claude-code-best-practice` | `bbe645975149` | Agentic engineering practice notes, settings drift, workflow examples. | Reference only; no direct SDD asset identified this pass. |
| `tirth8205/code-review-graph` | `b72413cbd34a` | Local code intelligence graph for review/exploration. | Candidate optional integration for large-repo review context, not core kit. |
| `ultraworkers/claw-code` | `4ea31c1bc91c` | Agent-managed Rust application example. | No direct SDD kit import candidate this pass. |

## Follow-Up Plan

1. Create an SDD-specific Quality Evals package by evaluating
   `everything-claude-code` `agent-eval`, `eval-harness`,
   and `ai-regression-testing`. Do not select `benchmark-methodology` by name:
   the September snapshot covers competitive positioning instead.
2. Evaluate `spec-kit` constitution, clarify, checklist, converge, and
   task-to-issues patterns against existing `agent-behavior-standards`,
   `analyze-sdd-artifacts`, `validate-impl-spec`, and `execute-task-train`.
3. Evaluate frontend visual QA improvements from `ui-ux-pro-max-skill` and
   `claude-webkit` only through SDD AC/design-system evidence requirements.
4. Evaluate whether `code-review-graph` should become an optional
   `large-repo-review-context` skill or documented integration.
5. Re-run this audit before taking future upstream changes; update audited
   revisions and explain every import decision.
6. Plan an optional minimal SDD harness over the existing validators, with
   approval-bound state, independently recorded evidence, bounded retries,
   explicit resume, and AC-preserving convergence. Measure it against a
   baseline before adopting additional orchestration. No runtime imports
   were made in the September research pass.
7. Make the existing TDD requirement evidence-backed in that update: observed
   RED before implementation, GREEN without weakened behavioral assertions,
   and explicit QA reporting of test-after or unverified sequence. Add a
   concise SOLID review contract alongside existing architecture and
   simplicity rules. These are mandatory proposal requirements; enforcement
   is not implemented by this documentation update.
