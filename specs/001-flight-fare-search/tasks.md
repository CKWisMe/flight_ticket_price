# Tasks: 機票比價入口

**Input**: `D:\flight_ticket_price\specs\001-flight-fare-search\` 下的設計文件  
**Prerequisites**: `plan.md`、`spec.md`、`research.md`、`data-model.md`、`contracts/search-api.yaml`、`quickstart.md`

**Tests**: 本功能依憲章採測試先行，所有 user story 都需先建立失敗測試，再進入實作。  
**Organization**: 任務依 user story 分組，確保每個故事都可獨立完成與驗證。  
**Language Rule**: `tasks.md` 以 `zh-TW` 撰寫；程式識別字、命令與協定欄位保留英文。

## Format: `[ID] [P?] [Story] Description`

- **[P]**: 可並行執行，且不依賴尚未完成的同階段任務
- **[Story]**: 對應 user story，僅 user story phase 使用
- 每個任務都包含精確檔案路徑

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: 建立本功能的基本目錄、設定與文件同步基線。

- [ ] T001 建立功能所需目錄骨架於 `app/services/`, `app/repositories/`, `test/services/`, `test/repositories/`, `test/jobs/`, `test/system/`
- [ ] T002 設定搜尋與結果頁路由骨架於 `config/routes.rb`
- [ ] T003 [P] 建立來源與匯率環境變數範本說明於 `README.md`
- [ ] T004 [P] 建立 adapter registry 與 service/repository 命名準則於 `D:\flight_ticket_price\AGENTS.md`
- [ ] T005 [P] 檢查 `D:\flight_ticket_price\specs\001-flight-fare-search\plan.md`, `D:\flight_ticket_price\specs\001-flight-fare-search\research.md`, `D:\flight_ticket_price\specs\001-flight-fare-search\data-model.md`, `D:\flight_ticket_price\specs\001-flight-fare-search\quickstart.md` 保持 `zh-TW`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: 建立所有 user story 共用的資料模型、分層骨架、背景工作與安全基線。

- [ ] T006 建立搜尋核心 migration 於 `db/migrate/*_create_search_requests.rb`, `db/migrate/*_create_itinerary_legs.rb`, `db/migrate/*_create_source_statuses.rb`, `db/migrate/*_create_exchange_rate_snapshots.rb`, `db/migrate/*_create_source_offers.rb`, `db/migrate/*_create_recommendations.rb`
- [ ] T007 [P] 建立 Active Record 模型與關聯於 `app/models/search_request.rb`, `app/models/itinerary_leg.rb`, `app/models/source_status.rb`, `app/models/exchange_rate_snapshot.rb`, `app/models/source_offer.rb`, `app/models/recommendation.rb`
- [ ] T008 [P] 建立 repository 骨架於 `app/repositories/search_request_repository.rb`, `app/repositories/source_offer_repository.rb`, `app/repositories/exchange_rate_repository.rb`
- [ ] T009 建立 source adapter 基底、registry 與來源設定骨架於 `app/services/source_adapters/base_adapter.rb`, `app/services/source_adapters/registry.rb`, `config/ticket_sources.yml`
- [ ] T010 建立幣別換算服務骨架於 `app/services/currency_conversion/normalize_service.rb`
- [ ] T011 建立背景工作骨架於 `app/jobs/ticket_search_job.rb`, `app/jobs/source_fetch_job.rb`
- [ ] T012 建立不記錄敏感資料的錯誤處理與 logging 包裝於 `app/controllers/application_controller.rb`, `config/initializers/filter_parameter_logging.rb`
- [ ] T013 建立 foundation 測試覆蓋於 `test/models/search_request_test.rb`, `test/models/source_offer_test.rb`, `test/repositories/search_request_repository_test.rb`, `test/services/currency_conversion/normalize_service_test.rb`, `test/jobs/ticket_search_job_test.rb`

**Checkpoint**: 共用 schema、分層骨架、背景工作與安全基線完成，user story 可開始實作。

---

## Phase 3: User Story 1 - 搜尋符合條件的機票 (Priority: P1)

**Goal**: 使用者可建立單程、來回或多點進出的搜尋條件，系統排程搜尋並逐步顯示來源狀態與第一批結果。

**Independent Test**: 送出有效搜尋條件後，系統立即建立搜尋請求並顯示狀態頁；來源逐步回傳結果時，頁面可看到至少一筆符合條件的結果或明確顯示無結果/來源失敗。

### Tests for User Story 1

- [ ] T014 [P] [US1] 建立搜尋建立、驗證與 `202 Accepted` JSON 回應 request test 於 `test/controllers/search_requests_controller_test.rb`
- [ ] T015 [P] [US1] 建立搜尋協調 service 與 job 失敗測試於 `test/services/search_requests/create_service_test.rb`, `test/jobs/source_fetch_job_test.rb`
- [ ] T016 [P] [US1] 建立表單送出與狀態刷新 system test 於 `test/system/search_request_submission_test.rb`

### Implementation for User Story 1

- [ ] T017 [P] [US1] 實作搜尋建立服務於 `app/services/search_requests/create_service.rb`
- [ ] T018 [US1] 實作來源狀態查詢服務於 `app/services/search_requests/status_service.rb`
- [ ] T019 [US1] 擴充 repository 以保存搜尋條件、航段與來源狀態於 `app/repositories/search_request_repository.rb`
- [ ] T020 [US1] 實作搜尋建立與狀態查詢 controller 及 JSON 序列化回應於 `app/controllers/search_requests_controller.rb`, `app/controllers/search_results_controller.rb`, `app/views/search_requests/create.json.jbuilder`, `app/views/search_requests/show.json.jbuilder`
- [ ] T021 [US1] 建立搜尋表單與狀態頁 UI 於 `app/views/search_requests/new.html.erb`, `app/views/search_requests/show.html.erb`, `app/views/search_results/show.html.erb`
- [ ] T022 [P] [US1] 建立多段航程、欄位即時驗證與狀態輪詢 Stimulus controller 於 `app/javascript/controllers/itinerary_builder_controller.js`, `app/javascript/controllers/search_status_controller.js`
- [ ] T023 [US1] 完成來源抓取 job 與 MVP 來源 adapter 呼叫流程於 `app/jobs/ticket_search_job.rb`, `app/jobs/source_fetch_job.rb`, `app/services/source_adapters/skyscanner_adapter.rb`, `app/services/source_adapters/trip_com_adapter.rb`, `app/services/source_adapters/registry.rb`, `config/ticket_sources.yml`
- [ ] T024 [US1] 補上送出時伺服器驗證、失敗來源訊息與隱私安全 logging 於 `app/models/search_request.rb`, `app/models/itinerary_leg.rb`, `app/controllers/application_controller.rb`

**Checkpoint**: User Story 1 可獨立建立搜尋、顯示狀態並看到逐步回傳的結果。

---

## Phase 4: User Story 2 - 比較並前往購買 (Priority: P2)

**Goal**: 使用者可在同一結果頁比較多個來源的價格與時間，依欄位排序，並點擊購買連結導流。

**Independent Test**: 已存在搜尋結果時，結果頁可顯示來源、價格、原幣別/顯示幣別、航班時間、旅行時間與購買連結；切換排序不重跑搜尋，點擊購買可前往對應來源。

### Tests for User Story 2

- [ ] T025 [P] [US2] 建立結果 JSON/頁面排序與導流 request test 於 `test/controllers/search_results_controller_test.rb`
- [ ] T026 [P] [US2] 建立來源結果 repository 與排序 service 測試於 `test/repositories/source_offer_repository_test.rb`, `test/services/search_requests/status_service_test.rb`
- [ ] T027 [P] [US2] 建立結果比較與購買導流 system test 於 `test/system/search_result_comparison_test.rb`

### Implementation for User Story 2

- [ ] T028 [P] [US2] 擴充來源結果模型與 repository 查詢排序能力於 `app/models/source_offer.rb`, `app/repositories/source_offer_repository.rb`
- [ ] T029 [US2] 實作結果查詢、排序流程與 JSON 結果輸出於 `app/services/search_requests/status_service.rb`, `app/controllers/search_results_controller.rb`, `app/views/search_results/show.json.jbuilder`
- [ ] T030 [US2] 建立結果列表、排序控制與導流 UI 於 `app/views/search_results/show.html.erb`, `app/helpers/search_results_helper.rb`
- [ ] T031 [P] [US2] 擴充 MVP 來源 adapter 的結果正規化欄位於 `app/services/source_adapters/skyscanner_adapter.rb`, `app/services/source_adapters/trip_com_adapter.rb`, `app/services/currency_conversion/normalize_service.rb`
- [ ] T032 [US2] 補上過期價格、座位供應狀態、匯率差異、來源失敗與購買連結提示文字，並輸出對應 JSON 揭露欄位於 `app/views/search_results/show.html.erb`, `app/controllers/search_results_controller.rb`, `app/views/search_results/show.json.jbuilder`

**Checkpoint**: User Story 2 可獨立完成比較、排序與購買導流。

---

## Phase 5: User Story 3 - 取得最優惠推薦 (Priority: P3)

**Goal**: 系統可依換算後最終總價、旅行時間與出發時間規則標示最優惠推薦。

**Independent Test**: 當搜尋結果有多筆可比較 offer 時，系統一定能標示一筆推薦；若無法推薦，則明確顯示原因。

### Tests for User Story 3

- [ ] T033 [P] [US3] 建立推薦規則 service 測試於 `test/services/search_requests/recommendation_service_test.rb`
- [ ] T034 [P] [US3] 建立推薦持久化與重算 repository/model test 於 `test/models/recommendation_test.rb`, `test/repositories/source_offer_repository_test.rb`
- [ ] T035 [P] [US3] 建立推薦顯示 system test 於 `test/system/search_recommendation_test.rb`

### Implementation for User Story 3

- [ ] T036 [P] [US3] 實作推薦模型與關聯細節於 `app/models/recommendation.rb`, `app/models/source_offer.rb`
- [ ] T037 [US3] 實作推薦排序與重算服務於 `app/services/search_requests/recommendation_service.rb`
- [ ] T038 [US3] 將推薦寫入與讀取流程接入 repository 於 `app/repositories/source_offer_repository.rb`, `app/repositories/search_request_repository.rb`
- [ ] T039 [US3] 將推薦重算接入來源抓取與結果查詢流程於 `app/jobs/source_fetch_job.rb`, `app/services/search_requests/status_service.rb`
- [ ] T040 [US3] 在結果頁加入推薦區塊與無法推薦說明於 `app/views/search_results/show.html.erb`, `app/helpers/search_results_helper.rb`

**Checkpoint**: User Story 3 可獨立根據既有結果產生與顯示推薦。

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: 收斂跨故事品質、效能、契約一致性與文件驗證。

- [ ] T041 [P] 驗證並更新內部 HTTP 契約、Jbuilder 與 controller 實作一致性於 `D:\flight_ticket_price\specs\001-flight-fare-search\contracts\search-api.yaml`, `app/controllers/search_requests_controller.rb`, `app/controllers/search_results_controller.rb`, `app/views/search_requests/create.json.jbuilder`, `app/views/search_results/show.json.jbuilder`
- [ ] T042 進行來源 timeout policy、背景工作節流與 fan-out 調校於 `app/jobs/ticket_search_job.rb`, `app/jobs/source_fetch_job.rb`, `app/services/source_adapters/registry.rb`
- [ ] T043 [P] 補上跨來源失敗、無結果、匯率差異與多段上限回歸測試於 `test/integration/search_request_flow_test.rb`, `test/system/search_result_comparison_test.rb`
- [ ] T044 [P] 補上 60 秒第一批結果可見性的效能驗證於 `test/integration/search_request_performance_test.rb`, `test/jobs/ticket_search_job_test.rb`
- [ ] T045 執行可近用性修正於 `app/views/search_requests/new.html.erb`, `app/views/search_results/show.html.erb`, `app/javascript/controllers/search_status_controller.js`
- [ ] T046 [P] 驗證並更新操作文件與 MVP 來源設定說明於 `D:\flight_ticket_price\specs\001-flight-fare-search\quickstart.md`, `README.md`
- [ ] T047 [P] 補上手機與桌面斷點下搜尋、排序、推薦與購買導流的 responsive 驗證於 `test/system/search_request_submission_test.rb`, `test/system/search_result_comparison_test.rb`, `test/system/search_recommendation_test.rb`
- [ ] T048 實作搜尋頁與結果頁在 375 px 以上手機寬度及桌面寬度下的 responsive 版面修正於 `app/views/search_requests/new.html.erb`, `app/views/search_results/show.html.erb`, `app/helpers/search_results_helper.rb`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1: Setup**: 無依賴
- **Phase 2: Foundational**: 依賴 Phase 1 完成，且阻塞所有 user stories
- **Phase 3: US1**: 依賴 Phase 2 完成，是 MVP 最小可交付範圍
- **Phase 4: US2**: 依賴 Phase 2 與 US1 的搜尋結果資料流完成
- **Phase 5: US3**: 依賴 Phase 2，並建議在 US1/US2 完成後接入最終結果頁
- **Phase 6: Polish**: 依賴所有預定 user stories 完成

### User Story Completion Order

1. **US1**: 先建立搜尋、狀態追蹤與結果回填主流程
2. **US2**: 再補齊比較、排序與購買導流
3. **US3**: 最後接入最優惠推薦規則與 UI

### Within Each User Story

- 測試任務必須先寫，且先看到失敗結果
- 模型與 repository 先於 service
- service 先於 controller / job / UI 整合
- 核心流程完成後再做 system/integration 驗證修補

## Parallel Opportunities

### Setup / Foundation

- `T003`, `T004`, `T005` 可並行
- `T007`, `T008` 可在 `T006` 後並行

### User Story 1

- `T014`, `T015`, `T016` 可並行撰寫
- `T017` 與 `T022` 可並行，完成後再接 `T020`/`T021`

### User Story 2

- `T025`, `T026`, `T027` 可並行
- `T028` 與 `T031` 可並行，完成後再接 `T029`/`T030`

### User Story 3

- `T033`, `T034`, `T035` 可並行
- `T036` 與 `T037` 可在既有結果流完成後並行展開

## Implementation Strategy

### MVP First

- 先完成 Phase 1、Phase 2、Phase 3。
- 這時即可交付最小可用版本：使用者能建立搜尋、看到來源狀態與第一批結果。

### Incremental Delivery

- 第二增量完成 US2，比較與導流正式可用。
- 第三增量完成 US3，補上最優惠推薦，完成產品核心價值。

### Validation Notes

- 共 48 個任務，全部符合 `- [ ] T### [P?] [US?] 描述含檔案路徑` 格式。
- 每個 user story 都有獨立測試標準與可單獨驗證的交付面。
- 所有任務都維持 `Route -> Service -> Repository` 邊界，並涵蓋測試、安全、可近用性與文件要求。
