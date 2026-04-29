# ER-200 Engineering Rule Pack Traceability Example

## ER-200: Add replay-safe event consumer fixture
**Status:** Done
**Commit message:** ER-200 test(sdd): add engineering rule traceability fixture
### Files created
### Files modified
### Summary
- Added a valid fixture that selects `data-intensive.mini.md` and `release-it.mini.md`.
### Notes
- Validation: `pytest tests/test_event_consumer.py` passed for replay, idempotency, timeout, and retry scenarios.
---
