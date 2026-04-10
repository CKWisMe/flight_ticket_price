<!--
Sync Impact Report
- Version change: 1.3.0 -> 1.4.0
- Modified principles:
  - VI. zh-TW Documentation Standard -> VI. zh-TW Documentation and Analysis Standard
- Added sections:
  - None
- Removed sections:
  - None
- Templates requiring updates:
  - updated: .specify/templates/plan-template.md
  - updated: .specify/templates/spec-template.md
  - updated: .specify/templates/tasks-template.md
  - updated: README.md
  - updated: AGENTS.md
  - pending: .specify/templates/commands/*.md (directory not present in this repo)
- Follow-up TODOs:
  - None
-->
# Flight Ticket Price Constitution

## Core Principles

### I. Simplicity Over Cleverness
Code MUST optimize for readability, directness, and low cognitive load. Deep
inheritance, metaprogramming, speculative abstractions, and pattern-heavy
designs MUST NOT be introduced unless the current implementation complexity
demands them and that need is documented in the implementation plan.

Rationale: Simple code is easier to review, test, delete, and replace.

### II. Reuse Before Rebuild
Before adding new business logic, helpers, or infrastructure, the agent MUST
inspect existing services, models, repositories, helpers, and utility folders
for equivalent behavior. Duplicate logic or near-duplicate helpers are
violations unless an implementation plan records why reuse is unsafe.

Rationale: A single source of truth reduces maintenance cost and behavioral
drift.

### III. Test-First Delivery
Every feature and every logic change MUST have an associated automated test
file. Logic changes SHOULD begin with a failing test that captures the expected
behavior before implementation. A task list that omits required tests is not
constitutionally complete.

Rationale: Test-first work provides executable proof of behavior and limits
regressions.

### IV. Layered Service Architecture
Business logic MUST follow a `Route -> Service -> Repository` flow. Route
handlers MUST coordinate request and response concerns only. Domain rules MUST
reside in services. Persistence access MUST be isolated behind repository
objects or equivalent persistence boundaries. Database models MUST NOT become
the primary home for business workflows.

Rationale: Strict separation of concerns keeps the application testable and
deletable.

### V. Security and Accessibility by Default
PII MUST NOT be logged or stored in plain text. Secrets MUST NOT be hardcoded.
Managed identity or equivalent platform-native secretless access MUST be used
for cloud resources when available. User-facing UI work MUST meet WCAG 2.1 AA
accessibility requirements.

Rationale: Security and accessibility are release criteria, not optional
hardening work.

### VI. zh-TW Documentation and Analysis Standard
All generated specification artifacts and analysis outputs MUST be written in
Traditional Chinese for Taiwan (`zh-TW`). This requirement applies to
`spec.md`, `plan.md`, `tasks.md`, `research.md`, `data-model.md`,
`quickstart.md`, `/speckit.analyze` reports, remediation suggestions, and
equivalent Markdown or chat-form workflow outputs produced by Spec Kit.
English MAY appear only for code, commands, protocol fields, or external proper
nouns that would lose precision if translated.

Rationale: A single mandated document language prevents mixed-language project
artifacts and keeps planning, review, and delivery communication consistent.

## Technical Constraints

- Runtime stack MUST align with the live repository: Ruby 4.0.1 and Rails
  8.1.3.
- Persistence choices in specifications and plans MUST match the implemented
  stack unless an ADR approves a migration. The current repository uses
  Rails-managed SQLite storage; any move to PostgreSQL or a non-Rails ORM MUST
  be treated as a governed architecture change.
- API-facing work MUST target p95 latency below 200 ms unless a feature spec
  documents a stricter budget.
- New dependencies MAY be introduced only when they are actively maintained and
  updated within the last 6 months at the time of adoption, and the adoption
  rationale MUST be recorded in the plan.
- Generated Markdown deliverables under `specs/` and Spec Kit analysis outputs
  MUST remain in `zh-TW`, including headings, narrative text, acceptance
  scenarios, task descriptions, findings, recommendations, and remediation
  guidance.

## Quality and Delivery Standards

- KISS and DRY are mandatory review gates. Solutions MUST solve the current
  problem without speculative extension points.
- Excessive interface layers, Strategy/Visitor/Factory patterns, or other
  indirection-heavy designs MUST NOT be introduced for single implementations
  without written justification in the plan's complexity tracking section.
- Feature plans, specs, and tasks MUST explicitly cover architecture
  boundaries, required tests, performance constraints, security/privacy impact,
  and accessibility impact when UI is affected.
- Reviews for generated Markdown artifacts and analysis reports MUST reject
  mixed-language prose when the content is expected to be authored in `zh-TW`.
- Compliance with this constitution MUST be reviewed on every pull request, and
  `/speckit.analyze` SHOULD be run to detect cross-artifact violations before
  merge.

## Governance

This constitution supersedes conflicting local conventions for design,
implementation, and review. Amendments are versioned using Semantic Versioning:
MAJOR for incompatible governance or principle changes, MINOR for new guidance
or materially expanded requirements, and PATCH for clarifications that preserve
existing intent.

Any change to a `MUST` principle requires an ADR and approval from the Lead
Architect before implementation artifacts are updated. Pull requests MUST verify
constitutional compliance, including testing obligations, architecture
boundaries, privacy/security rules, dependency due diligence, and `zh-TW`
artifact requirements.

**Version**: 1.4.0 | **Ratified**: 2026-04-11 | **Last Amended**: 2026-04-11
