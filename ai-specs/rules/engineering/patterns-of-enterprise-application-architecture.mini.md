# Patterns of Enterprise Application Architecture: Mini

## When to use

Use when a ticket needs explicit choices about business logic style,
persistence, transaction boundaries, DTOs, remote boundaries, or integration
patterns in an enterprise application.

## Primary bias to correct

Do not apply one enterprise pattern everywhere just because it is familiar.

## Decision rules

- Choose the business logic pattern by complexity: transaction script for simple flows, domain model for rich behavior.
- Keep controllers, message handlers, and jobs thin; put workflow in a service layer or use-case layer.
- Use DTOs and remote facades for expensive or unstable boundaries where coarse contracts beat chatty coupling.
- Match persistence style to separation needs; repositories are useful when they hide meaningful persistence complexity.
- Use Unit of Work, Identity Map, lazy loading, and locking deliberately, not as invisible framework magic.
- Make transaction boundaries and conflict strategy explicit where consistency or contention matters.
- Treat remote calls as distributed boundaries, not local calls with slower syntax.

## Trigger rules

- When adding a repository, ask whether it hides complexity or only restates the ORM.
- When a simple flow accumulates business rules, revisit whether transaction script is still enough.
- When remote calls become chatty, redesign the boundary around a coarse-grained contract.
- When duplicate updates or contention matter, choose an explicit lock or conflict strategy.

## Final checklist

- Is the business logic pattern appropriate for domain complexity?
- Is the persistence pattern appropriate for the separation need?
- Is the transaction boundary explicit?
- Is each remote boundary coarse and intentional?

## Source and Attribution

Adapted for `kathy-sdd-kit` from
[ciembor/agent-rules-books patterns-of-enterprise-application-architecture](https://github.com/ciembor/agent-rules-books/tree/main/patterns-of-enterprise-application-architecture),
MIT licensed. Inspired by Patterns of Enterprise Application Architecture concepts.
