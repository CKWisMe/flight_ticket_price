# Tasks: zh-TW 語系與首頁返回入口

**Input**: 來自 `/specs/003-zh-tw-home-nav/` 的設計文件  
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: 每個功能與每次邏輯變更都 REQUIRED 自動化測試。每個使用者故事都 MUST 包含足以證明行為的測試工作。

**Organization**: 任務依使用者故事分組，讓每個故事都能獨立實作與驗證。

**Language Rule**: `tasks.md` 以 `zh-TW` 撰寫；程式碼、命令、協定欄位與必要專有名詞可保留英文。

## Format: `[ID] [P?] [Story] Description`

- **[P]**: 可平行執行（不同檔案、且不依賴未完成工作）
- **[Story]**: 對應的使用者故事（US1、US2、US3）
- 每個任務都包含精確檔案路徑

## Path Conventions

- Rails app: `app/`, `config/`, `test/` 位於 repository root
- 本功能的規劃與驗證文件位於 `specs/003-zh-tw-home-nav/`

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: 盤點現有前台頁面、文案來源與測試入口，避免重複實作與漏掉旅客可見頁面

- [X] T001 盤點前台頁面與既有文案來源，更新 `specs/003-zh-tw-home-nav/plan.md` 參照的實際檔案清單
- [X] T002 [P] 檢查 `app/controllers/search_requests_controller.rb`、`app/controllers/search_results_controller.rb`、`app/controllers/application_controller.rb` 的硬編碼 flash 與錯誤文案
- [X] T003 [P] 檢查 `app/views/search_requests/new.html.erb`、`app/views/search_requests/show.html.erb`、`app/views/search_results/show.html.erb` 的英文核心文案與導覽入口
- [X] T004 [P] 檢查 `app/javascript/controllers/airport_lookup_controller.js`、`app/javascript/controllers/itinerary_builder_controller.js`、`app/javascript/controllers/search_status_controller.js` 的前台提示文案
- [X] T005 [P] 檢查 `test/system/search_request_submission_test.rb`、`test/system/search_result_comparison_test.rb`、`test/controllers/search_requests_controller_test.rb`、`test/controllers/search_results_controller_test.rb`、`test/integration/search_request_flow_test.rb` 的既有驗證切入點
- [X] T006 [P] 確認 `specs/003-zh-tw-home-nav/plan.md`、`specs/003-zh-tw-home-nav/research.md`、`specs/003-zh-tw-home-nav/data-model.md`、`specs/003-zh-tw-home-nav/quickstart.md` 維持 `zh-TW`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: 建立所有 user stories 共用的語系與文案基礎設施

- [X] T007 設定前台預設語系與 fallback 策略於 `config/application.rb`
- [X] T008 [P] 建立前台 `zh-TW` 文案鍵於 `config/locales/zh-TW.yml`
- [X] T009 [P] 補齊對應英文 fallback 文案鍵於 `config/locales/en.yml`
- [X] T010 建立或更新前台共用翻譯輔助邏輯與狀態翻譯入口於 `app/helpers/application_helper.rb` 與 `app/helpers/search_results_helper.rb`
- [X] T011 整理前台頁面與返回首頁入口的驗收對照於 `specs/003-zh-tw-home-nav/contracts/frontstage-copy-contract.md`

**Checkpoint**: 語系基礎設施與文案鍵已就緒，User Stories 可開始實作。

---

## Phase 3: User Story 1 - 以中文完成搜尋流程 (Priority: P1)

**Goal**: 讓旅客在首頁、搜尋狀態頁、搜尋結果頁與常見提示訊息中看到一致的繁體中文文案

**Independent Test**: 開啟首頁、送出有效與無效搜尋、進入搜尋狀態頁與搜尋結果頁時，主要標題、欄位標籤、按鈕與 flash/驗證提示皆為繁體中文

### Tests for User Story 1

> **NOTE: 先寫這些測試並確認它們在變更前失敗**

- [X] T012 [P] [US1] 更新首頁與搜尋狀態頁中文流程及狀態標示測試於 `test/system/search_request_submission_test.rb`
- [X] T013 [P] [US1] 更新搜尋結果頁中文標題與空狀態文案測試於 `test/system/search_result_comparison_test.rb`
- [X] T014 [P] [US1] 補上找不到搜尋請求時首頁中文 alert 驗證於 `test/controllers/search_results_controller_test.rb`
- [X] T015 [P] [US1] 補上無效搜尋提交時中文錯誤提示驗證於 `test/controllers/search_requests_controller_test.rb`

### Implementation for User Story 1

- [X] T016 [US1] 將首頁翻譯鍵接入 `app/views/search_requests/new.html.erb`
- [X] T017 [US1] 將搜尋狀態頁翻譯鍵與中文狀態標示接入 `app/views/search_requests/show.html.erb` 與 `app/helpers/search_results_helper.rb`
- [X] T018 [US1] 將搜尋結果頁主要標題、排序、推薦、狀態標示與空狀態翻譯鍵接入 `app/views/search_results/show.html.erb` 與 `app/helpers/search_results_helper.rb`
- [X] T019 [US1] 將成功/失敗/找不到資料的前台提示改用 I18n 於 `app/controllers/search_requests_controller.rb` 與 `app/controllers/application_controller.rb`
- [X] T020 [US1] 將機場查找、多城市驗證與搜尋狀態輪詢提示改用 I18n 或伺服端翻譯資料於 `app/javascript/controllers/airport_lookup_controller.js`、`app/javascript/controllers/itinerary_builder_controller.js`、`app/javascript/controllers/search_status_controller.js`

**Checkpoint**: User Story 1 已可獨立完成並以中文操作主流程。

---

## Phase 4: User Story 2 - 從搜尋結果快速回到首頁 (Priority: P2)

**Goal**: 讓搜尋結果頁在所有狀態下都提供清楚可用的返回首頁入口

**Independent Test**: 直接開啟搜尋結果頁，不論有結果或無結果，都能看到「回到首頁」入口並成功導回首頁

### Tests for User Story 2

- [X] T021 [P] [US2] 新增搜尋結果頁返回首頁入口可見性測試於 `test/system/search_result_comparison_test.rb`
- [X] T022 [P] [US2] 新增無結果與錯誤提示情境仍可返回首頁的流程驗證於 `test/integration/search_request_flow_test.rb`

### Implementation for User Story 2

- [X] T023 [US2] 在搜尋結果頁主要操作區加入固定可見的返回首頁入口於 `app/views/search_results/show.html.erb`
- [X] T024 [US2] 補齊返回首頁入口的翻譯鍵與可近用名稱於 `config/locales/zh-TW.yml` 與 `config/locales/en.yml`
- [X] T025 [US2] 整理搜尋結果頁返回首頁入口與 error state 導覽文案於 `app/views/search_results/show.html.erb` 與 `app/helpers/search_results_helper.rb`

**Checkpoint**: User Stories 1 和 2 都能獨立運作，且搜尋結果頁不再依賴瀏覽器返回。

---

## Phase 5: User Story 3 - 維持一致的中文導覽體驗 (Priority: P3)

**Goal**: 讓首頁、搜尋狀態頁、搜尋結果頁之間的中文導覽命名一致，避免旅客在往返流程中混淆

**Independent Test**: 從首頁送出搜尋、查看狀態、進入結果頁再返回首頁，整段流程的核心 CTA 與提示語意保持一致且為繁體中文

### Tests for User Story 3

- [X] T026 [P] [US3] 新增首頁到結果頁再返回首頁的導覽一致性測試於 `test/system/search_request_submission_test.rb`
- [X] T027 [P] [US3] 新增搜尋狀態頁查看結果 CTA 中文一致性驗證於 `test/system/airport_lookup_city_disambiguation_test.rb`

### Implementation for User Story 3

- [X] T028 [US3] 統一首頁、搜尋狀態頁與搜尋結果頁核心 CTA 命名於 `app/views/search_requests/new.html.erb`、`app/views/search_requests/show.html.erb`、`app/views/search_results/show.html.erb`
- [X] T029 [US3] 對齊搜尋狀態輪詢、來源狀態卡片與跨頁 CTA 的中文命名於 `app/javascript/controllers/search_status_controller.js`、`app/views/search_requests/show.html.erb`、`app/views/search_results/show.html.erb`
- [X] T030 [US3] 對齊前台文案契約與手動驗證步驟於 `specs/003-zh-tw-home-nav/contracts/frontstage-copy-contract.md` 與 `specs/003-zh-tw-home-nav/quickstart.md`

**Checkpoint**: 三個 User Stories 都可獨立驗證，且前台導覽語意一致。

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: 收斂跨故事風險、補齊回歸驗證與文件同步

- [X] T031 [P] 執行前台相關回歸測試並確認 `test/system/search_request_submission_test.rb`、`test/system/search_result_comparison_test.rb`、`test/controllers/search_requests_controller_test.rb`、`test/controllers/search_results_controller_test.rb` 全數通過
- [X] T032 [P] 檢查前台頁面鍵盤操作與可近用名稱是否符合契約於 `app/views/search_results/show.html.erb`、`app/javascript/controllers/airport_lookup_controller.js`、`app/javascript/controllers/search_status_controller.js`
- [X] T033 [P] 檢查不同結果狀態下的返回首頁入口與中文空狀態文案於 `specs/003-zh-tw-home-nav/quickstart.md`
- [X] T034 更新 `specs/003-zh-tw-home-nav/quickstart.md` 的最終手動驗證步驟並補記 error state 驗收說明

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: 無前置依賴
- **Foundational (Phase 2)**: 依賴 Setup 完成，並阻擋所有 user stories
- **User Stories (Phase 3+)**: 依賴 Foundational 完成
- **Polish (Phase 6)**: 依賴所有目標 user stories 完成

### User Story Dependencies

- **US1 (P1)**: 可在 Foundational 完成後立即開始，構成 MVP
- **US2 (P2)**: 依賴 US1 已提供 `zh-TW` 文案鍵與搜尋結果頁基礎翻譯
- **US3 (P3)**: 依賴 US1 與 US2，因其目標是跨頁一致性與最終導覽收斂

### Within Each User Story

- 測試 MUST 先寫並在變更前失敗
- locale / helper / 共用文案基礎先於 view 與 controller 整合
- controller / Stimulus 文案調整先於完整流程驗證
- 導覽與可近用收斂先於 polish

### Parallel Opportunities

- Phase 1 的 T002-T006 可平行執行
- Phase 2 的 T008-T009 可平行執行
- US1 的四個測試任務 T012-T015 可平行執行
- US2 的兩個測試任務 T021-T022 可平行執行
- US3 的兩個測試任務 T026-T027 可平行執行
- Polish 的 T031-T033 可平行執行

## Parallel Execution Examples

### User Story 1

```text
# 平行撰寫失敗測試
Task: "T012 更新 test/system/search_request_submission_test.rb 的中文流程斷言"
Task: "T013 更新 test/system/search_result_comparison_test.rb 的中文結果頁斷言"
Task: "T014 更新 test/controllers/search_results_controller_test.rb 的中文 alert 驗證"
Task: "T015 更新 test/controllers/search_requests_controller_test.rb 的中文錯誤提示驗證"
```

### User Story 2

```text
# 平行處理結果頁入口的流程驗證
Task: "T021 在 test/system/search_result_comparison_test.rb 驗證返回首頁入口"
Task: "T022 在 test/integration/search_request_flow_test.rb 驗證無結果情境仍可返回首頁"
```

### User Story 3

```text
# 平行收斂跨頁導覽一致性
Task: "T026 在 test/system/search_request_submission_test.rb 驗證首頁到結果頁再返回首頁"
Task: "T027 在 test/system/airport_lookup_city_disambiguation_test.rb 驗證搜尋狀態頁中文 CTA"
```

## Implementation Strategy

### MVP First

1. 完成 Phase 1-2，先建立 `zh-TW` 預設語系與文案鍵基礎。
2. 完成 US1，讓旅客主流程先可用繁體中文操作。
3. 完成 US2，補齊搜尋結果頁返回首頁入口。

### Incremental Delivery

1. US1 完成後即可交付第一版前台中文化 MVP。
2. US2 完成後即可交付更完整的結果頁導覽體驗。
3. US3 與 Polish 再收斂跨頁一致性、可近用與回歸驗證。

## Notes

- 優先重用既有 `root_path`、前台 view 結構、system test 流程與按鈕樣式
- 不要把商業邏輯移入 route handlers 或 models
- 不要記錄 PII 或硬編碼 secrets
- 所有 generated Markdown artifact 與分析輸出都必須維持 `zh-TW`
- 每個 User Story 完成後都應能獨立驗證，不必等待所有故事全部完成
