# Release It!: Mini

## When to use

Use for services, APIs, queues, jobs, integrations, and critical paths that
must survive production failure, overload, deployment, and recovery scenarios.

## Primary bias to correct

A passing happy path is not a production-ready design.

## Decision rules

- Assume every dependency can fail, stall, throttle, or return malformed data.
- Put explicit timeouts on network and external calls.
- Retry only when duplicate execution is safe, and bound retries with backoff or jitter.
- Prevent retry storms and cascading failure with circuit breakers, bulkheads, and fast failure where appropriate.
- Define overload behavior with backpressure, queue limits, admission control, rate limiting, or load shedding.
- Protect state with idempotency and protect resources with validation, quotas, and limits.
- Make logs, metrics, and traces sufficient to diagnose degradation, overload, and partial outage.
- Design startup, deployment, caches, APIs, and jobs to fail safely and recover predictably.

## Trigger rules

- When adding an external call, choose timeout, retry, fallback, and failure propagation deliberately.
- When adding a queue or async job, define capacity, duplicate safety, and failure handling.
- When adding a cache, decide miss, stampede, staleness, and invalidation behavior.
- When adding a critical endpoint or path, define overload behavior before traffic does.

## Final checklist

- Are timeouts explicit?
- Are retries duplicate-safe and bounded?
- Is dependency failure isolated?
- Is overload behavior explicit?
- Is the path observable under stress?

## Enforcement Contract

| Check ID | Required When Selected | Evidence Keywords | Applies To |
|---|---|---|---|
| REL-01 | Dependency failure, stall, or timeout is in scope | timeout, failure, fallback | Validation Plan, QA |
| REL-02 | Retry, duplicate execution, or queue redelivery is in scope | retry, duplicate safety, idempotency, backoff | Validation Plan, QA, Review |
| REL-03 | Overload, capacity, or production diagnostics are in scope | overload, backpressure, observability, metric, circuit breaker | Review, PR |

## Source and Attribution

Adapted for `kathy-sdd-kit` from
[ciembor/agent-rules-books release-it](https://github.com/ciembor/agent-rules-books/tree/main/release-it),
MIT licensed. Inspired by Release It! concepts.
