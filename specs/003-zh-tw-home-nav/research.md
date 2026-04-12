# Phase 0 研究：zh-TW 語系與首頁返回入口

## 決策 1：前台語系採 Rails I18n，並以 `zh-TW` 作為預設 locale

- **Decision**: 使用 Rails 內建 I18n 管理旅客可見前台頁面的文案，新增 `config/locales/zh-TW.yml`，並在應用程式設定中將 `zh-TW` 設為預設 locale；現有英文 locale 保留作為 fallback 或開發期間參考，不再讓前台核心文案直接硬編碼在 view / controller 內。
- **Rationale**: 目前首頁、搜尋狀態頁、搜尋結果頁與 controller flash 大量使用英文硬編碼字串，若只做局部逐字替換，後續新增頁面時容易再次混回英文。Rails I18n 已是現有框架能力，能最小成本集中管理文案並支援一致的 `zh-TW` 體驗。
- **Alternatives considered**:
  - 直接把各 view/controller 字串改成中文常值：短期可行，但會讓文案分散且難以維護。
  - 引入額外 i18n gem 或 CMS：超出目前需求，增加依賴與維運成本。

## 決策 2：本次前台頁面範圍至少涵蓋首頁、搜尋狀態頁與搜尋結果頁

- **Decision**: 以目前旅客會直接操作的三個前台頁面作為最小設計與驗收範圍：
  - 首頁 `search_requests#new`
  - 搜尋狀態頁 `search_requests#show`
  - 搜尋結果頁 `search_results#show`
  並同步處理這些頁面會觸發的 flash、驗證與空狀態提示。
- **Rationale**: 專案目前的旅客主流程就是「首頁送出搜尋 -> 搜尋狀態頁 -> 搜尋結果頁」。若只修首頁與結果頁，狀態頁與 flash 仍會保留英文，無法符合「所有旅客可見前台頁面」的 clarify 結論。
- **Alternatives considered**:
  - 只調整首頁與搜尋結果頁：會留下搜尋狀態頁與成功/失敗提示的英文斷層。
  - 連同後台/管理頁全面翻譯：超出本 feature 範圍，沒有對應需求價值。

## 決策 3：搜尋結果頁的返回首頁入口採固定可見連結，覆蓋所有結果狀態

- **Decision**: 在搜尋結果頁主要操作區放置固定可見的「回到首頁」入口，讓有結果、無結果與錯誤狀態都共享同一個返回首頁操作；空狀態可視需要重用同一文案，但不應只在空狀態才出現。
- **Rationale**: 目前結果頁僅在空狀態顯示 `Start Another Search`，正常有結果時沒有清楚返回入口，與規格不符。把入口放在頁面主要操作區，可避免使用者需要先判斷頁面是否為空，導覽一致性也最好。
- **Alternatives considered**:
  - 維持只在空狀態顯示：無法滿足「所有搜尋結果頁狀態都可返回首頁」。
  - 依賴瀏覽器上一頁：不可靠，也不符合可預期導覽。

## 決策 4：翻譯範圍包含 controller flash、view 標題與前端互動提示

- **Decision**: 除了 ERB 頁面標題與按鈕文案，還要一併整理 controller 的 `notice` / `alert`，以及前端互動使用的驗證、空結果、載入中提示文字，避免使用者在同一流程中看到中英混用。
- **Rationale**: 目前 `SearchRequestsController` 與 `ApplicationController` 直接輸出文案，若只翻譯 view，流程訊息仍會跳回英文或半套中文，驗收體驗會失敗。
- **Alternatives considered**:
  - 只翻譯頁面可見標題：會漏掉真正高頻的提交流程回饋訊息。
  - 僅翻譯 controller flash：不足以滿足首頁與結果頁大面積英文文案調整。

## 決策 5：測試以更新既有 system flows 為主，輔以 controller/integration 驗證 flash 與導向

- **Decision**: 延續既有 system tests `search_request_submission_test`、`search_result_comparison_test` 等主流程驗證，將英文斷言改為繁體中文並新增「回到首頁」導覽驗證；同時補 controller 或 integration test，覆蓋找不到搜尋請求時的中文 alert 與首頁導向。
- **Rationale**: 這個功能的風險在於完整旅客流程是否仍成立，而不是單一 helper 是否回傳正確字串。從現有 system tests 延伸，能最直接證明前台頁面與導覽入口符合需求。
- **Alternatives considered**:
  - 只寫 view/helper 單元測試：無法證明導頁、flash 與按鈕可見性。
  - 全部只靠 system tests：會漏掉 `RecordNotFound` 導向與某些 controller 層訊息。
