---

description: "Task list template for feature implementation"
---

# Tasks: [FEATURE NAME]

**Input**: 來自 `/specs/[###-feature-name]/` 的設計文件
**Prerequisites**: plan.md (required), spec.md (required for user stories),
research.md, data-model.md, contracts/

**Tests**: 每個功能與每次邏輯變更都 REQUIRED 自動化測試。每個使用者故事都
MUST 包含足以證明行為的測試工作。

**Organization**: 任務依使用者故事分組，讓每個故事都能獨立實作與驗證。

**Language Rule**: 產出的 `tasks.md` 敘述文字必須以 `zh-TW` 撰寫；程式碼、
命令、協定欄位與必要專有名詞可保留英文。

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Rails app**: `app/`, `config/`, `db/`, `test/` at repository root
- **Split app**: adapt paths to the structure selected in `plan.md`

<!--
  IMPORTANT: 下方任務僅為示意範例。
  /speckit.tasks 指令 MUST 依據實際功能產物將其完全替換。
-->

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: 專案初始化與基本結構

- [ ] T001 Create project structure per implementation plan
- [ ] T002 Initialize framework dependencies and runtime configuration
- [ ] T003 [P] Configure linting, formatting, and test execution tools
- [ ] T004 [P] Review existing services, repositories, helpers, and utilities to
  prevent duplicate logic
- [ ] T005 [P] Confirm generated Markdown deliverables for this feature are
  authored in `zh-TW`, including analysis findings and remediation summaries

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: 在任何使用者故事開始前都 MUST 完成的核心基礎建設

- [ ] T006 Setup database schema and migrations framework
- [ ] T007 [P] Implement authentication and authorization framework
- [ ] T008 [P] Setup routing and middleware structure
- [ ] T009 Create base models or entities that all stories depend on
- [ ] T010 Create service and repository base structure for business and
  persistence logic
- [ ] T011 Configure error handling and logging infrastructure without exposing
  PII
- [ ] T012 Setup environment configuration and secret management

**Checkpoint**: Foundation ready. User story implementation can now begin.

---

## Phase 3: User Story 1 - [Title] (Priority: P1)

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 1

> **NOTE: Write these tests FIRST and ensure they FAIL before implementation**

- [ ] T013 [P] [US1] Add automated test coverage for the story and capture the
  failing expectation first
- [ ] T014 [P] [US1] Add integration coverage for the user journey when the
  story crosses boundaries

### Implementation for User Story 1

- [ ] T015 [P] [US1] Create or update entities required by the story
- [ ] T016 [US1] Implement service logic for the story
- [ ] T017 [US1] Implement repository or persistence boundary changes required by
  the story
- [ ] T018 [US1] Implement route or UI integration without moving business logic
  into handlers
- [ ] T019 [US1] Add validation, privacy-safe logging, error handling, and
  zh-TW documentation updates required by the story

**Checkpoint**: User Story 1 is fully functional and independently testable.

---

## Phase 4: User Story 2 - [Title] (Priority: P2)

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 2

- [ ] T020 [P] [US2] Add automated test coverage for the story and capture the
  failing expectation first
- [ ] T021 [P] [US2] Add integration coverage for the user journey when the
  story crosses boundaries

### Implementation for User Story 2

- [ ] T022 [P] [US2] Create or update entities required by the story
- [ ] T023 [US2] Implement service logic for the story
- [ ] T024 [US2] Implement repository or persistence boundary changes required by
  the story
- [ ] T025 [US2] Implement route or UI integration with preserved architecture

**Checkpoint**: User Stories 1 and 2 both work independently.

---

## Phase 5: User Story 3 - [Title] (Priority: P3)

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 3

- [ ] T026 [P] [US3] Add automated test coverage for the story and capture the
  failing expectation first
- [ ] T027 [P] [US3] Add integration coverage for the user journey when the
  story crosses boundaries

### Implementation for User Story 3

- [ ] T028 [P] [US3] Create or update entities required by the story
- [ ] T029 [US3] Implement service logic for the story
- [ ] T030 [US3] Implement repository or persistence boundary changes required by
  the story
- [ ] T031 [US3] Implement route or UI integration with preserved architecture

**Checkpoint**: All user stories are independently functional.

---

## Phase N: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] TXXX [P] Documentation updates in docs/
- [ ] TXXX Code cleanup and refactoring
- [ ] TXXX Performance optimization across affected stories
- [ ] TXXX [P] Additional automated tests for edge cases and regressions
- [ ] TXXX Security hardening
- [ ] TXXX Accessibility validation for UI changes
- [ ] TXXX Validate `quickstart.md` in `zh-TW`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies
- **Foundational (Phase 2)**: Depends on Setup completion and blocks all stories
- **User Stories (Phase 3+)**: Depend on Foundational completion
- **Polish (Final Phase)**: Depends on all desired stories being complete

### Within Each User Story

- Tests MUST be written and FAIL before implementation
- Models or entities before services
- Services before routes, controllers, or UI handlers
- Repository changes before route integration when persistence behavior changes
- Core implementation before integration

### Parallel Opportunities

- Setup tasks marked `[P]` can run in parallel
- Foundational tasks marked `[P]` can run in parallel
- Story-level tests marked `[P]` can run in parallel
- Different user stories can run in parallel after Foundational completes

## Notes

- Reuse existing code before introducing new helpers or services
- Keep business logic out of route handlers and models
- Do not log PII or hardcode secrets
- Each user story should be independently completable and testable
- Generated Markdown planning artifacts must remain in `zh-TW`
- Analysis findings and remediation summaries must remain in `zh-TW`
