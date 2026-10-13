# Upstream Review and Harness Adoption Proposal

## Decision

Adopt selected methods from Spec Kit while keeping `kathy-sdd-kit` as the portable source of SDD policy. The highest-value experiment is an optional, bounded execution harness that consumes an approved ticket plan, invokes existing validators, records verifiable results, and resumes without losing acceptance-criterion identity. Pair it with behavioral evaluations before expanding automation.

Do not replace the kit with Spec Kit or import the three repositories wholesale. Spec Kit supplies useful workflow and specification practices; claude-skills supplies a compact loop-controller reference; ECC supplies evaluation and adapter patterns. Their execution models and storage conventions need adaptation to this kit.

This is a research and adoption proposal, not an approved implementation specification. No runtime, skill, template, test, configuration, or version change is delivered here. The implementation gate in root `AGENTS.md` still applies after a canonical work item and implementation scope are resolved.

## 1. Audit Boundary and Revision Evidence

The local kit reports version `0.6.0`. The previous source register is dated July 4, 2026. This audit compares its recorded revisions with default-branch heads observed on September 9, 2026. All source-file links below are pinned to the inspected revision; release links describe published releases, not the entire current branch.

| Repository | Previous revision | Inspected revision | Head commit date, UTC | Commits since baseline |
|---|---|---|---|---:|
| github/spec-kit | `bba473c223dc` | `86b7a01420a42b479f55296554030c8962744759` | 2026-09-09 | 644 |
| kathesama/claude-skills | `1bd5b1a0b51c` | `aa8d778811a557a2c28ccadda4cf3d0bd028a4cc` | 2026-07-17 | 91 |
| kathesama/everything-claude-code | `49128b5763b7` | `d8409a4b0813771235555e32e3d8046a73988bfa` | 2026-08-19 | 175 |

The three comparisons are ahead-only relative to the recorded baselines. The accompanying [commit inventory](upstream-commit-inventory-2026-09-09.json) enumerates all 910 commit records, with dates, subjects, and canonical links. This is complete metadata enumeration for these comparisons, not a claim that every patch was semantically reviewed. GitHub's comparison file lists stop at 300 files for Spec Kit and ECC; current recursive tree responses were not truncated. Detailed inspection concentrates on specification workflows, harnesses, evidence, resume, evaluation, and local compatibility. [S1–S3]

The fork distinction matters. claude-skills identifies `alirezarezvani/claude-skills` as its parent; ECC identifies `affaan-m/ECC`. Both fork metadata records show an August 20 push, but that does not change the dates of the default-branch commits above. Parent heads were not audited or synchronized. Findings describe the requested forks. [S2–S3]

Spec Kit's newest observed published release is **v1.0.5**, published September 8. The September 9 per-step integration configuration is in inspected `main`, after that release. claude-skills' release collection exposes v2.8.2, while recent commit metadata references 2.11.2; its release body also carries a May date despite a July publication timestamp. ECC's package manifest says **2.2.0**, but the requested fork returns no releases. Use SHAs for the two forks rather than inferring installed or published versions from a README. [S4–S6]

## 2. Spec Kit: What Actually Changed

### 2.1 Existing mechanisms versus newly added methods

Workflows, bundles, presets, and `converge` were already present in the July baseline tree. Calling them September inventions would misrepresent the comparison. They remain important adoption candidates because the local kit has not implemented equivalent runtime behavior. `extensions/assess/README.md` is absent from that baseline and present now. [S1, S7]

| Change | Evidence | Consequence for this kit |
|---|---|---|
| Configurable shell-step timeouts and workflow input validation | July commits #3404, #3327/#3328 and subsequent validation fixes | Budgets and malformed-input handling belong in executable code. |
| Idea assessment pipeline | July 17, #3568 | Add optional discovery before committing to delivery. |
| Constitution write scope narrowed | July 22–28, #3646 and #3737/#3790 | Project policy updates should not silently rewrite framework templates or execute features. |
| Clearer clarification questions | July 28, #3745 | Ask real, consequential questions; persist their answers in the spec. |
| Agent-native runtime hooks | July 29, #3704 | Runtime support must be checked per agent, not inferred from shared skill files. |
| Gate verdict supplied through workflow input | July 30, #3725 | Resume can consume an explicit decision, but its provenance needs local enforcement. |
| Custom checklist ownership clarified | August 11, #4028 | Requirements review is distinct from implementation evidence. |
| v1.0.0 published | August 21 | A release milestone; it does not mean every community extension is equally mature. |
| Workflow slots | September 3, #4352; included in v1.0.5 | Optional insertion points are useful only after actual extension demand exists. |
| Data-model field constraints preserved in tasks | September 8, #4430 | Prevent task decomposition from dropping required, enum, length, and nullability rules. |
| Per-step integration arguments/options | September 9, #4425; after v1.0.5 | Mixed-runtime experiments are possible, but should not be the first local pilot. |

Commit identities and dates are in the inventory. Release membership is checked against the release notes rather than assumed from the branch. [S1, S4]

### 2.2 Workflows: durable execution, with important limits

The workflow reference describes command, prompt, shell, gate, conditional, loop, fan-out/fan-in, and slot steps. Runs preserve `state.json` and support resume after pause or failure; JSON output separates structured results from progress output. This is a stronger operational basis than asking an agent to remember which prose step it last completed. [S8]

The bundled `speckit` workflow is narrower than the complete methodology: specify, review-spec gate, plan, review-plan gate, tasks, implement. It does not include clarify, analyze, converge, or local SDD QA by default. A default workflow installation therefore would not reproduce the full contract of `kathy-sdd-kit`. [S9]

The inspected gate implementation pauses without a terminal and can resolve a verdict from a named input. A non-empty default can auto-decide a gate. Overlays can replace steps, including review gates. For our adoption, a model-generated value or default must never become the required human `approve`; ordinary resume within unchanged approved scope should not ask again. Material plan changes need a new decision tied to the changed content. [S8, S10]

The workflow engine explicitly does **not** provide a capability sandbox. Shell steps execute with the user's privileges, and interpolated values are plain substitutions. A gate does not inspect the next command. Therefore `requires`, a YAML permission-looking field, or a review prompt cannot be sold as execution isolation. A local harness should start with known validator commands passed as argument arrays, with explicit working directories and timeouts, rather than arbitrary shell snippets assembled from tickets or model output. [S8]

**Recommendation:** adopt persistent state, structured results, bounded attempts, and explicit resume semantics. Defer a general workflow language, dynamic catalogs, shell interpolation, and multi-agent dispatch until a simple sequential pilot demonstrates value.

### 2.3 Assess: discovery before delivery

The bundled assessment extension separates five activities: intake, research, problem definition, shaping options, and a decision of go, needs-clarification, or kill. Research explicitly looks for contrary evidence. A go decision needs a defined problem, adequate evidence, and a shaped concept. `define` can be the minimum viable entry, so five documents are not always necessary. [S11]

It is opt-in and registers no automatic lifecycle hooks. That matters: a mature, refined ticket should not be forced through another discovery ceremony. For the harness proposal, its useful questions are concrete: which failures recur, what can be checked mechanically, and whether reduced intervention justifies another runtime dependency. A go decision is still not implementation approval. [S11]

**Local fit:** extend the existing enrichment process with an optional assessment report for ambiguous ideas and architectural experiments. Reuse its evidence and non-goals when planning. Do not create a second source of acceptance criteria under `.specify/assessments/`.

### 2.4 Clarify and checklist: improve the contract before execution

Clarify scans functional scope, domain data, interaction, non-functional attributes, integrations, failure cases, constraints, and terminology. It prioritizes questions whose answers change implementation or validation, and records answers in the specification. The current command limits the question queue and requires understandable interrogatives. [S12]

The local `enrich-user-story` already contains a clarification scan. The useful adaptation is a stronger traceable decision record and unresolved-risk classification, not another mandatory questionnaire. Ask only when repository evidence and existing decisions cannot resolve a material ambiguity.

Spec Kit custom checklists evaluate **requirements quality**. A checked item says the requirement has been reviewed; it does not prove the application works. The checklist generator must not mark its own custom items complete. This distinction maps directly to our separation between validated planning artifacts and per-AC execution evidence. [S13]

**Example:** “Is the maximum retry count specified?” belongs to requirements review. “The client stops after the third failed attempt, as demonstrated by test X” belongs to implementation verification. Passing the former must never grant coverage for the latter.

### 2.5 Constitution and configuration precedence

The current constitution command updates the project constitution only. Templates read it at runtime. September 9 guidance describes the sync-impact report as temporary review material. An optional constitution-sync preset exists, so older assumptions about automatic template propagation should not be carried into a new integration. [S14]

Our kit already has project override precedence through `AGENTS.md`, `CODEX.md`, ADRs, contracts, and `DESIGN.md`. Adding a competing constitution file immediately would increase authority ambiguity. A small documented policy-resolution report could provide the benefit while retaining those existing sources.

Presets customize existing files, extensions add capabilities, and bundles assemble versioned component sets. File resolution gives project-local overrides precedence, then presets, extensions, and core. Commands are materialized into the active integration; they are not dynamically re-resolved by every agent invocation. Bundles add packaging and dependency lifecycle behavior that our source-mounted kit currently does not need. [S15–S16]

**Recommendation:** retain the single canonical skill source and explicit project overrides. Trial lightweight profiles only if two consuming projects require different behavior. Do not copy the lean preset directly: removing template ceremony can also remove the literal sections required by our validators. [S17]

### 2.6 Converge: inspect the implementation against approved intent

Converge reads spec, plan, and tasks, inspects scoped code, and classifies missing, partial, contradicting, and unrequested behavior. Its only allowed write is appending remediation tasks; no-gap runs leave the task file unchanged. It does not itself implement fixes. This complements artifact analysis: consistent documents can still describe code that was never built. [S18]

Our `analyze-sdd-artifacts` checks agreement among artifacts, while QA/review inspect behavior and evidence. A convergence report could bridge them without replacing either. It should preserve member-ticket plus AC identity, deduplicate recurring findings, and distinguish a missing requirement from insufficient evidence. A static inspection verdict must not substitute for a runtime check required by an AC.

Appended tasks need scope classification. A repair within the approved plan can continue under that approval; a new behavior, new contract, or removed obligation requires a revised plan. Unrequested code should be reported, not automatically deleted. Repeated convergence must stop at an explicit budget and preserve unresolved findings.

### 2.7 Living specifications and existing projects

Spec Kit now documents three maintenance models: flow-forward preserves historical feature records, living spec updates the contract before derived artifacts, and flow-back reconciles discoveries from implementation into the artifact set. [S19]

**Recommended local policy:** preserve ticket plans and append-only changelogs as historical delivery evidence; maintain ADRs, API contracts, and `DESIGN.md` as living project contracts. Permit flow-back as a proposal for reconciliation, never as permission to rewrite ACs after a failing test. This preserves the useful distinction already present in the kit.

### 2.8 Evaluator Contract: promising community reference

Spec Kit's catalog added the external Evaluator Contract extension in #4420. It is community code, not a built-in guarantee of Spec Kit. Its v1.0.0 README defines outcomes `pass`, `warn`, `iterate`, `clarify`, `gather_evidence`, and `block`, and distinguishes observed, inferred, asserted, contradicted, and unsupported evidence. It also calls for preserving disagreement and compact resume state. [S20]

This is particularly relevant to our `Covered` status: a generated sentence should not carry the same authority as a check result. The protocol's intent is useful, but schema validity alone is insufficient: its minimal example permits a pass with empty findings. The kit must require actual evidence for each obligatory AC. Its optional hooks and majority/optimistic composition modes are not suitable as mandatory local gates. Use strict blocking behavior for required obligations.

Only the pinned README and catalog entry were reviewed for this external extension; its implementation and tests were not audited. Treat it as a contract-design reference, not an installation recommendation or a tested dependency.

## 3. claude-skills: A Small Harness and a Larger Learning Experiment

### 3.1 Agent harness added since the baseline

The new agent-harness separates a domain manifest, a goal-derived plan, and a persistent run state. Its controller provides init, next, record, verify, and close operations. Verification can execute checks in subprocesses, with timeouts; failed attempts are counted and closure is refused while work remains unresolved. State writes use a temporary file and replacement. These are concrete implementation patterns worth adapting. [S21–S23]

However, static code inspection exposes boundaries that prose alone does not enforce:

| Observation | Implication |
|---|---|
| `record --phase verify --exit-code 0 --evidence ...` accepts a non-empty evidence string and marks a verifying task verified. | The agent can attest without the controller having run the executable checks. |
| `close --waive ... --reason ...` consumes CLI arguments; the code does not establish a separate human principal. | “Only a human waives” is an instruction, not an authenticated boundary. |
| `cmd_record` and `cmd_verify` perform work before the returned `directive` checks the global cap. | The returned stop directive is not equivalent to preventing direct further mutation through all commands. |
| Verification uses `shell=True` for commands in the state. | A state file contains executable authority and must not be treated as harmless imported data. |
| Atomic replacement exists, but no independent-writer lock was identified in the controller. | Avoid claiming concurrent session safety; use one writer in a pilot. |

These are source-level observations, not demonstrated exploit runs. The upstream code was not executed. For our kit, separate manual evidence from machine checks, prevent manual records from satisfying required executable checks, validate budgets before work, and treat waiver as a distinct non-covered outcome. [S22]

### 3.2 Specification workflow and selective reuse

The fork includes a spec-driven-workflow skill with its own generator, validator, and acceptance-test extraction references. Importing those beside `validate-impl-spec.sh` would create competing formats. Reuse ideas through the existing planner and validators, preserving literal headings, canonical ticket paths, and the companion-spec contract. [S24]

Recent unrelated productivity, meeting, and marketplace changes are present in the inventory but do not justify kit changes. Minimalist/strict-api additions should be considered only for a demonstrated gap in existing complexity review or API-contract workflows, not as another globally loaded rule set.

### 3.3 SkillOpt-Sleep is a separate experimental track

SkillOpt-Sleep harvests session records, mines tasks, replays them, proposes bounded document edits, evaluates a held-out set, stages changes, and then adopts them. The skill distinguishes a mock backend from real agent backends and exposes budget and scheduling controls. That gives us a useful future process for improving skills based on observed failures. [S25]

It is not model training and a deterministic demo is not evidence of better real SDD delivery. It also introduces transcript access, API consumption, scheduling, and instruction/memory changes. Keep it outside the first harness pilot. A later experiment should use reviewed task records, a disjoint holdout, staged suggestions, and explicit adoption; never silently update the kit's own rules from a session. No session harvesting, memory modification, scheduling, or paid replay was performed in this audit.

## 4. ECC: Evaluation Discipline and Runtime Portability

### 4.1 Changes with local relevance

The 175-commit delta includes Plan Canvas, a read-only reviewer contract, a delegation-completion contract, a contract-first collaboration workflow, shared memory, adapter documentation, bounded harness evaluation with rollback, and installer hardening. Later TasteForge, Nasiko, and Itô changes expand product-specific surfaces and are not needed for portable SDD. [S3]

The useful principle is to keep the shared contract stable and adapt runtime mechanics at the edge. ECC's matrix explicitly distinguishes native, adapter-backed, instruction-backed, and reference-only support. It describes Codex hook behavior as instruction-backed for that ECC revision; this is a statement about the inspected adapter, not a universal claim about every current Codex capability. [S26]

Our `.agents/skills/` exposure already solves discovery. It does not prove runtime hook enforcement, interruption handling, or approval integrity. A local capability table should name the installed agent/version and the evidence for each supported surface.

### 4.2 Evaluation versus audit scoring

`eval-harness` recommends defining capability and regression evaluations before changing agent behavior. `agent-eval` describes repeated comparisons using task definitions, deterministic judges, time, cost, and pass rate. The latter points to an external CLI; the skill file is not proof that this CLI is installed or that its commands work here. [S27–S28]

Use deterministic checks as the first evidence tier and model review for semantic judgments that cannot be checked mechanically. A pattern match may establish a name exists, but cannot establish correct retry behavior. Human review remains necessary where the intended result is subjective or evidence is disputed.

`scripts/harness-audit.js` scores configuration and repository signals. Such a score is a readiness heuristic, not measured task success. Also, the inspected `benchmark-methodology` skill concerns competitive positioning and brand dimensions; its name alone does not make it a coding-agent benchmark. Do not import it into Quality Evals on the basis of the earlier candidate register. [S29–S30]

### 4.3 Bounded evaluation and rollback

ECC's `ecc2/src/harness_eval.rs` includes content-addressed candidate configurations, evidence references, paired seeds, minimum samples, mean-delta and win-rate policy checks, and a recorded evaluator. Commit #2686 introduces the broader bounded evaluation and rollback loop. These are useful foundations for candidate-versus-baseline experiments. [S31]

The inspected evaluator reads recorded scores and a candidate-keyed health assertion. Hashes bind data to a candidate; they do not establish that the scores came from a live agent or that a claimed health result was independently observed. Importing the entire alpha control plane would be disproportionate. Adapt the provenance and comparison concepts into a small evaluation package, with actual run records and independent checks.

## 5. Local Kit Strengths and Gaps

| Existing local surface | What it already provides | Gap worth addressing |
|---|---|---|
| `AGENTS.md`, `CODEX.md` | Planning approval, source precedence, project overrides, ticket identity | Approval/resume binding is procedural. |
| `ai-specs/skills/enrich-user-story/SKILL.md` | Clarification scan and explicit ACs | Optional evidence-against assessment and decision traceability. |
| `tools/validate-impl-spec.sh` | Required sections, enums, mappings, weak evidence rejection | It parses artifacts; it does not execute the AC validation plan or authenticate evidence. |
| `ai-specs/skills/analyze-sdd-artifacts/SKILL.md` | Cross-artifact consistency and ambiguity review | A separate, bounded code-to-intent reconciliation result. |
| `ai-specs/skills/execute-task-train/SKILL.md` | One anchor, ordered members, member-scoped evidence and consolidated QA | Durable controller state and guarded transitions across sessions. |
| `docs/ac-enforcement-pressure-scenarios.md` | Twelve documented pressure scenarios | Repeatable agent trajectories and independently graded behavioral results. |
| `ai-specs/skills/verify-ac-enforcement/SKILL.md` | Scenario-based checks; allows mental or target-agent execution | Mental simulation must remain labeled separately from live evaluation. |
| `.github/workflows/sdd-kit.yml` | Positive and negative structural fixtures on Ubuntu | Behavioral harness evaluation and demonstrated Windows runtime coverage. |
| `tools/sync-agent-skills.sh` | Single-source skill exposures | Discovery checks do not prove behavior or hook parity. |

These conclusions come from the local files, not a remote description of this repository. The inspected CI is a configuration, not evidence that a current CI run passed.

Two adjacent findings should remain explicit follow-ups. `base-standards.mdc` states 90%+ coverage among its principles and 80% in Definition of Done; the adopted policy should be made unambiguous before an automated gate consumes it. The workspace resolver invokes `git rev-parse`, while the supplied session rules permit only status/diff commands; a future no-Git harness profile must address this hidden dependency rather than silently violate the rule. Neither was changed here.

## 6. Recommended Experiment

### 6.1 What harness means here

A harness is the controlled execution environment around the agent: approved intent, available operations, state, verification, budgets, and stop conditions. It complements the spec by controlling how work is attempted and judged. An evaluation harness measures whether that control improves outcomes across repeatable scenarios. These are related but separate deliverables.

### 6.2 Candidate design, not an implemented API

Use three small contracts: an approved-plan reference, a run state, and an evidence result. Keep execution state under `.ai-specs/changes/{TICKET}/harness/`; preserve the existing Markdown specs and changelog as their authoritative artifact types. The harness must not become another independently editable implementation plan.

The plan reference should bind the canonical ticket, member identities, scope/validation content, kit version, and explicit approval. Compute approval identity from stable approved content, not mutable completion-evidence rows. Otherwise normal progress would spuriously invalidate approval.

Each evidence result should identify the AC, check, evidence kind, evaluator version, input/artifact digest, working directory, outcome, timestamp, duration, and output reference. Capture only needed sanitized output; failed checks and unknown cost must remain failures and unknowns. A machine-result digest detects stale or altered content but cannot authenticate the evaluator if the agent can rewrite both result and digest.

The first pilot should use one writer, fixed validator invocations, explicit timeouts, and persistent attempts. Missing state, schema mismatch, stale plan references, interrupted writes, and exhausted budgets must produce a recoverable stop rather than a clean pass. Resuming unchanged approved work should reuse approval. Manual/waived evidence must remain distinct from executed and covered ACs.

This proposal should not promise a security boundary that the host cannot enforce. If the agent retains unrestricted access to the same result files or can bypass the controller, label enforcement as cooperative. Stronger enforcement requires host/CI-controlled validation and permissions outside the agent's writable surface.

### 6.3 Mandatory TDD and engineering-quality requirements

The September 9 follow-up requirement makes test-first behavior a mandatory
part of this update. TDD already exists in `ai-specs/specs/base-standards.mdc`
and the backend planner's execution flow. The frontend planner permits TDD or
component-first validation. The missing work is evidence and enforcement of
the sequence, not merely adding another mention of TDD.

For new executable behavior and bug fixes, the proposed harness must require:

1. A behavior test derived from an AC or bug reproduction, defined before the
   implementation or fix. Record the expected failing assertion and its link
   to the behavior contract.
2. An actual RED execution against the pre-change implementation, with the
   test identity, test-content digest, baseline identity, command, exit status,
   and diagnostic output. A missing tool, syntax error, or unrelated fixture
   failure does not establish the intended RED condition. A missing API can
   establish RED only when that absence is the behavior explicitly under test
   and the surrounding test environment is operational.
3. The minimal implementation, followed by GREEN using the same behavioral
   assertion. If the test changes, preserve the reason and rerun RED against
   the pre-change snapshot; do not replace a difficult assertion with an
   easier one just to pass.
4. Refactoring, if needed, followed by relevant regression checks. No
   refactoring step is required when there is nothing useful to simplify.
5. Evidence available to QA and review. Final GREEN alone must never be
   described as proof of test-first development. Convergence remains a later
   completeness check and cannot grant retrospective TDD compliance.

For existing buggy code, writing a reproduction test before the fix is TDD
for the fix. Writing a test after the fix can still add regression protection,
but does not prove the original test-first sequence. Rerunning that test on an
older snapshot can establish bug-detection sensitivity; it cannot manufacture
historical evidence that the test was written first. Distinguish both facts.

Do not create artificial RED results for documentation-only edits or
behavior-preserving refactoring. Refactoring starts from passing behavior or
characterization tests and preserves them. Purely visual judgments may need
review evidence; frontend interactions, validation, permissions, and state
changes still require executable behavior checks where feasible. A missing
test runner for testable behavior is a prerequisite to resolve or a recorded
blocker, not permission to silently switch to test-after development. These
applicability distinctions must be recorded in planning and cannot be used by
the implementing agent to waive an obligatory AC.

The evidence adapter must distinguish `test-first observed`, `test-after`,
`unverified sequence`, and `not applicable` as proposed evidence concepts,
without changing the existing `Covered` / `Partial` / `Not Covered` AC enums.
A feature may behave correctly while failing the required development process;
QA must report both rather than falsifying either conclusion. Controller
ordering and hashes alone do not prove chronology if the agent can edit all
records; stronger claims need independently controlled capture.

Engineering quality must remain complementary to TDD. Passing tests cannot
prove good dependency boundaries, a coherent responsibility split, or a useful
abstraction. Existing backend standards and Clean Architecture rules establish
inward dependencies and ports/adapters, and the complexity ladder discourages
speculative abstractions. The inspected kit does not explicitly enumerate all
five SOLID principles. Add a concise, language-appropriate review contract:

| Principle | Required review question | Suitable evidence |
|---|---|---|
| Single Responsibility | Does the changed module have one coherent responsibility and reason to change? | Boundary and responsibility rationale tied to the actual diff. |
| Open/Closed | Does the needed extension preserve established behavior without speculative extension points? | Extension scenario and regression evidence where applicable. |
| Liskov Substitution | Do interchangeable implementations preserve the caller's behavioral contract? | Shared contract tests when substitution exists. |
| Interface Segregation | Are consumers forced to depend on operations they do not need? | Consumer and interface inspection. |
| Dependency Inversion | Does core policy avoid depending directly on infrastructure details? | Dependency inspection and core tests without external infrastructure. |

Apply these questions to real design decisions. Do not mandate inheritance,
one interface per class, additional layers, or factories where they add no
value. Keep the existing simplicity, reuse, AC traceability, security,
accessibility, API contracts, and selected engineering obligations. Record
non-applicable principles with a concrete reason, rather than inventing code
to satisfy a checklist. This update must make quality obligations observable,
not replace architectural review with an automated SOLID score.

### 6.4 Pilot sequence and proposed acceptance checks

| Phase | Deliverable | Acceptance checks | Deferred scope |
|---|---|---|---|
| A0: Test-first and design contract | TDD applicability, RED/GREEN provenance, and explicit SOLID review criteria integrated into planning and QA | Reject GREEN-only TDD claims, unrelated RED failures, weakened assertions, and fabricated chronology; preserve appropriate refactoring/documentation validation; review applicable SOLID obligations without forced abstractions | Automatic architecture scoring or exemption from required behavior tests |
| A: Evidence foundation | Versioned evidence contract and adapters for existing validators | False pass, missing output, invalid status, stale artifact, and malformed input rejected; valid existing artifacts remain compatible | General scheduler and model routing |
| B: Bounded execution | Sequential init/status/verify/resume/close behavior, designed in the implementation plan | Refuse execution without approval; preserve approval on ordinary resume; stop before over-budget work; do not close with required ACs uncovered | Parallel writes, arbitrary shell DSL, automatic waivers |
| C: Convergence | Scoped implementation-to-intent report with stable findings | Missing/partial/contradicting/unrequested examples classified; repeated run does not duplicate work; new scope returned to planning | Automatic code deletion or spec weakening |
| D: Behavior evals | Baseline/candidate runs on representative pressure scenarios | Independent check results, complete run metadata, explicit failures and costs; no structural fixture presented as a live agent run | Unattended learning and production adoption |
| E: Optional discovery | Assessment and requirements-quality review integrated with enrichment | Existing refined tickets avoid extra questions; unresolved material assumptions remain visible | New tracker backend or a mandatory five-document funnel |

Potential implementation targets are `ai-specs/skills/`, `ai-specs/specs/`, `tools/`, `examples/`, and `.github/workflows/sdd-kit.yml`; exact new filenames belong in the approved implementation spec. Keep the existing POSIX-only gate usable. If the optional controller needs Python for structured state, document that dependency explicitly and keep it out of baseline kit validation.

### 6.5 Evaluation protocol

Start with six scenario families selected from the existing pressure suite and harness-specific risks: missing child AC, unapproved implementation, forged completion evidence, interrupted resume, repeated failing validation, and cross-member AC contamination. Use reviewed fixtures in fresh temporary directories; this session's Git restrictions rule out assuming worktree creation.

Compare baseline and candidate with the same model/runtime version, prompts, fixture digests, tool permissions, and check definitions. Use at least three independent trials per scenario as a smoke experiment: six scenarios times three trials times two variants gives 36 runs. This is a proposed sample size, not executed work or statistical proof. Stop a run at its budget and count the failure; do not drop it from the denominator.

Report first-attempt success, success within a bounded repair budget, all-trial consistency, AC omissions, false completion, approval bypass, intervention count, elapsed time, and observed cost. Missing billing data is unknown, not zero. Separate independent trials from iterative repairs; otherwise pass@k can hide a weak first attempt or an expensive recovery loop.

Predeclare hard rejection criteria: any unauthorized execution or falsely covered required AC rejects the candidate. Evaluate latency/cost changes separately from correctness, with tolerances chosen before the experiment. Use a disjoint holdout for follow-up tuning and retain negative cases. Passing 18 candidate trials does not establish production reliability; promotion requires representative real ticket evidence.

Extend those six initial scenario families with four mandatory TDD cases:
implementation attempted before RED, RED caused by an unrelated test error,
assertion weakened between RED and GREEN, and test-after evidence presented
as test-first. The expanded pilot has ten families, three trials, and two
variants: 60 proposed runs. Include positive cases for a genuine bug
reproduction and appropriate characterization before refactoring. Preserve
separate reporting for behavior correctness, TDD sequence, and architecture
review; a higher test pass rate must not conceal a bypass of mandatory TDD.

## 7. Adoption Choices

| Option | Benefits | Costs | Judgment |
|---|---|---|---|
| Native minimal harness over existing kit | Preserves paths, gates, and portability; smallest behavior change | We own a small controller and its tests | Recommended first pilot |
| Optional Spec Kit bridge, pinned to a published version | Reuses workflow engine and integrations | Two artifact/config conventions; approval and shell semantics need adaptation | Compare after evidence foundation, in a fixture project |
| Replace kit with Spec Kit plus a custom preset | Broad ecosystem reuse | Migration of ticket identity, overrides, validators, and delivery evidence | Not justified by current evidence |
| Embed ECC control plane or SkillOpt-Sleep | Broad orchestration or learning capabilities | Much larger runtime and trust surface | Separate later experiment only |

The immediate update is the research register and this proposal. The next implementation package should contain phases A0–D with explicit ACs and a single reviewable planning gate. TDD evidence and applicable engineering-quality obligations are mandatory scope. Discovery can be a separate optional follow-up. No version number is assigned in advance: versioning should reflect the approved and verified compatibility impact.

## 8. Validation and Limitations

Verified remotely: requested repository identities, baseline/head commits, all comparison commit metadata, release collections, current file trees, and the cited source files. Verified locally: kit version, entrypoints, source register, relevant skills, validators, scenario documentation, template, runtime guide, and CI configuration.

Not performed: upstream runtime installation, third-party script execution, a security audit of complete upstream repositories, current CI execution, live agent benchmarks, paid replay, fork synchronization, commits, or pull requests. Source review establishes design behavior and limitations; it does not establish measured reliability or performance improvement.

## Sources

- **S1. GitHub, Spec Kit comparison and baseline tree.** [Comparison](https://github.com/github/spec-kit/compare/bba473c223dc298fb76ecf8f87f86d5d2b8ed11c...86b7a01420a42b479f55296554030c8962744759), [baseline tree](https://github.com/github/spec-kit/tree/bba473c223dc298fb76ecf8f87f86d5d2b8ed11c).
- **S2. kathesama, claude-skills metadata and comparison.** [Metadata](https://api.github.com/repos/kathesama/claude-skills), [comparison](https://github.com/kathesama/claude-skills/compare/1bd5b1a0b51c91f6e3335592c2b41ffb9b543002...aa8d778811a557a2c28ccadda4cf3d0bd028a4cc).
- **S3. kathesama, ECC metadata and comparison.** [Metadata](https://api.github.com/repos/kathesama/everything-claude-code), [comparison](https://github.com/kathesama/everything-claude-code/compare/49128b5763b7ac0b50acef35ac0bcca08d1576af...d8409a4b0813771235555e32e3d8046a73988bfa).
- **S4. GitHub, Spec Kit v1.0.5, September 8, 2026.** [Release](https://github.com/github/spec-kit/releases/tag/v1.0.5).
- **S5. kathesama, claude-skills release record.** [v2.8.2](https://github.com/kathesama/claude-skills/releases/tag/v2.8.2).
- **S6. kathesama, ECC package and releases.** [Package manifest](https://github.com/kathesama/everything-claude-code/blob/d8409a4b0813771235555e32e3d8046a73988bfa/package.json), [release collection](https://api.github.com/repos/kathesama/everything-claude-code/releases).
- **S7. GitHub, Spec Kit changelog.** [Pinned file](https://github.com/github/spec-kit/blob/86b7a01420a42b479f55296554030c8962744759/CHANGELOG.md).
- **S8. GitHub, Workflow reference.** [Pinned file](https://github.com/github/spec-kit/blob/86b7a01420a42b479f55296554030c8962744759/docs/reference/workflows.md).
- **S9. GitHub, Bundled SDD workflow.** [Pinned YAML](https://github.com/github/spec-kit/blob/86b7a01420a42b479f55296554030c8962744759/workflows/speckit/workflow.yml).
- **S10. GitHub, Gate implementation.** [Pinned code](https://github.com/github/spec-kit/blob/86b7a01420a42b479f55296554030c8962744759/src/specify_cli/workflows/steps/gate/__init__.py).
- **S11. GitHub, Idea assessment pipeline.** [Pinned README](https://github.com/github/spec-kit/blob/86b7a01420a42b479f55296554030c8962744759/extensions/assess/README.md).
- **S12. GitHub, Clarify command.** [Pinned template](https://github.com/github/spec-kit/blob/86b7a01420a42b479f55296554030c8962744759/templates/commands/clarify.md).
- **S13. GitHub, Checklist command.** [Pinned template](https://github.com/github/spec-kit/blob/86b7a01420a42b479f55296554030c8962744759/templates/commands/checklist.md).
- **S14. GitHub, Constitution command.** [Pinned template](https://github.com/github/spec-kit/blob/86b7a01420a42b479f55296554030c8962744759/templates/commands/constitution.md).
- **S15. GitHub, Presets reference.** [Pinned file](https://github.com/github/spec-kit/blob/86b7a01420a42b479f55296554030c8962744759/docs/reference/presets.md).
- **S16. GitHub, Bundles reference.** [Pinned file](https://github.com/github/spec-kit/blob/86b7a01420a42b479f55296554030c8962744759/docs/reference/bundles.md).
- **S17. GitHub, Lean preset.** [Pinned README](https://github.com/github/spec-kit/blob/86b7a01420a42b479f55296554030c8962744759/presets/lean/README.md).
- **S18. GitHub, Converge command.** [Pinned template](https://github.com/github/spec-kit/blob/86b7a01420a42b479f55296554030c8962744759/templates/commands/converge.md).
- **S19. GitHub, Evolving specs.** [Pinned guide](https://github.com/github/spec-kit/blob/86b7a01420a42b479f55296554030c8962744759/docs/guides/evolving-specs.md).
- **S20. ElectroHire, Evaluator Contract v1.0.0.** [README](https://github.com/electrohire/spec-kit-evaluator/blob/v1.0.0/README.md), [Spec Kit catalog entry](https://github.com/github/spec-kit/blob/86b7a01420a42b479f55296554030c8962744759/extensions/catalog.community.json).
- **S21. kathesama, Agent Harness skill.** [Pinned skill](https://github.com/kathesama/claude-skills/blob/aa8d778811a557a2c28ccadda4cf3d0bd028a4cc/engineering/agent-harness/skills/agent-harness/SKILL.md).
- **S22. kathesama, Agent Harness controller.** [Pinned code](https://github.com/kathesama/claude-skills/blob/aa8d778811a557a2c28ccadda4cf3d0bd028a4cc/engineering/agent-harness/skills/agent-harness/scripts/loop_controller.py).
- **S23. kathesama, Agent Harness manifest schema.** [Pinned schema](https://github.com/kathesama/claude-skills/blob/aa8d778811a557a2c28ccadda4cf3d0bd028a4cc/engineering/agent-harness/skills/agent-harness/assets/harness_manifest.schema.json).
- **S24. kathesama, Spec-driven workflow.** [Pinned skill](https://github.com/kathesama/claude-skills/blob/aa8d778811a557a2c28ccadda4cf3d0bd028a4cc/engineering/skills/spec-driven-workflow/SKILL.md).
- **S25. kathesama, SkillOpt-Sleep.** [Pinned skill](https://github.com/kathesama/claude-skills/blob/aa8d778811a557a2c28ccadda4cf3d0bd028a4cc/engineering/skillopt-sleep/skills/skillopt-sleep/SKILL.md).
- **S26. kathesama, ECC adapter compliance.** [Pinned matrix](https://github.com/kathesama/everything-claude-code/blob/d8409a4b0813771235555e32e3d8046a73988bfa/docs/architecture/harness-adapter-compliance.md).
- **S27. kathesama, Eval Harness.** [Pinned skill](https://github.com/kathesama/everything-claude-code/blob/d8409a4b0813771235555e32e3d8046a73988bfa/skills/eval-harness/SKILL.md).
- **S28. kathesama, Agent Eval.** [Pinned skill](https://github.com/kathesama/everything-claude-code/blob/d8409a4b0813771235555e32e3d8046a73988bfa/skills/agent-eval/SKILL.md).
- **S29. kathesama, Harness audit scoring.** [Pinned code](https://github.com/kathesama/everything-claude-code/blob/d8409a4b0813771235555e32e3d8046a73988bfa/scripts/harness-audit.js).
- **S30. kathesama, Benchmark methodology.** [Pinned skill](https://github.com/kathesama/everything-claude-code/blob/d8409a4b0813771235555e32e3d8046a73988bfa/skills/benchmark-methodology/SKILL.md).
- **S31. kathesama, Bounded harness evaluation.** [Pinned code](https://github.com/kathesama/everything-claude-code/blob/d8409a4b0813771235555e32e3d8046a73988bfa/ecc2/src/harness_eval.rs), [introducing commit](https://github.com/kathesama/everything-claude-code/commit/623f2c020f05).
