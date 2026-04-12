# 實作計畫：zh-TW 語系與首頁返回入口

**分支**: `[003-zh-tw-home-nav]` | **日期**: 2026-04-12 | **規格**: [spec.md](D:/flight_ticket_price/specs/003-zh-tw-home-nav/spec.md)
**輸入**: 來自 `/specs/003-zh-tw-home-nav/spec.md` 的功能規格

## 摘要

此功能會把目前對旅客可見的前台頁面切換為 `zh-TW` 繁體中文預設體驗，範圍至少涵蓋首頁、搜尋狀態頁與搜尋結果頁，並將目前硬編碼在 view / controller / Stimulus 驗證訊息中的英文文案收斂到 Rails I18n。搜尋結果頁會新增固定可見的「回到首頁」操作按鈕，讓使用者可在任何結果狀態下重新開始搜尋；整體實作維持既有 Rails 單體結構，不新增第三方依賴，也不改動既有搜尋商業邏輯。

## 技術背景

**語言與版本**: Ruby 4.0.1  
**主要依賴**: Rails 8.1.3、Hotwire (`turbo-rails`, `stimulus-rails`)、Jbuilder、Puma  
**儲存方案**: Rails 管理的 SQLite3  
**測試方式**: `ruby bin/rails test`、`ruby bin/rails test:system`  
**目標平台**: Rails Web App；開發環境為 Windows PowerShell，部署環境為標準 Rails 伺服器  
**專案型態**: 單體 Rails Web App  
**效能目標**: 文案與導覽調整不得讓既有前台頁面互動明顯退化；若有 JSON/HTML 邊界調整，仍需符合 API-facing p95 < 200 ms 的既有憲章限制  
**限制條件**: 維持 `Route -> Service -> Repository`、前台介面符合 WCAG 2.1 AA、不得硬編碼 secrets、不得新增非必要第三方套件、所有規劃文件維持 `zh-TW`  
**範圍與規模**: 調整目前旅客可見前台頁面的預設語系與核心導覽文案，新增搜尋結果頁返回首頁入口，並更新對應自動化測試

## 憲章檢查

*檢核門檻: 必須在 Phase 0 研究前通過，並於 Phase 1 設計後再次確認。*

- **簡潔性**: 採用 Rails 內建 I18n 與既有 view/helper/Stimulus 結構，不引入額外國際化套件，也不建立獨立文案服務。
- **重用性**: 已檢查 [SearchRequestsController](D:/flight_ticket_price/app/controllers/search_requests_controller.rb)、[SearchResultsController](D:/flight_ticket_price/app/controllers/search_results_controller.rb)、[ApplicationController](D:/flight_ticket_price/app/controllers/application_controller.rb)、[SearchResultsHelper](D:/flight_ticket_price/app/helpers/search_results_helper.rb)、[search_status_controller.js](D:/flight_ticket_price/app/javascript/controllers/search_status_controller.js)、[app/views/search_requests/new.html.erb](D:/flight_ticket_price/app/views/search_requests/new.html.erb)、[app/views/search_requests/show.html.erb](D:/flight_ticket_price/app/views/search_requests/show.html.erb)、[app/views/search_results/show.html.erb](D:/flight_ticket_price/app/views/search_results/show.html.erb)、[config/locales/en.yml](D:/flight_ticket_price/config/locales/en.yml)。本功能優先重用既有 `root_path`、共用按鈕樣式、helper 與頁面結構。
- **測試完整性**: 補上或更新 system tests、controller/integration tests，先證明目前前台頁面存在英文核心文案與結果頁返回入口缺口，再驗證 `zh-TW` 文案與返回首頁按鈕行為。
- **架構邊界**: 語系與導覽調整集中在 controller/view/helper/Stimulus 文案層；不修改既有搜尋服務與 repository 的商業流程。
- **安全與隱私**: 本功能不新增個資欄位、不增加外部資源請求，也不改變 secrets 管理；只整理既有前台文字與站內導覽。
- **可近用性**: 返回首頁按鈕需沿用具語意的連結/按鈕標記；翻譯後的提示文字需維持可辨識標籤與鍵盤操作，不因語系調整破壞無障礙。
- **效能**: I18n 文案查找屬本機記憶體/檔案載入，對既有頁面延遲影響可忽略；不新增會拉長 request 路徑的外部依賴。
- **依賴管理**: 不新增第三方依賴，僅使用 Rails 既有 I18n 與 view helper。
- **文件語言**: 本計畫與所有下游 Markdown 產物均以 `zh-TW` 撰寫，僅保留必要英文程式識別。

## 專案結構

### 文件（本功能）

```text
specs/003-zh-tw-home-nav/
|-- plan.md
|-- research.md
|-- data-model.md
|-- quickstart.md
|-- contracts/
|   `-- frontstage-copy-contract.md
`-- tasks.md
```

### 原始碼（專案根目錄）

```text
app/
|-- controllers/
|-- helpers/
|-- javascript/controllers/
`-- views/

config/
|-- application.rb
`-- locales/

test/
|-- controllers/
|-- integration/
`-- system/
```

**結構決策**: 沿用既有 Rails 單體專案結構；文案翻譯放入 `config/locales/`，前台頁面與導覽入口調整留在現有 controllers/views/helpers/Stimulus，測試延續既有 system 與 integration/controller 測試分層。

## Phase 0：研究結論

研究成果見 [research.md](D:/flight_ticket_price/specs/003-zh-tw-home-nav/research.md)。本階段已解決以下設計未知：

- 前台語系採 Rails I18n，並把 `zh-TW` 設為預設 locale，同時保留英文作為 fallback/開發用語系，而不是繼續在 view、helper、controller 與 Stimulus 中硬編碼文案。
- 本次「旅客可見前台頁面」範圍至少涵蓋首頁、搜尋狀態頁與搜尋結果頁；後台與管理頁明確排除。
- 搜尋結果頁返回首頁入口採持續可見的站內連結，放在結果頁主要操作區，不限於空狀態才顯示。
- 測試策略以更新既有 system tests 為主，輔以 controller/integration 驗證 flash 與導向文案，避免只驗 view 片段卻漏掉完整流程。

## Phase 1：設計產物

- 資料模型：[data-model.md](D:/flight_ticket_price/specs/003-zh-tw-home-nav/data-model.md)
- UI 契約：
  - [frontstage-copy-contract.md](D:/flight_ticket_price/specs/003-zh-tw-home-nav/contracts/frontstage-copy-contract.md)
- 驗證與手動流程：[quickstart.md](D:/flight_ticket_price/specs/003-zh-tw-home-nav/quickstart.md)

## Phase 2：實作切分

1. 設定 `zh-TW` 為前台預設語系，建立或擴充 locale 檔，整理首頁、搜尋狀態頁、搜尋結果頁、status badge 與 controller flash/錯誤提示所需文案鍵。
2. 更新前台 views / helpers / Stimulus 驗證訊息與動態狀態顯示，移除核心硬編碼英文文案，保持旅客可見頁面用語一致。
3. 在搜尋結果頁加入固定可見的「回到首頁」入口，覆蓋有結果、無結果與錯誤提示等狀態。
4. 補齊與更新 system、controller、integration tests，確認 `zh-TW` 文案、導向、error state 與無障礙命名行為。

## Phase 1 設計後憲章檢查

- **簡潔性**: 通過。以 Rails I18n 與既有頁面結構完成，無新增抽象層或額外套件。
- **重用性**: 通過。首頁路由、現有 panel/button 樣式、既有 system test 流程與 controller 導向均被重用。
- **測試完整性**: 通過。已規劃更新既有 system tests，並補 controller/integration 驗證前台文字與結果頁返回入口。
- **架構邊界**: 通過。此功能不侵入 `SearchRequests::CreateService`、`SearchRequests::StatusService` 或 repository 商業流程。
- **安全與隱私**: 通過。無新增個資處理、secret 或外部整合。
- **可近用性**: 通過。返回首頁入口採語意化連結/按鈕，翻譯後標籤與提示文案可由輔助工具朗讀。
- **效能**: 通過。I18n 與 view copy 調整不改變既有資料查詢與服務呼叫路徑。
- **依賴管理**: 通過。未新增第三方依賴。
- **文件語言**: 通過。所有規劃文件均為 `zh-TW`。

## 複雜度追蹤

本功能目前無需正當化的憲章違規項目。
