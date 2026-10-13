# Engineering Quality Contract

Review applicable principles explicitly, with source evidence or a reason for
non-applicability. These are design questions, not requirements to add layers.

| Principle | Review question |
|---|---|
| SRP | Does this unit have one coherent reason to change? |
| OCP | Can a demonstrated variation be added without destabilizing existing behavior? |
| LSP | Do substitutes preserve caller expectations and failure contracts? |
| ISP | Do clients depend only on operations they need? |
| DIP | Does policy remain independent of filesystem, process and transport details? |

Preserve existing hexagonal boundaries, contracts, security, accessibility and
error handling. Prefer pure functions plus a callable dependency over speculative
interface hierarchies. Use the selected engineering rule packs and complexity
review; do not load every optional pack by default.

Coverage defaults: 80% minimum, 90% target. Stricter project or ticket requirements
win. Record line and branch metrics separately where supported. This harness
upgrade requires at least 90% of both for its new Python package. Coverage does
not establish AC correctness or a test-first sequence.
