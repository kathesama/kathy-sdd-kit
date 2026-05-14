---
name: consume-api-contract
description: Use when planning or implementing frontend/UI screens, API clients, data fetching, mocked flows, permissions, or capability-gated UI in a repository that has docs/api-contract.md, contracts/api/capabilities.json, contracts/api/openapi, or contracts/api/api-contract-source.json.
---

# Skill: Consume API Contract

## Purpose

Use the UI repository's copied API contract artifacts as the only source of
truth for backend capabilities. Prevent agents from inventing endpoints,
payloads, status codes, auth rules, permissions, feature flags, or response
fields while building frontend work.

## Contract Sources

Look for sources in this order:

1. `contracts/api/api-contract-source.json`
2. `docs/api-contract.md`
3. `contracts/api/capabilities.json`
4. `contracts/api/openapi/**`

If `api-contract-source.json` exists, read it first to identify generated
contract artifacts and the API source repository. Treat generated artifacts as
read-only in the UI repository.

## Workflow

1. Before planning or implementing API-consuming UI, inspect `Contract Sources`.
2. Read the smallest contract files needed for the requested screens, routes,
   hooks, forms, permissions, and states.
3. Map each UI action or data dependency to documented contract evidence:
   method, route, request fields, response fields, status/error states, auth,
   capability flag, or documented absence.
4. If a required behavior is missing from the contract, record a contract gap
   or blocker. Do not create an undocumented route, field, status, or
   capability name.
5. If the API contract itself must change, stop UI implementation for that
   behavior until the API source is updated and `api-contract-sync` has
   refreshed the UI copy.

## Planning Requirements

For frontend implementation specs, add API evidence to `Execution Notes for
Implementer` when the ticket touches server state, auth, permissions, forms,
or backend-backed views:

- `API Contract Source`: files read
- `API Usage Map`: UI behavior to endpoint/capability evidence
- `Contract Gaps`: missing or ambiguous backend behavior
- `Out Of Scope`: backend contract changes not implemented in UI

## Implementation Rules

- API clients, hooks, schemas, and mocks must match documented request and
  response shapes.
- Do not use `any` or invented optional fields to bypass missing contract
  detail.
- Loading, empty, error, permission, and disabled states must come from the
  documented statuses or capability rules.
- When backend services are unavailable locally, mock at the documented
  contract boundary rather than inventing alternate behavior.
- Do not edit generated contract files in the UI repository. Update the API
  source and rerun `api-contract-sync`.

## Common Mistakes

- Creating a route because it is convenient but not documented.
- Treating copied UI contract files as editable source.
- Adding UI states for permissions or feature flags that the contract does not
  define.
- Using mock payloads with fields absent from the contract.
- Assuming service-to-service endpoints are public UI endpoints.
