# 實作計畫: 機票比價入口

**Branch**: `001-flight-fare-search` | **Date**: 2026-04-11 | **Spec**: [spec.md](./spec.md)  
**Input**: 來自 `/specs/001-flight-fare-search/spec.md` 的已澄清功能規格

## 摘要

本功能將在現有 Rails 8 應用中建立一個公開可用的機票比價入口，讓使用者輸入航線、航程型態、日期區間、旅遊天數與直飛偏好後，系統啟動一次搜尋工作，並逐步彙整多個售票來源的結果。設計重點是將使用者請求與外部來源抓取解耦，避免長時間外部呼叫阻塞請求週期，同時以一致的資料模型呈現價格、航班資訊、來源狀態與最優惠推薦；主介面採 server-rendered 頁面，並以內部 JSON 端點支援 Hotwire/Stimulus 的狀態輪詢與結果刷新。

## 技術背景

**Language/Version**: Ruby 4.0.1  
**Primary Dependencies**: Rails 8.1.3、Hotwire (`turbo-rails`, `stimulus-rails`)、Jbuilder、Puma、SQLite3  
**Storage**: Rails 管理的 SQLite（開發、測試與目前 production 設定皆為 SQLite 系列資料庫）  
**Testing**: `bin/rails test`、controller/integration tests、model tests、service/repository tests、system tests  
**Target Platform**: Windows 開發環境、Linux 容器化部署環境  
**Project Type**: Rails 單體式 Web application  
**Performance Goals**: 搜尋提交請求在 200 ms 內完成排程回應；90% 有效搜尋在 60 秒內顯示第一批結果；購買導流與結果刷新不阻塞頁面操作  
**Constraints**: WCAG 2.1 AA、不可記錄 PII、不得硬編碼 secrets、維持 `Route -> Service -> Repository` 邊界、文件以 `zh-TW` 撰寫、價格比較需以單一顯示幣別計算但保留原幣別  
**Scale/Scope**: 匿名公開搜尋、國際線情境優先、單次搜尋最多 4 段航程、架構上支援持續擴充來源，第一版驗收至少啟用 2 個明確售票來源並以 adapter registry 管理

## Constitution Check

*Gate: 通過。Phase 0 research 與 Phase 1 design 均未發現需先中止的違規項目。*

- **Simplicity**: 採用單體 Rails + 背景工作 + adapter registry + 內部 JSON 輪詢端點的最小可行設計；不拆前後端、不引入事件匯流排或多服務架構。
- **Reuse**: 已檢查現有 `app/controllers`、`app/models`、`config/routes.rb`、`test/`，目前僅有 Rails 骨架，無既有 service/repository 可重用；因此新增最小必要分層。
- **Tests**: 每個新增邏輯都會有對應測試，包含 request/controller、service、repository、job、system tests；搜尋協調與推薦規則先寫失敗測試再實作。
- **Architecture**: Routes 僅處理表單與結果頁進出；搜尋協調、推薦、匯率換算與結果聚合放在 services；對資料來源結果、搜尋快照、匯率快照的持久化與查詢封裝在 repositories。
- **Security and Privacy**: 不要求登入；只保存搜尋條件與結果快照，不收集護照或付款資料；來源憑證與匯率來源設定使用 environment secrets；log 中排除使用者輸入全文與外部回應原文。
- **Accessibility**: 搜尋表單、結果排序、來源狀態與推薦區塊將用語意化標記與可鍵盤操作控制項，並以 system test 驗證關鍵流程可操作性與錯誤訊息可辨識性。
- **Performance**: 以非同步搜尋工作避免違反 API-facing p95 < 200 ms 憲章門檻；頁面透過輪詢或 Turbo 更新顯示漸進結果，長延遲留在背景工作中。
- **Dependencies**: 計畫階段不預設新增 gem；優先使用 Rails 內建能力、Ruby 標準庫 HTTP、Active Job / Solid Queue。若後續需要 HTML 解析或瀏覽器自動化，需在實作時補上維護狀態審查。
- **Documentation Language**: 本計畫與下游 Markdown 產物均以 `zh-TW` 撰寫。

## 專案結構

### 功能文件

```text
specs/001-flight-fare-search/
|-- plan.md
|-- research.md
|-- data-model.md
|-- quickstart.md
|-- contracts/
|   `-- search-api.yaml
`-- tasks.md
```

### 程式碼結構

```text
app/
|-- controllers/
|   |-- search_requests_controller.rb
|   `-- search_results_controller.rb
|-- jobs/
|   |-- ticket_search_job.rb
|   `-- source_fetch_job.rb
|-- models/
|   |-- search_request.rb
|   |-- itinerary_leg.rb
|   |-- source_offer.rb
|   |-- source_status.rb
|   |-- recommendation.rb
|   `-- exchange_rate_snapshot.rb
|-- repositories/
|   |-- search_request_repository.rb
|   |-- source_offer_repository.rb
|   `-- exchange_rate_repository.rb
|-- services/
|   |-- search_requests/
|   |   |-- create_service.rb
|   |   |-- status_service.rb
|   |   `-- recommendation_service.rb
|   |-- source_adapters/
|   |   |-- base_adapter.rb
|   |   |-- skyscanner_adapter.rb
|   |   `-- trip_com_adapter.rb
|   |   `-- registry.rb
|   `-- currency_conversion/
|       `-- normalize_service.rb
|-- views/
|   |-- search_requests/
|   `-- search_results/
|-- javascript/
|   `-- controllers/
`-- helpers/
    `-- search_results_helper.rb

config/
|-- routes.rb
`-- initializers/

test/
|-- controllers/
|-- integration/
|-- jobs/
|-- models/
|-- services/
|-- repositories/
`-- system/
```

**Structure Decision**: 採用 Rails 單體式伺服器渲染架構，新增 `services/` 與 `repositories/` 以符合憲章要求，並用 `jobs/` 處理外部來源 fan-out。

## Phase 0: 研究輸出摘要

- 已確認使用既有 Rails/Hotwire/SQLite 基線，不拆分前後端。
- 已確認搜尋提交流程需與外部抓取解耦，避免同步請求超時並符合 p95 < 200 ms 約束。
- 已確認價格比較需保存原始幣別與換算後顯示幣別，推薦只看換算後最終總價。
- 已確認來源範圍在架構上可持續擴充，但第一版驗收需落到至少 2 個明確來源，以維持可測試邊界。
- 已確認 `search-api.yaml` 定義的是支援 server-rendered 頁面與前端輪詢的內部 HTTP 契約，而非獨立對外產品 API。
- 詳細決策見 [research.md](./research.md)。

## Phase 1: 設計產物

- [research.md](./research.md): 記錄架構、背景工作、匯率換算與來源整合策略決策。
- [data-model.md](./data-model.md): 定義搜尋請求、航段、來源結果、匯率快照、推薦與來源狀態模型。
- [contracts/search-api.yaml](./contracts/search-api.yaml): 定義搜尋建立、狀態輪詢、結果查詢與購買導流所需的內部 HTTP 介面契約。
- [quickstart.md](./quickstart.md): 說明本功能的本地開發、測試與驗收流程。

## Phase 2: 實作方向

1. 建立搜尋資料模型與 migration，支援最多 4 段、多來源結果、匯率快照與推薦快照。
2. 建立 controller、service、repository 與 jobs 骨架，先完成搜尋建立與狀態查詢。
3. 完成推薦規則、幣別換算與來源狀態聚合邏輯，並以單元測試覆蓋。
4. 建立至少 2 個具體來源 adapter，完成第一版可驗收的多來源聚合。
5. 建立表單與結果頁 UI，支援進階多段輸入、排序、推薦顯示、來源失敗提示、價格/座位供應與匯率差異揭露。
6. 針對手機與桌面斷點調整搜尋與結果頁版面，確保排序控制、推薦區塊與購買導流在 375 px 以上寬度仍可操作。
7. 補齊 system tests、integration tests、JSON 契約驗證、行動裝置版面驗證與效能驗證。

## Post-Design Constitution Check

- **Simplicity**: 維持單體架構，未引入超出當前需求的分散式基礎設施。
- **Reuse**: 僅在既有骨架無可重用實作時新增 service/repository；未複製現有邏輯。
- **Tests**: 設計已列出完整測試層次，可直接轉成任務。
- **Architecture**: 明確保留 `Route -> Service -> Repository` 與 `Job -> Service -> Repository` 邊界。
- **Security and Privacy**: 未引入登入與敏感個資儲存；外部來源 secrets 保持環境變數管理。
- **Accessibility**: UI 需求與驗證方式已納入設計。
- **Performance**: 長耗時工作移至背景 job，HTTP 回應預算可維持在門檻內。
- **Dependencies**: 尚未承諾新增 gem，符合先重用後擴充原則。
- **Documentation Language**: 產物維持 `zh-TW`。

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Repository layer | 憲章要求將 persistence access 與 business workflow 分離 | 直接在 model 或 service 內散落查詢會破壞 `Route -> Service -> Repository` 邊界 |
| Background jobs for search fan-out | 外部來源抓取延遲與失敗率高，需要與即時 HTTP 請求解耦 | 同步在 controller 內抓取會違反 200 ms API 回應預算，也會讓使用者等待過久 |
| Adapter registry | 來源數量不預設上限，需要一致的來源封裝與健康檢查 | 直接把每個來源寫死在單一 service 內會使來源擴充與失敗隔離失控 |
