# 功能規格：[FEATURE NAME]

**Feature Branch**: `[###-feature-name]`
**Created**: [DATE]
**Status**: Draft
**Input**: 使用者描述：「$ARGUMENTS」

> 本文件與同功能下的 `plan.md`、`tasks.md`、`research.md`、`data-model.md`、
> `quickstart.md` 等 Markdown 產物，敘述文字皆必須以 `zh-TW` 撰寫；
> 程式碼、命令、協定欄位與必要專有名詞可保留英文。

## 使用者情境與測試 *(mandatory)*

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

### 邊界情況

- What happens when [boundary condition]?
- How does system handle [error scenario]?

## 需求 *(mandatory)*

### 功能需求

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
- **FR-011**: System MUST produce all generated Markdown planning and
  specification artifacts, analysis reports, and remediation summaries in
  `zh-TW`, except where English is required for code, commands, protocol
  fields, or necessary proper nouns.

*不明需求的標示範例：*

- **FR-012**: System MUST authenticate users via [NEEDS CLARIFICATION: auth
  method not specified - email/password, SSO, OAuth?]
- **FR-013**: System MUST retain user data for [NEEDS CLARIFICATION: retention
  period not specified]

### 關鍵實體 *(若功能涉及資料則必填)*

- **[Entity 1]**: [What it represents, key attributes without implementation]
- **[Entity 2]**: [What it represents, relationships to other entities]

## 成功準則 *(mandatory)*

### 可衡量結果

- **SC-001**: [Measurable metric]
- **SC-002**: [Measurable metric]
- **SC-003**: [User satisfaction metric]
- **SC-004**: [Business metric]
- **SC-005**: [Performance metric, e.g., API p95 latency remains below 200 ms]

## 憲章一致性 *(mandatory)*

- **Simplicity**: [Why this design is the simplest viable approach]
- **Reuse**: [Existing code reviewed and reused before adding new logic]
- **Testing**: [Required automated tests and expected failing behavior]
- **Architecture**: [How the feature preserves `Route -> Service -> Repository`]
- **Security/Privacy**: [PII handling, secret management, identity assumptions]
- **Accessibility**: [Required only when UI is affected; otherwise state N/A]
- **Dependencies**: [New dependencies or explicit statement that none are added]
- **Documentation Language**: [說明本功能相關 Markdown 產物如何維持 `zh-TW`]

## 假設

- [Assumption about target users]
- [Assumption about scope boundaries]
- [Assumption about data/environment]
- [Dependency on existing system/service]
