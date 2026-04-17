# Ticket Tracker Policy

`{TICKET}` is the canonical work-item key used by the consuming project. The kit
does not hardcode Jira, Linear, GitHub, Salesforce, or any other provider.

## Default Rule

`{TICKET}` must be:

- stable
- unique within the consuming project
- filesystem-safe
- used consistently in `.ai-specs/changes/{TICKET}/`

Allowed examples:

- `JAP-160`
- `ENG-123`
- `GH-42`
- `SF-1024`
- `ADO-345`
- `160`
- `task-160`

Rejected examples:

- `../JAP-160`
- `JAP/160`
- `implement memory reindex`
- empty values

## Common Tracker Examples

| Tracker | Example `{TICKET}` | Notes |
|---|---|---|
| Jira | `JAP-160` | Project key plus issue number. Numeric shorthand can be expanded by project policy. |
| Linear | `ENG-123` | Team key plus issue number. |
| GitHub Issues | `GH-42` or `42` | Choose a project convention and keep it stable. |
| Azure DevOps | `ADO-345` or `345` | Use a prefix if multiple trackers may overlap. |
| Salesforce work items | `SF-1024` | Use the stable external work item key, not the title. |
| Shortcut | `SC-987` | Prefix recommended for filesystem clarity. |
| YouTrack | `PROJ-456` | Similar to Jira-style keys. |
| Asana | `ASANA-12345` | Use a stable task ID or project-specific alias. |
| Trello | `TRELLO-abc123` | Use a stable card ID or project-specific alias. |
| Internal tracker | `TASK-160` or `160` | Numeric-only is allowed when the project policy is unambiguous. |

## Project Override

Consuming projects may define a stricter policy in root `AGENTS.md`,
`CLAUDE.md`, or project docs.

Example:

```md
## Project Ticket Policy

For this repository, `{TICKET}` must be the Jira issue key, e.g. `JAP-160`.
If the user says "task 160", resolve it to `JAP-160` before creating artifacts.
```

The kit default stays provider-agnostic; project overrides define provider
specific behavior.
