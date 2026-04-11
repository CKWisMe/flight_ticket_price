# 實作計畫：機場查找與名錄同步

**分支**: `[002-airport-lookup-sync]` | **日期**: 2026-04-11 | **規格**: [spec.md](D:/flight_ticket_price/specs/002-airport-lookup-sync/spec.md)
**輸入**: 來自 `/specs/002-airport-lookup-sync/spec.md` 的功能規格

## 摘要

此功能會為搜尋頁新增機場自動完成查找流程，讓使用者可用機場代號、中文名稱或城市名稱選取正確機場，並在多機場城市情境下強制明確選擇。後端將新增可重複使用的機場名錄資料模型、每週排程同步作業、查找 JSON 契約，以及對應的 controller/service/repository 分層實作；同步流程採可部分成功的 upsert 策略，只有在完整來源快照成功取得時，才會把來源已移除的機場標記為停用。第一版以 `OurAirports` 為主要同步來源，並在 adapter 內以 `keywords` 的中文別名補齊中文機場名、城市名與國家名，缺值時回退英文。

## 技術背景

**語言與版本**: Ruby 4.0.1  
**主要依賴**: Rails 8.1.3、Hotwire (`turbo-rails`, `stimulus-rails`)、Jbuilder、Active Job  
**儲存方案**: Rails 管理的 SQLite3  
**測試方式**: `ruby bin/rails test`、`ruby bin/rails test:system`  
**目標平台**: Rails Web App；開發環境為 Windows PowerShell，部署以可執行排程的 Linux/PaaS 環境為前提  
**專案型態**: 單體 Rails Web App  
**效能目標**: 機場查找 API 伺服器端 p95 < 200 ms；使用者可感知候選結果 2 秒內出現  
**限制條件**: 維持 `Route -> Service -> Repository`、不記錄敏感資訊、UI 需符合 WCAG 2.1 AA、規格與分析文件維持 `zh-TW`、不新增非必要第三方套件  
**範圍與規模**: 支援全球機場名錄同步、雙欄位機場查找、每週一次固定同步、最新同步狀態查詢

## 憲章檢查

*檢核門檻: 必須在 Phase 0 研究前通過，並於 Phase 1 設計後再次確認。*

- **簡潔性**: 採用既有 Rails/Jbuilder/Stimulus 架構；不引入搜尋引擎、背景排程框架或額外 API client gem。查找以正規化欄位與 SQL prefix query 完成。
- **重用性**: 已檢查既有 [SearchRequestsController](D:/flight_ticket_price/app/controllers/search_requests_controller.rb)、[SearchRequests::CreateService](D:/flight_ticket_price/app/services/search_requests/create_service.rb)、[SearchRequestRepository](D:/flight_ticket_price/app/repositories/search_request_repository.rb)、[SourceAdapters::Registry](D:/flight_ticket_price/app/services/source_adapters/registry.rb)。本功能將沿用相同的 controller/service/repository 分層與 config-driven adapter 模式。
- **測試完整性**: 新增 model、repository、service、controller、integration、system tests。查找邏輯與同步邏輯都需有對應自動化測試，且 UI 明確選取行為需由 system test 驗證。
- **架構邊界**: `AirportsController` 與 `AirportDirectorySyncStatusesController` 只處理 request/response；查找邏輯放入 `Airports::LookupService`；同步邏輯放入 `AirportDirectory::SyncService`；資料存取分別進入 `AirportRepository` 與 `AirportDirectorySyncRunRepository`。
- **安全與隱私**: 機場查找字串不視為 PII，但仍避免在錯誤訊息中輸出整包 request params。同步來源憑證若需要，使用 Rails credentials 或環境變數；不得硬編碼。
- **可近用性**: 自動完成元件需支援鍵盤上下選取、Enter 確認、aria label/role、錯誤提示可被朗讀；行動版不可隱藏辨識機場所需資訊。
- **效能**: 以預先同步的本地名錄、正規化欄位與前綴查詢維持低延遲，避免查找時呼叫外部服務。
- **依賴管理**: 規劃不新增第三方套件；HTTP 抓取若需要，優先使用 Ruby/Rails 內建能力。
- **文件語言**: 本計畫與輸出文件全部以 `zh-TW` 撰寫，僅保留必要英文程式識別。

## 專案結構

### 文件（本功能）

```text
specs/002-airport-lookup-sync/
|-- plan.md
|-- research.md
|-- data-model.md
|-- quickstart.md
|-- contracts/
|   |-- airport_lookup_response.schema.json
|   `-- airport_directory_sync_status_response.schema.json
`-- tasks.md
```

### 原始碼（專案根目錄）

```text
app/
|-- controllers/
|-- javascript/controllers/
|-- jobs/
|-- models/
|-- repositories/
|-- services/
`-- views/

config/
|-- routes.rb
`-- airport_directory_sources.yml

db/
|-- migrate/
`-- schema.rb

test/
|-- controllers/
|-- integration/
|-- jobs/
|-- models/
|-- repositories/
|-- services/
`-- system/
```

**結構決策**: 沿用既有 Rails 單體專案結構；新增機場名錄相關 controller、service、repository、job、model、Jbuilder 與 Stimulus controller，不建立獨立前後端專案。

## Phase 0：研究結論

研究成果見 [research.md](D:/flight_ticket_price/specs/002-airport-lookup-sync/research.md)。本階段已解決以下設計未知：

- 同步來源採單一主來源、config-driven adapter，方便在 `test` 以 fixture/mock 取代遠端來源；目前主來源為 `OurAirports`，中文欄位採 `keywords` 中文別名優先、英文回退策略。
- 查找不依賴外部 API，而是在本地資料表保存正規化欄位後做 prefix query 與排序。
- 缺漏機場停用只在完整成功同步後執行，避免把來源暫時不完整誤判為刪除。
- 排程以 `AirportDirectorySyncJob` 為執行單位，由部署環境每週一 01:00 觸發；目前專案已有 `config/deploy.yml`，本功能將沿用該部署設定檔描述排程需求，而非引入新的排程框架。

## Phase 1：設計產物

- 資料模型：[data-model.md](D:/flight_ticket_price/specs/002-airport-lookup-sync/data-model.md)
- JSON 契約：
  - [airport_lookup_response.schema.json](D:/flight_ticket_price/specs/002-airport-lookup-sync/contracts/airport_lookup_response.schema.json)
  - [airport_directory_sync_status_response.schema.json](D:/flight_ticket_price/specs/002-airport-lookup-sync/contracts/airport_directory_sync_status_response.schema.json)
- 驗證與手動流程：[quickstart.md](D:/flight_ticket_price/specs/002-airport-lookup-sync/quickstart.md)

## Phase 2：實作切分

1. 建立 `airports` 與 `airport_directory_sync_runs` 資料表、model 與 repository。
2. 建立 `AirportDirectorySources` adapter/registry 與 `AirportDirectory::SyncService`、`AirportDirectorySyncJob`。
3. 建立 `Airports::LookupService`、查找 endpoint、Jbuilder 輸出與 sync status endpoint。
4. 將搜尋頁起飛地/目的地欄位改為 Stimulus autocomplete 互動，保留最終選定的機場代號。
5. 補齊 controller/service/repository/model/system/integration tests，確認查找延遲、lookup API p95 < 200 ms、固定排程與無障礙行為。

## Phase 1 設計後憲章檢查

- **簡潔性**: 通過。所有新增能力都維持在現有 Rails 層內完成，沒有導入額外基礎設施。
- **重用性**: 通過。adapter registry、service result 模式與 repository 分層都延續既有實作。
- **測試完整性**: 通過。已規劃對應的自動化測試類型，未留白。
- **架構邊界**: 通過。查找與同步都明確落在 service/repository；controller 只負責 JSON/HTML 邊界。
- **安全與隱私**: 通過。未引入新的個資儲存；同步憑證保留在 config/credentials 邊界。
- **可近用性**: 通過。已把鍵盤導覽、ARIA 與錯誤提示納入設計與測試。
- **效能**: 通過。查找採本地索引/正規化欄位策略，符合 latency budget。
- **依賴管理**: 通過。暫不新增第三方依賴。
- **文件語言**: 通過。所有規劃文件均為 `zh-TW`。

## 複雜度追蹤

| 偏離項目 | 必要原因 | 未採用更簡單方案的原因 |
|-----------|----------|--------------------------|
| Airport 專用 repository layer | 需隔離同步 upsert、停用標記與查找查詢 | 直接把查找與同步邏輯塞進 Active Record model 會破壞既有分層原則 |
