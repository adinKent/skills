# Grill to Implement (`/grill-with-docs` -> `/to-spec` -> `/to-tickets` -> `/implement-spec`)

An end-to-end engineering pipeline skill that combines four stages into a single workflow:

1. **`/grill-with-docs` (Interactive)**: Interviews you to resolve design decisions, edge cases, and domain terminology (updating ADRs/glossary as needed).
2. **`/to-spec` (Autonomous)**: Synthesizes the conversation into a complete specification (`.scratch/<feature-slug>/spec.md` when no issue tracker is configured) without pausing to ask about testing seams.
3. **`/to-tickets` (Autonomous)**: Breaks the spec into tracer-bullet vertical-slice tickets with blocking edges (`.scratch/<feature-slug>/issues/<NN>-<slug>.md` when no issue tracker is configured) without pausing for breakdown approval.
4. **`/implement-spec` (Autonomous)**: Implements all tickets in dependency order using TDD (`tdd`) and runs a final `code-review`, fixing any findings until all tests pass.

## Key Rules

- **Human interaction happens ONLY in Stage 1 (`grill-with-docs`)**. Once grilling finishes, Stages 2–4 run automatically to completion.
- **Local `.md` fallback**: When no external issue tracker is configured, spec and ticket `.md` files are written under `.scratch/<feature-slug>/` and are **never staged or committed to git**.

