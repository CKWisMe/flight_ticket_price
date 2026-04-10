# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]
**Input**: Feature specification from `/specs/[###-feature-name]/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See
`.specify/templates/plan-template.md` for the execution workflow.

## Summary

[Extract from feature spec: primary requirement + technical approach from research]

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: [e.g., Ruby 4.0.1 or NEEDS CLARIFICATION]
**Primary Dependencies**: [e.g., Rails 8.1.3, Hotwire or NEEDS CLARIFICATION]
**Storage**: [e.g., Rails-managed SQLite, PostgreSQL via Active Record, or N/A]
**Testing**: [e.g., `bin/rails test`, system tests, or NEEDS CLARIFICATION]
**Target Platform**: [e.g., Linux server, Windows dev environment, or NEEDS CLARIFICATION]
**Project Type**: [e.g., Rails web app or NEEDS CLARIFICATION]
**Performance Goals**: [domain-specific targets]
**Constraints**: [e.g., p95 < 200 ms, WCAG 2.1 AA, no PII logging]
**Scale/Scope**: [domain-specific scope]

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- Simplicity: Explain the simplest viable design and list any required
  complexity exceptions.
- Reuse: Identify existing services, repositories, helpers, or utilities that
  were reviewed before introducing new logic.
- Tests: Define the automated tests that will be added for each feature or logic
  change.
- Architecture: Show how the design preserves `Route -> Service -> Repository`
  boundaries.
- Security and Privacy: Record PII handling, secret management, and cloud
  identity assumptions.
- Accessibility: For UI changes, describe how WCAG 2.1 AA compliance will be
  verified.
- Performance: State the latency budget and how the design avoids violating the
  p95 < 200 ms target for API-facing work.
- Dependencies: Justify each new dependency and confirm current maintenance
  status.

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
|-- plan.md
|-- research.md
|-- data-model.md
|-- quickstart.md
|-- contracts/
`-- tasks.md
```

### Source Code (repository root)
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths. The delivered plan must not include Option labels.
-->

```text
# [REMOVE IF UNUSED] Option 1: Rails web application (DEFAULT)
app/
|-- controllers/
|-- services/
|-- repositories/
|-- models/
`-- views/

config/
db/
lib/

test/
|-- integration/
|-- models/
|-- services/
`-- repositories/

# [REMOVE IF UNUSED] Option 2: Split frontend/backend
backend/
frontend/
```

**Structure Decision**: [Document the selected structure and reference the real
directories captured above]

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., extra abstraction layer] | [current need] | [why direct design is insufficient] |
| [e.g., repository layer] | [specific persistence boundary] | [why model-only persistence access is insufficient] |
