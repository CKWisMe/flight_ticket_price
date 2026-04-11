# 任務清單：機場查找與名錄同步

**輸入**: 來自 `/specs/002-airport-lookup-sync/` 的設計文件
**前置文件**: plan.md（必要）、spec.md（使用者故事必要）、research.md、data-model.md、contracts/

**測試原則**: 每個功能與每次邏輯變更都必須有自動化測試。每個使用者故事都必須包含足以證明行為的測試工作。

**任務組織方式**: 任務依使用者故事分組，讓每個故事都能獨立實作與驗證。

## 任務格式：`[ID] [P?] [Story] 說明`

- **[P]**: 可平行執行（不同檔案、且不依賴未完成任務）
- **[Story]**: 對應的使用者故事（US1、US2、US3）
- 每個任務敘述都包含精確檔案路徑

## Phase 1：設定與共用骨架

**目的**: 建立任務所需的設定檔與共用骨架

- [X] T001 建立機場名錄來源設定檔 `config/airport_directory_sources.yml`
- [X] T002 [P] 盤點既有 `config/routes.rb` 與搜尋流程，確認同步狀態 endpoint 命名與 URL 慣例可沿用現有路由風格
- [X] T003 [P] 建立機場查找與同步相關測試目錄骨架於 `test/controllers/.keep`, `test/jobs/.keep`, `test/models/.keep`, `test/repositories/.keep`, `test/services/.keep`, `test/system/.keep`
- [X] T004 [P] 確認本功能規劃文件維持 `zh-TW` 並對齊 `specs/002-airport-lookup-sync/plan.md`, `specs/002-airport-lookup-sync/research.md`, `specs/002-airport-lookup-sync/data-model.md`, `specs/002-airport-lookup-sync/quickstart.md`

---

## Phase 2：基礎建設（阻擋性前置）

**目的**: 在任何使用者故事開始前都必須完成的核心基礎建設

- [X] T005 建立機場名錄 migration 於 `db/migrate/*_create_airports.rb` 與同步紀錄 migration 於 `db/migrate/*_create_airport_directory_sync_runs.rb`
- [X] T006 [P] 建立 `Airport` 與 `AirportDirectorySyncRun` model 於 `app/models/airport.rb`, `app/models/airport_directory_sync_run.rb`
- [X] T007 [P] 建立資料存取邊界於 `app/repositories/airport_repository.rb`, `app/repositories/airport_directory_sync_run_repository.rb`
- [X] T008 [P] 建立同步來源 registry 與 base adapter 於 `app/services/airport_directory_sources/registry.rb`, `app/services/airport_directory_sources/base_adapter.rb`, `app/services/airport_directory_sources/config_adapter.rb`
- [X] T009 建立共用正規化與比對工具於 `app/services/airports/normalize_query_service.rb`
- [X] T010 建立同步工作入口於 `app/jobs/airport_directory_sync_job.rb`
- [X] T011 執行 schema 更新並確認資料表結構反映於 `db/schema.rb`

**檢查點**: 基礎建設完成，使用者故事可開始實作。

---

## Phase 3：使用者故事 1 - 用熟悉名稱找到正確機場（優先度：P1）

**目標**: 讓使用者可用機場代號、中文名稱或城市名稱查找並選定正確機場

**獨立驗證方式**: 在搜尋頁的起飛地與目的地欄位輸入 `TPE`、`桃園`、`東京` 等字串時，可取得符合契約的候選結果並完成單一機場選取

### 使用者故事 1 的測試

> **注意**: 先寫這些測試，並確認它們在實作前會失敗

- [X] T012 [P] [US1] 新增 `Airport` model 驗證與正規化測試於 `test/models/airport_test.rb`
- [X] T013 [P] [US1] 新增查找 repository 測試於 `test/repositories/airport_repository_test.rb`
- [X] T014 [P] [US1] 新增查找 service 測試於 `test/services/airports/lookup_service_test.rb`
- [X] T015 [P] [US1] 新增查找 controller 與 JSON 契約測試於 `test/controllers/airports_controller_test.rb`
- [X] T016 [P] [US1] 新增搜尋頁自動完成 system test 於 `test/system/airport_lookup_autocomplete_test.rb`
- [X] T017 [P] [US1] 新增查找延遲與 lookup API p95 驗證 integration test 於 `test/integration/airport_lookup_performance_test.rb`

### 使用者故事 1 的實作

- [X] T018 [P] [US1] 建立查找 service 於 `app/services/airports/lookup_service.rb`
- [X] T019 [US1] 在 `app/repositories/airport_repository.rb` 實作 active 名錄 prefix query、match type 判定與排序規則
- [X] T020 [P] [US1] 更新 `config/routes.rb` 加入 `airports/lookup` 路由
- [X] T021 [US1] 建立查找 endpoint 於 `app/controllers/airports_controller.rb`
- [X] T022 [US1] 建立查找 JSON 輸出於 `app/views/airports/lookup.json.jbuilder`
- [X] T023 [P] [US1] 建立前端自動完成 controller 於 `app/javascript/controllers/airport_lookup_controller.js` 並在 `app/javascript/controllers/index.js` 註冊
- [X] T024 [US1] 將查找互動接入搜尋表單於 `app/views/search_requests/new.html.erb`
- [X] T025 [US1] 補強查找欄位的可近用與錯誤提示樣式於 `app/assets/stylesheets/application.css`
- [X] T026 [US1] 調整 `app/controllers/search_requests_controller.rb` 與 `app/services/search_requests/create_service.rb` 以只接受最終選定的機場代號且維持既有送出契約
- [X] T027 [US1] 在 `specs/002-airport-lookup-sync/quickstart.md` 補充 lookup API p95 < 200 ms 的量測方式與 US1 驗收步驟

**檢查點**: 使用者故事 1 可獨立運作並驗證。

---

## Phase 4：使用者故事 2 - 在多機場城市中避免選錯機場（優先度：P2）

**目標**: 在多機場城市情境下提供可辨識候選清單並阻止未明確選取的送出

**獨立驗證方式**: 對於如東京、倫敦等多機場城市，搜尋頁必須顯示完整候選資訊、支援鍵盤選取，且未選定具體機場前不得送出查詢

### 使用者故事 2 的測試

- [X] T028 [P] [US2] 新增多機場排序與候選辨識測試於 `test/services/airports/lookup_service_test.rb`
- [X] T029 [P] [US2] 新增多機場送出阻擋 controller/service 測試於 `test/controllers/search_requests_controller_test.rb` 與 `test/services/search_requests/create_service_test.rb`
- [X] T030 [P] [US2] 新增多機場明確選取與鍵盤操作 system test 於 `test/system/airport_lookup_city_disambiguation_test.rb`

### 使用者故事 2 的實作

- [X] T031 [US2] 在 `app/services/airports/lookup_service.rb` 與 `app/repositories/airport_repository.rb` 完成城市多候選、輸入含國家或地區字樣時的完全匹配優先，以及名稱匹配度排序
- [X] T032 [US2] 在 `app/views/airports/lookup.json.jbuilder` 補齊 `displayName`, `cityName`, `countryName`, `countryCode`, `matchType`, `selectable` 契約欄位
- [X] T033 [US2] 在 `app/javascript/controllers/airport_lookup_controller.js` 實作多機場候選清單、鍵盤導覽、重新輸入後清除既有選取與送出前驗證
- [X] T034 [US2] 更新 `app/views/search_requests/new.html.erb` 顯示多機場提示、無結果訊息與欄位驗證文字
- [X] T035 [US2] 在 `app/assets/stylesheets/application.css` 完成行動版與桌面版候選列表呈現，確保必要辨識資訊不被隱藏

**檢查點**: 使用者故事 1 與 2 都可獨立運作。

---

## Phase 5：使用者故事 3 - 維持可用的全球機場名錄（優先度：P3）

**目標**: 建立可定期同步、可部分成功且可追查狀態的全球機場名錄

**獨立驗證方式**: 手動或排程執行同步後，名錄可更新；若來源部分失敗，舊資料仍可查找；若完整快照缺少既有機場，該機場會被標記停用且不再出現在候選中

### 使用者故事 3 的測試

- [X] T036 [P] [US3] 新增同步 run model 測試於 `test/models/airport_directory_sync_run_test.rb`
- [X] T037 [P] [US3] 新增同步 repository 測試於 `test/repositories/airport_directory_sync_run_repository_test.rb`
- [X] T038 [P] [US3] 新增同步 service 成功、部分成功與停用規則測試於 `test/services/airport_directory/sync_service_test.rb`
- [X] T039 [P] [US3] 新增同步 job 測試於 `test/jobs/airport_directory_sync_job_test.rb`
- [X] T040 [P] [US3] 新增同步狀態 endpoint 測試於 `test/controllers/airport_directory_sync_statuses_controller_test.rb`
- [X] T041 [P] [US3] 新增同步後查找可用性 integration test 於 `test/integration/airport_directory_sync_availability_test.rb`
- [X] T042 [P] [US3] 新增排程設定驗證測試於 `test/integration/airport_directory_schedule_configuration_test.rb`

### 使用者故事 3 的實作

- [X] T043 [P] [US3] 在 `app/repositories/airport_repository.rb` 實作 upsert、reactivate 與 deactivate-missing 能力
- [X] T044 [P] [US3] 在 `app/repositories/airport_directory_sync_run_repository.rb` 實作同步狀態建立與完成更新
- [X] T045 [US3] 建立同步主流程於 `app/services/airport_directory/sync_service.rb`
- [X] T046 [US3] 在 `app/jobs/airport_directory_sync_job.rb` 串接同步 service 並提供可重入 job 入口
- [X] T047 [US3] 在 `app/services/airport_directory_sources/config_adapter.rb` 與 `app/services/airport_directory_sources/registry.rb` 依 `specs/002-airport-lookup-sync/research.md` 的標準化 payload 契約實作來源讀取與資料映射
- [X] T048 [US3] 建立同步狀態 endpoint 於 `app/controllers/airport_directory_sync_statuses_controller.rb`
- [X] T049 [US3] 建立同步狀態 JSON 輸出於 `app/views/airport_directory_sync_statuses/show.json.jbuilder`
- [X] T050 [US3] 更新 `config/routes.rb` 加入 `airport_directory_sync_status` 路由
- [X] T051 [US3] 在 `config/deploy.yml` 新增每週一 01:00 執行 `AirportDirectorySyncJob` 的排程設定
- [X] T052 [US3] 在 `specs/002-airport-lookup-sync/quickstart.md` 補充固定排程部署 runbook、同步狀態檢查方式與 US3 驗證步驟

**檢查點**: 全部使用者故事都可獨立運作。

---

## 最終階段：收尾與跨故事品質項目

**目的**: 改善跨多個使用者故事的品質、文件與驗證

- [X] T053 [P] 以契約實際回應比對 `specs/002-airport-lookup-sync/contracts/airport_lookup_response.schema.json` 與 `specs/002-airport-lookup-sync/contracts/airport_directory_sync_status_response.schema.json`
- [X] T054 [P] 依最終整合結果整理 `specs/002-airport-lookup-sync/quickstart.md`，統一 US1-US3 的手動驗證順序與前置條件
- [X] T055 執行完整回歸測試並處理失敗案例於 `test/` 與受影響原始碼檔案
- [X] T056 進行安全與可近用性收尾檢查於 `app/controllers/airports_controller.rb`, `app/controllers/airport_directory_sync_statuses_controller.rb`, `app/views/search_requests/new.html.erb`, `app/assets/stylesheets/application.css`

---

## 相依性與執行順序

### 階段相依性

- **Phase 1 設定與共用骨架**: 無前置相依
- **Phase 2 基礎建設**: 依賴 Phase 1 完成，並阻擋所有使用者故事
- **Phase 3 使用者故事 1**: 依賴 Phase 2 完成
- **Phase 4 使用者故事 2**: 依賴使用者故事 1，因為它延伸相同的查找 UI 與選取流程
- **Phase 5 使用者故事 3**: 依賴 Phase 2，且可在使用者故事 1 後開始，但最終整合仍應排在使用者故事 2 後以降低查找行為回歸風險
- **最終階段**: 依賴所有目標故事完成

### 各使用者故事內部順序

- 測試必須先撰寫，並在實作前失敗
- Model 與 repository 變更先於 service 邏輯
- Service 邏輯先於 controller、Jbuilder 或 UI 處理
- UI 驗證與可近用性更新先於最終回歸測試

### 使用者故事依賴圖

- **US1**: MVP 基礎查找能力，無故事前置依賴
- **US2**: 依賴 US1 的查找 API 與 autocomplete 骨架
- **US3**: 依賴 Phase 2 的資料模型與同步骨架；完成後反向強化 US1/US2 的真實資料來源

## 可平行處理項目

- `T002`, `T003`, `T004` 可在設定階段平行執行
- `T006`, `T007`, `T008`, `T010` 可在 migration 決定後平行執行
- `T012` 到 `T016` 可由不同測試層級平行撰寫
- `T023` 與 `T025` 可在 `T021`/`T022` API 骨架完成後平行進行
- `T028` 到 `T030` 可平行撰寫後再集中修正 US2 行為
- `T036` 到 `T042` 可由 model/repository/service/job/controller/排程檢查平行展開
- `T043` 與 `T044` 可平行實作，之後由 `T045` 統整
- `T053` 與 `T054` 可在最終驗收前平行處理

## 實作策略

### 先交付 MVP

- 先完成 Phase 1、Phase 2、Phase 3
- MVP 只需交付 US1：使用者能在搜尋頁查找到正確機場並選定代號

### 漸進式交付

1. 完成 US1 後先驗證查找 API、autocomplete 與既有搜尋送出流程不回歸
2. 再完成 US2，補足多機場城市辨識、鍵盤操作與送出阻擋
3. 最後完成 US3，把查找資料從靜態/fixture 導向可同步的真實名錄來源

### 格式驗證

- 全部任務皆遵守 `- [ ] T### [P?] [US?] 描述含檔案路徑` 格式
- 設定、基礎建設、最終階段不含 story label
- 使用者故事階段任務全部含對應 `US1`、`US2`、`US3` 標記
