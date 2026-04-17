# Review Fix Pattern Example

Use this pattern when QA or code review finds gaps after implementation.

## Rule

Do not patch review findings as untracked side work. Convert each accepted
finding into:

- a new AC or review-fix criterion
- implementation mapping
- validation plan
- delivery plan step
- completion evidence
- changelog entry

## Example

| Finding | Added Criterion | Validation |
|---|---|---|
| Missing batch integrity check | `AC-09` Reindex verifies each processed batch before progress recording | `test_reindex_service_fails_job_when_batch_integrity_check_fails` |
| Malformed event blocks consumer | `AC-10` Malformed events do not block the consumer indefinitely | consumer bad-message tests |
| Completed replay mutates audit metadata | `AC-11` Completed event replay does not mutate audit metadata | repository replay SQL test |

After updating the plan/spec, run:

```bash
sh .sdd-kit/tools/validate-impl-spec.sh {TICKET}
```

Then stop for `approve`, `change`, or `deny` before implementing review fixes.
