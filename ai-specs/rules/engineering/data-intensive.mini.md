# Designing Data-Intensive Applications: Mini

## When to use

Use when correctness depends on data ownership, consistency, event flow,
retries, replay, schema evolution, derived views, caches, or partitioning.

## Primary bias to correct

Do not let storage, messaging, retries, or caches hide correctness assumptions.

## Decision rules

- Give every business fact one clear owner and source of truth.
- Make consistency explicit per write path.
- Protect immediate invariants in one local transaction or aggregate by default.
- Document where staleness, reconciliation, or eventual consistency is acceptable.
- Require idempotency and replay safety for retried, queued, or event-driven writes.
- Preserve ordering only where the product needs it, and encode that contract with keys, versions, sequence rules, or partition ownership.
- Treat events, streams, and APIs as versioned contracts.
- Treat caches, indexes, search views, and projections as derived data that can lag and must be rebuildable.
- Partition around locality and access patterns; make cross-partition coordination explicit.

## Trigger rules

- When touching a write path, state source of truth, consistency boundary, and failure semantics.
- When adding retries, jobs, or consumers, prove duplicate delivery and replay are safe.
- When changing a schema or event, define how old readers, new writers, and rebuild paths coexist.
- When one business fact is written in multiple places, define the coordination contract or collapse to one authoritative write.

## Final checklist

- Is there one clear owner per fact?
- Are consistency and staleness semantics explicit?
- Is the path safe under retry, replay, and duplicate delivery?
- Are secondary views rebuildable?

## Source and Attribution

Adapted for `kathy-sdd-kit` from
[ciembor/agent-rules-books designing-data-intensive-applications](https://github.com/ciembor/agent-rules-books/tree/main/designing-data-intensive-applications),
MIT licensed. Inspired by Designing Data-Intensive Applications concepts.
