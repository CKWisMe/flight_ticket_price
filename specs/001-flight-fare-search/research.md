# 研究紀錄: 機票比價入口

## 決策 1: 介面採用 Rails 伺服器渲染搭配 Hotwire 漸進更新

- **Decision**: 使用 Rails controller + server-rendered views 作為主要 UI，搜尋提交後以 Turbo 驅動結果刷新，不另建獨立 SPA。
- **Rationale**: 現有 repo 已包含 `turbo-rails` 與 `stimulus-rails`，可直接延續現有堆疊，減少新依賴與部署複雜度。
- **Alternatives considered**:
  - 獨立 frontend/backend：會增加 API surface、建置與驗證成本，超出目前需求。
  - 純同步完整頁面刷新：無法良好呈現外部來源逐步回傳的結果。

## 決策 2: 搜尋採非同步協調流程

- **Decision**: `POST /search_requests` 僅建立搜尋請求與排程背景工作，來源抓取與推薦更新在 jobs 中進行。
- **Rationale**: 外部售票來源回應延遲不可控，若同步抓取會讓 request 過久，與憲章要求的 API-facing p95 < 200 ms 衝突。
- **Alternatives considered**:
  - Controller 同步 fan-out 抓取：回應時間不可控，錯誤隔離差。
  - 先不持久化，全部 client-side 打站台：無法統一推薦、排序與來源狀態。

## 決策 3: 來源整合採 adapter registry

- **Decision**: 為每個售票來源建立一個 source adapter，並由 registry 提供所有目前可用來源的清單與健康狀態。
- **Rationale**: 規格要求來源數量不預先設限，adapter registry 能用一致介面管理不同來源的請求、解析、失敗與停用狀態。
- **Alternatives considered**:
  - 在單一 service 寫死所有來源邏輯：維護困難，難以測試與停用單一來源。
  - 只支援固定數量來源：違反已澄清的規格方向。

## 決策 4: 價格比較以匯率快照正規化

- **Decision**: 每次搜尋建立一份匯率快照，將各來源原始幣別換算成單一顯示幣別後進行排序與推薦，同時保留原始幣別與原始價格。
- **Rationale**: 規格已要求跨幣別要能比較，且使用者仍需看到來源原始標價；把匯率綁定到搜尋快照能避免同一頁結果因即時匯率變動而失去一致性。
- **Alternatives considered**:
  - 不做跨幣別推薦：無法完成最優惠推薦。
  - 每次重新渲染時即時重新換匯：同一搜尋結果可能前後不一致，驗證困難。

## 決策 5: 搜尋結果保存為快照資料，而非即時計算視圖

- **Decision**: 將每個來源回傳的 offer、來源狀態、匯率快照與推薦結果保存為 search request 底下的快照資料。
- **Rationale**: 這讓結果頁可以反覆查看、排序、重算推薦與追蹤失敗來源，不必每次重新觸發所有外部請求。
- **Alternatives considered**:
  - 僅記憶體暫存：程序重啟或多進程下結果易遺失。
  - 每次開頁重新打來源：增加來源壓力，也讓價格與推薦不穩定。

## 決策 6: 初版不要求登入，且只保存最低必要資料

- **Decision**: 搜尋功能採匿名使用，不建立會員系統；持久化資料僅包含搜尋條件、結果快照、來源狀態、匯率快照與推薦結果。
- **Rationale**: 規格未要求個人化或訂閱功能，匿名使用能降低範圍與隱私風險。
- **Alternatives considered**:
  - 強制登入才能搜尋：增加 friction 且不符合當前使用情境。
  - 保存使用者識別與追蹤資料：目前沒有商業需求支撐額外隱私負擔。

## 決策 7: 新依賴採延後核准策略

- **Decision**: 計畫階段不先承諾新增 gem；優先使用 Rails 既有能力、Ruby 標準庫、Active Job 與 Solid Queue。若個別來源需要 HTML 解析或 browser automation，再於實作任務中補做維護狀態審查。
- **Rationale**: 目前 repo 仍是骨架，先把可驗證架構定清楚，再按實際來源需求引入依賴，可避免過早承諾。
- **Alternatives considered**:
  - 一開始就加入完整爬蟲/瀏覽器套件：可能過度設計，也不一定所有來源都需要。
