# Feature Specification: [FEATURE NAME]

**Feature Branch**: `[###-feature-name]`
**Created**: [DATE]
**Status**: Draft
**Input**: User description: "$ARGUMENTS"

## User Scenarios & Testing *(mandatory)*

<!--
  IMPORTANT: User stories should be PRIORITIZED as user journeys ordered by importance.
  Each user story/journey must be INDEPENDENTLY TESTABLE - meaning if you implement just ONE of them,
  you should still have a viable MVP (Minimum Viable Product) that delivers value.

  Assign priorities (P1, P2, P3, etc.) to each story, where P1 is the most critical.
  Think of each story as a standalone slice of functionality that can be:
  - Developed independently
  - Tested independently
  - Deployed independently
  - Demonstrated to users independently
-->

### User Story 1 - [Brief Title] (Priority: P1)

[Describe this user journey in plain language]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected outcome]
2. **Given** [initial state], **When** [action], **Then** [expected outcome]

---

### User Story 2 - [Brief Title] (Priority: P2)

[Describe this user journey in plain language]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected outcome]

---

### User Story 3 - [Brief Title] (Priority: P3)

[Describe this user journey in plain language]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected outcome]

---

[Add more user stories as needed, each with an assigned priority]

### Edge Cases

- What happens when [boundary condition]?
- How does system handle [error scenario]?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST [specific capability]
- **FR-002**: System MUST [specific capability]
- **FR-003**: Users MUST be able to [key interaction]
- **FR-004**: System MUST [data requirement]
- **FR-005**: System MUST [behavior]
- **FR-006**: System MUST identify which existing services, repositories,
  helpers, or utilities are reused and where new logic is unavoidable.
- **FR-007**: System MUST specify the automated tests required for the feature,
  including the expected failing behavior that proves the need for the change.
- **FR-008**: System MUST keep business logic out of route handlers and models by
  defining the service and repository responsibilities.
- **FR-009**: System MUST define privacy and security handling for secrets, PII,
  and external resource access.
- **FR-010**: UI-facing work MUST define accessibility expectations sufficient to
  verify WCAG 2.1 AA compliance.

*Example of marking unclear requirements:*

- **FR-011**: System MUST authenticate users via [NEEDS CLARIFICATION: auth
  method not specified - email/password, SSO, OAuth?]
- **FR-012**: System MUST retain user data for [NEEDS CLARIFICATION: retention
  period not specified]

### Key Entities *(include if feature involves data)*

- **[Entity 1]**: [What it represents, key attributes without implementation]
- **[Entity 2]**: [What it represents, relationships to other entities]

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: [Measurable metric]
- **SC-002**: [Measurable metric]
- **SC-003**: [User satisfaction metric]
- **SC-004**: [Business metric]
- **SC-005**: [Performance metric, e.g., API p95 latency remains below 200 ms]

## Constitutional Alignment *(mandatory)*

- **Simplicity**: [Why this design is the simplest viable approach]
- **Reuse**: [Existing code reviewed and reused before adding new logic]
- **Testing**: [Required automated tests and expected failing behavior]
- **Architecture**: [How the feature preserves `Route -> Service -> Repository`]
- **Security/Privacy**: [PII handling, secret management, identity assumptions]
- **Accessibility**: [Required only when UI is affected; otherwise state N/A]
- **Dependencies**: [New dependencies or explicit statement that none are added]

## Assumptions

- [Assumption about target users]
- [Assumption about scope boundaries]
- [Assumption about data/environment]
- [Dependency on existing system/service]
