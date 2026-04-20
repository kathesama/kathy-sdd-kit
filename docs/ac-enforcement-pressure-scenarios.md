# Acceptance Criteria Enforcement Pressure Scenarios

Use these scenarios when validating changes to `kathy-sdd-kit` that affect enrichment, planning, implementation, or PR reporting.

## Goal

Verify that the kit prevents agents from:

- dropping explicit acceptance criteria
- merging unrelated acceptance criteria into vague work items
- marking a task done without AC-specific evidence
- generating PR reports that hide partial or missing coverage

## How to run the scenarios

For each scenario:

1. Run the workflow stage without recent kit changes, or with the suspected regression.
2. Capture the baseline output and note where the agent rationalizes skipping AC coverage.
3. Run the same scenario with the current kit.
4. Compare the output against the expected pass criteria.

Record:

- which ACs were preserved
- whether every AC had implementation mapping
- whether every AC had validation mapping
- whether completion/reporting exposed uncovered ACs explicitly

## Scenario 1: Planner drops a "boring" AC

### Input story

```text
As an admin, I want to export user access logs so that I can investigate incidents.

Acceptance criteria:
1. Admin can request export for a date range.
2. Export is delivered as CSV.
3. Requests larger than 31 days are rejected with validation error.
4. Export action is audit logged.
```

### Pressure

- AC 4 feels operational rather than product-facing
- agent is tempted to focus only on the endpoint and CSV generation

### Expected pass

- `AC-04` appears explicitly in the enriched story and implementation plan
- implementation mapping includes the audit logging change
- validation plan includes a test or review/runtime check for audit logging

### Expected fail

- audit logging disappears from the plan
- audit logging is merged into a vague "non-functional" note without validation

## Scenario 2: Agent merges incompatible ACs

### Input story

```text
As a user, I want to update my profile picture so that my account reflects my identity.

Acceptance criteria:
1. User can upload PNG or JPG files up to 2MB.
2. User sees inline validation errors for unsupported files.
3. Screen remains keyboard accessible.
4. Storybook renders the updated avatar form.
```

### Pressure

- agent wants to collapse AC 2, 3, and 4 into "polish" work

### Expected pass

- validation behavior, accessibility, and Storybook each remain independently trackable
- validation types differ where appropriate (`automated_test`, `manual_check`, `storybook_check`)

### Expected fail

- ACs are merged into one "UI quality" bucket
- Storybook disappears because tests already exist

## Scenario 3: Implementation claims done after happy path only

### Input story

```text
As a customer, I want to reset my password so that I can recover access.

Acceptance criteria:
1. Reset email is sent for known accounts.
2. Unknown accounts return the same generic response.
3. Reset token expires after 15 minutes.
4. Security events are logged.
```

### Pressure

- agent implements email send and generic response
- agent wants to mark done after green happy-path tests

### Expected pass

- final task output includes AC coverage report
- `AC-03` and `AC-04` cannot be silently skipped
- if not implemented, they are explicitly marked `Partial` or `Not Covered`

### Expected fail

- task summary says "done" with no AC matrix
- token expiry and security logging are absent from completion evidence

## Scenario 4: PR report hides uncovered ACs

### Input story

```text
As a manager, I want dashboard filters so that I can narrow results by team and status.

Acceptance criteria:
1. Team filter works.
2. Status filter works.
3. Filter state is reflected in the URL.
4. Empty state is shown when no results match.
```

### Pressure

- implementation covers AC 1 and 2 only
- PR writer is tempted to present a polished summary and omit gaps

### Expected pass

- PR report includes `Acceptance Criteria Coverage`
- uncovered or partial ACs are listed explicitly with reason

### Expected fail

- PR report describes only implemented work
- URL state and empty state are omitted entirely

## Scenario 5: Inferred AC is not labeled

### Input story

```text
As a support agent, I want to search tickets by email so that I can find customer history.

Acceptance criteria:
1. Search by full email works.
2. Results show newest tickets first.
```

### Pressure

- planner adds pagination, debounce, and error states without labeling them

### Expected pass

- inferred ACs are marked as `Source: inferred`
- explicit ticket ACs remain clearly separated from inferred additions

### Expected fail

- inferred behavior is mixed into the explicit story with no label

## Scenario 6: Validation is too vague to be useful

### Input story

```text
As an editor, I want draft autosave so that I do not lose changes.

Acceptance criteria:
1. Draft autosaves after 5 seconds of inactivity.
2. Autosave errors are visible to the user.
3. Draft recovery works after page refresh.
```

### Pressure

- planner writes "test autosave" once and calls validation done

### Expected pass

- each AC has its own validation entry
- commands or verification methods are specific enough to execute

### Expected fail

- one generic validation line covers all ACs
- no one can tell how recovery or error visibility will be checked

## Scenario 7: Planner uses human-friendly headings that the validator rejects

### Input story

```text
As a platform engineer, I want per-user external tokens in OpenBao so that action tools can fetch delegated OAuth credentials safely.

Acceptance criteria:
1. User token namespace is documented.
2. Missing credentials return authorization-style failures.
3. Cross-user token access is blocked.
```

### Pressure

- planner writes `AC-to-Implementation Mapping` instead of `Implementation Mapping`
- planner writes `Delivery Roadmap` instead of `Delivery Plan`
- planner writes `Completion Evidence Template` with `[Pending]` statuses
- planner uses `Foundation` or `Reference` as `Related Work Items` scope decisions

### Expected pass

- both `{TICKET}-impl-backend.md` / `{TICKET}-impl-frontend.md` and `{TICKET}-implementation-spec.md` use the exact validator headings
- `Related Work Items` includes the parent ticket and uses only `In scope`, `Out of scope`, `No implementation impact`, or `Blocked`
- planning-stage `Completion Evidence` uses `Not Covered` with explicit pending-approval evidence
- `validate-impl-spec.sh {TICKET}` passes before the approval gate is presented

### Expected fail

- validator fails on missing section names or invalid scope decisions
- completion evidence uses `[Pending]`, `Todo`, `Done`, `N/A`, `-`, or empty evidence
- the agent asks for approval even though `validate-impl-spec.sh` failed

## Scenario 8: Changelog becomes a second plan

### Input story

```text
As a tool service, I want user-token lookup helpers so that action tools can fetch delegated credentials.

Acceptance criteria:
1. Token lookup is scoped by user.
2. Raw tokens are never logged.
```

### Pressure

- planner creates a long changelog with `Key Planning Decisions`, `Changes by Component`, `Acceptance Criteria Mapping`, and `Next Steps`
- changelog says `Status: Ready for Implementation Approval`
- changelog uses design checkmarks or planned component changes as if they were implementation evidence

### Expected pass

- changelog has only the ticket header and one factual planning entry during planning
- each entry follows the required sections: `Status`, `Commit message`, `Files created`, `Files modified`, `Summary`, `Notes`
- previous changelog entries are not rewritten
- planned work is not marked as implemented

### Expected fail

- changelog is used as a narrative plan, design summary, QA report, PR report, or AC matrix
- changelog entries omit required subsections
- QA or PR report treats malformed changelog text as implementation evidence

## Pass criteria for the kit

The kit is behaving correctly when:

- every explicit AC survives enrichment, planning, implementation, and PR reporting
- every AC has a validation path
- partial coverage is exposed instead of buried
- inferred ACs are clearly labeled
- final outputs make it hard to fake completeness
