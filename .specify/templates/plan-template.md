# 實作計畫：[FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]
**Input**: 來自 `/specs/[###-feature-name]/spec.md` 的功能規格

**Note**: 此模板由 `/speckit.plan` 指令填入。產出的 Markdown 內容必須以
`zh-TW` 撰寫；程式碼、命令、協定欄位與無法精確翻譯的專有名詞可保留英文。
執行流程請參考 `.specify/templates/plan-template.md`。

## 摘要

[從功能規格擷取：主要需求 + research 中採用的技術做法]

## 技術背景

<!--
  ACTION REQUIRED: 將本區內容替換為此專案的實際技術資訊。
  這個結構是用來引導規劃流程的建議骨架。
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

*Gate: 必須在 Phase 0 research 前通過，並於 Phase 1 design 後再次確認。*

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
- Documentation Language: Confirm this plan and all downstream Markdown
  artifacts, analysis reports, and remediation summaries are authored in
  `zh-TW`.

## 專案結構

### 文件（此功能）

```text
specs/[###-feature]/
|-- plan.md
|-- research.md
|-- data-model.md
|-- quickstart.md
|-- contracts/
`-- tasks.md
```

### 原始碼（repository root）
<!--
  ACTION REQUIRED: 將下方佔位結構替換為此功能的實際目錄。
  刪除未使用的選項，並展開為真實路徑。
  最終輸出的 plan 不可保留 Option 標籤。
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

**Structure Decision**: [記錄選定的結構，並引用上方列出的實際目錄]

## Complexity Tracking

> **僅在 Constitution Check 有違規且必須正當化時填寫**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., extra abstraction layer] | [current need] | [why direct design is insufficient] |
| [e.g., repository layer] | [specific persistence boundary] | [why model-only persistence access is insufficient] |
