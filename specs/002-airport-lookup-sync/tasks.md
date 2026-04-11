# Tasks: 機場查找與名錄同步

**Input**: 來自 `/specs/002-airport-lookup-sync/` 的設計文件
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: 每個功能與每次邏輯變更都 REQUIRED 自動化測試。每個使用者故事都 MUST 包含足以證明行為的測試工作。

**Organization**: 任務依使用者故事分組，讓每個故事都能獨立實作與驗證。

## Format: `[ID] [P?] [Story] Description`

- **[P]**: 可平行執行（不同檔案、且不依賴未完成任務）
- **[Story]**: 對應的使用者故事（US1、US2、US3）
- 每個任務敘述都包含精確檔案路徑

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: 建立任務所需的設定檔與共用骨架

- [ ] T001 建立機場名錄來源設定檔 `config/airport_directory_sources.yml`
- [ ] T002 [P] 檢查並補充機場查找相關路由規劃於 `config/routes.rb`
- [ ] T003 [P] 建立機場查找與同步相關測試目錄骨架於 `test/controllers/.keep`, `test/jobs/.keep`, `test/models/.keep`, `test/repositories/.keep`, `test/services/.keep`, `test/system/.keep`
- [ ] T004 [P] 確認本功能規劃文件維持 `zh-TW` 並對齊 `specs/002-airport-lookup-sync/plan.md`, `specs/002-airport-lookup-sync/research.md`, `specs/002-airport-lookup-sync/data-model.md`, `specs/002-airport-lookup-sync/quickstart.md`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: 在任何使用者故事開始前都 MUST 完成的核心基礎建設

- [ ] T005 建立機場名錄 migration 於 `db/migrate/*_create_airports.rb` 與同步紀錄 migration 於 `db/migrate/*_create_airport_directory_sync_runs.rb`
- [ ] T006 [P] 建立 `Airport` 與 `AirportDirectorySyncRun` model 於 `app/models/airport.rb`, `app/models/airport_directory_sync_run.rb`
- [ ] T007 [P] 建立資料存取邊界於 `app/repositories/airport_repository.rb`, `app/repositories/airport_directory_sync_run_repository.rb`
- [ ] T008 [P] 建立同步來源 registry 與 base adapter 於 `app/services/airport_directory_sources/registry.rb`, `app/services/airport_directory_sources/base_adapter.rb`, `app/services/airport_directory_sources/config_adapter.rb`
- [ ] T009 建立共用正規化與比對工具於 `app/services/airports/normalize_query_service.rb`
- [ ] T010 建立同步工作入口於 `app/jobs/airport_directory_sync_job.rb`
- [ ] T011 執行 schema 更新並確認資料表結構反映於 `db/schema.rb`

**Checkpoint**: Foundation ready. User story implementation can now begin.

---

## Phase 3: User Story 1 - 用熟悉名稱找到正確機場 (Priority: P1)

**Goal**: 讓使用者可用機場代號、中文名稱或城市名稱查找並選定正確機場

**Independent Test**: 在搜尋頁的起飛地與目的地欄位輸入 `TPE`、`桃園`、`東京` 等字串時，可取得符合契約的候選結果並完成單一機場選取

### Tests for User Story 1

> **NOTE: Write these tests FIRST and ensure they FAIL before implementation**

- [ ] T012 [P] [US1] 新增 `Airport` model 驗證與正規化測試於 `test/models/airport_test.rb`
- [ ] T013 [P] [US1] 新增查找 repository 測試於 `test/repositories/airport_repository_test.rb`
- [ ] T014 [P] [US1] 新增查找 service 測試於 `test/services/airports/lookup_service_test.rb`
- [ ] T015 [P] [US1] 新增查找 controller 與 JSON 契約測試於 `test/controllers/airports_controller_test.rb`
- [ ] T016 [P] [US1] 新增搜尋頁自動完成 system test 於 `test/system/airport_lookup_autocomplete_test.rb`
- [ ] T017 [P] [US1] 新增查找延遲 integration test 於 `test/integration/airport_lookup_performance_test.rb`

### Implementation for User Story 1

- [ ] T018 [P] [US1] 建立查找 service 於 `app/services/airports/lookup_service.rb`
- [ ] T019 [US1] 在 `app/repositories/airport_repository.rb` 實作 active 名錄 prefix query、match type 判定與排序規則
- [ ] T020 [US1] 建立查找 endpoint 於 `app/controllers/airports_controller.rb`
- [ ] T021 [US1] 建立查找 JSON 輸出於 `app/views/airports/lookup.json.jbuilder`
- [ ] T022 [P] [US1] 建立前端自動完成 controller 於 `app/javascript/controllers/airport_lookup_controller.js` 並在 `app/javascript/controllers/index.js` 註冊
- [ ] T023 [US1] 將查找互動接入搜尋表單於 `app/views/search_requests/new.html.erb`
- [ ] T024 [US1] 補強查找欄位的可近用與錯誤提示樣式於 `app/assets/stylesheets/application.css`
- [ ] T025 [US1] 調整 `app/controllers/search_requests_controller.rb` 與 `app/services/search_requests/create_service.rb` 以只接受最終選定的機場代號且維持既有送出契約

**Checkpoint**: User Story 1 is fully functional and independently testable.

---

## Phase 4: User Story 2 - 在多機場城市中避免選錯機場 (Priority: P2)

**Goal**: 在多機場城市情境下提供可辨識候選清單並阻止未明確選取的送出

**Independent Test**: 對於如東京、倫敦等多機場城市，搜尋頁必須顯示完整候選資訊、支援鍵盤選取，且未選定具體機場前不得送出查詢

### Tests for User Story 2

- [ ] T026 [P] [US2] 新增多機場排序與候選辨識測試於 `test/services/airports/lookup_service_test.rb`
- [ ] T027 [P] [US2] 新增多機場送出阻擋 controller/service 測試於 `test/controllers/search_requests_controller_test.rb` 與 `test/services/search_requests/create_service_test.rb`
- [ ] T028 [P] [US2] 新增多機場明確選取與鍵盤操作 system test 於 `test/system/airport_lookup_city_disambiguation_test.rb`

### Implementation for User Story 2

- [ ] T029 [US2] 在 `app/services/airports/lookup_service.rb` 與 `app/repositories/airport_repository.rb` 完成城市多候選、國家完全匹配優先與名稱匹配度排序
- [ ] T030 [US2] 在 `app/views/airports/lookup.json.jbuilder` 補齊 `displayName`, `cityName`, `countryName`, `countryCode`, `matchType`, `selectable` 契約欄位
- [ ] T031 [US2] 在 `app/javascript/controllers/airport_lookup_controller.js` 實作多機場候選清單、鍵盤導覽、重新輸入後清除既有選取與送出前驗證
- [ ] T032 [US2] 更新 `app/views/search_requests/new.html.erb` 顯示多機場提示、無結果訊息與欄位驗證文字
- [ ] T033 [US2] 在 `app/assets/stylesheets/application.css` 完成行動版與桌面版候選列表呈現，確保必要辨識資訊不被隱藏

**Checkpoint**: User Stories 1 and 2 both work independently.

---

## Phase 5: User Story 3 - 維持可用的全球機場名錄 (Priority: P3)

**Goal**: 建立可定期同步、可部分成功且可追查狀態的全球機場名錄

**Independent Test**: 手動或排程執行同步後，名錄可更新；若來源部分失敗，舊資料仍可查找；若完整快照缺少既有機場，該機場會被標記停用且不再出現在候選中

### Tests for User Story 3

- [ ] T034 [P] [US3] 新增同步 run model 測試於 `test/models/airport_directory_sync_run_test.rb`
- [ ] T035 [P] [US3] 新增同步 repository 測試於 `test/repositories/airport_directory_sync_run_repository_test.rb`
- [ ] T036 [P] [US3] 新增同步 service 成功、部分成功與停用規則測試於 `test/services/airport_directory/sync_service_test.rb`
- [ ] T037 [P] [US3] 新增同步 job 測試於 `test/jobs/airport_directory_sync_job_test.rb`
- [ ] T038 [P] [US3] 新增同步狀態 endpoint 測試於 `test/controllers/airport_directory_sync_statuses_controller_test.rb`
- [ ] T039 [P] [US3] 新增同步後查找可用性 integration test 於 `test/integration/airport_directory_sync_availability_test.rb`
- [ ] T040 [P] [US3] 新增排程設定驗證測試於 `test/integration/airport_directory_schedule_configuration_test.rb`

### Implementation for User Story 3

- [ ] T041 [P] [US3] 在 `app/repositories/airport_repository.rb` 實作 upsert、reactivate 與 deactivate-missing 能力
- [ ] T042 [P] [US3] 在 `app/repositories/airport_directory_sync_run_repository.rb` 實作同步狀態建立與完成更新
- [ ] T043 [US3] 建立同步主流程於 `app/services/airport_directory/sync_service.rb`
- [ ] T044 [US3] 在 `app/jobs/airport_directory_sync_job.rb` 串接同步 service 並提供可重入 job 入口
- [ ] T045 [US3] 在 `app/services/airport_directory_sources/config_adapter.rb` 與 `app/services/airport_directory_sources/registry.rb` 依 `specs/002-airport-lookup-sync/research.md` 的標準化 payload 契約實作來源讀取與資料映射
- [ ] T046 [US3] 建立同步狀態 endpoint 於 `app/controllers/airport_directory_sync_statuses_controller.rb`
- [ ] T047 [US3] 建立同步狀態 JSON 輸出於 `app/views/airport_directory_sync_statuses/show.json.jbuilder`
- [ ] T048 [US3] 更新 `config/routes.rb` 加入 `airports/lookup` 與 `airport_directory_sync_status` 路由
- [ ] T049 [US3] 在 `config/deploy.yml` 新增每週一 01:00 執行 `AirportDirectorySyncJob` 的排程設定
- [ ] T050 [US3] 在 `specs/002-airport-lookup-sync/quickstart.md` 補充固定排程部署 runbook 與驗證步驟

**Checkpoint**: All user stories are independently functional.

---

## Final Phase: Polish & Cross-Cutting Concerns

**Purpose**: 改善跨多個使用者故事的品質、文件與驗證

- [ ] T051 [P] 以契約實際回應比對 `specs/002-airport-lookup-sync/contracts/airport_lookup_response.schema.json` 與 `specs/002-airport-lookup-sync/contracts/airport_directory_sync_status_response.schema.json`
- [ ] T052 [P] 依手動驗證流程更新 `specs/002-airport-lookup-sync/quickstart.md`
- [ ] T053 執行完整回歸測試並處理失敗案例於 `test/` 與受影響原始碼檔案
- [ ] T054 進行安全與可近用性收尾檢查於 `app/controllers/airports_controller.rb`, `app/controllers/airport_directory_sync_statuses_controller.rb`, `app/views/search_requests/new.html.erb`, `app/assets/stylesheets/application.css`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies
- **Foundational (Phase 2)**: Depends on Setup completion and blocks all stories
- **User Story 1 (Phase 3)**: Depends on Foundational completion
- **User Story 2 (Phase 4)**: Depends on User Story 1 completion because it extends the same lookup UI and selection flow
- **User Story 3 (Phase 5)**: Depends on Foundational completion and can proceed after User Story 1 if needed, but final delivery should follow US2 to keep lookup behavior stable
- **Polish (Final Phase)**: Depends on all desired stories being complete

### Within Each User Story

- Tests MUST be written and FAIL before implementation
- Model and repository changes before service logic
- Service logic before controllers, Jbuilder, or UI handlers
- UI validation and accessibility updates before final regression testing

### User Story Dependency Graph

- **US1**: MVP 基礎查找能力，無故事前置依賴
- **US2**: 依賴 US1 的查找 API 與 autocomplete 骨架
- **US3**: 依賴 Phase 2 的資料模型與同步骨架；完成後反向強化 US1/US2 的真實資料來源

## Parallel Opportunities

- `T002`, `T003`, `T004` 可在 Setup phase 平行執行
- `T006`, `T007`, `T008`, `T010` 可在 migration 決定後平行執行
- `T012` 到 `T016` 可由不同測試層級平行撰寫
- `T022` 與 `T024` 可在 `T020`/`T021` API 骨架完成後平行進行
- `T026` 到 `T028` 可平行撰寫後再集中修正 US2 行為
- `T034` 到 `T040` 可由 model/repository/service/job/controller/排程檢查平行展開
- `T041` 與 `T042` 可平行實作，之後由 `T043` 統整
- `T051` 與 `T052` 可在最終驗收前平行處理

## Implementation Strategy

### MVP First

- 先完成 Phase 1、Phase 2、Phase 3
- MVP 只需交付 US1：使用者能在搜尋頁查找到正確機場並選定代號

### Incremental Delivery

1. 完成 US1 後先驗證查找 API、autocomplete 與既有搜尋送出流程不回歸
2. 再完成 US2，補足多機場城市辨識、鍵盤操作與送出阻擋
3. 最後完成 US3，把查找資料從靜態/fixture 導向可同步的真實名錄來源

### Format Validation

- 全部任務皆遵守 `- [ ] T### [P?] [US?] 描述含檔案路徑` 格式
- Setup、Foundational、Polish phase 不含 story label
- User Story phase 任務全部含對應 `US1`、`US2`、`US3` 標記
