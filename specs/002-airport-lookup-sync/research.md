# Phase 0 研究：機場查找與名錄同步

## 決策 1：同步來源採 config-driven 單一主來源 adapter

- **Decision**: 新增 `config/airport_directory_sources.yml` 與 `AirportDirectorySources::Registry`，由單一主來源 adapter 回傳標準化機場資料列。`test` 環境以 fixture 或 stub adapter 取代遠端來源。
- **Rationale**: 專案已存在 [config/ticket_sources.yml](D:/flight_ticket_price/config/ticket_sources.yml) 與 [SourceAdapters::Registry](D:/flight_ticket_price/app/services/source_adapters/registry.rb) 的設定驅動模式，沿用同樣做法可維持一致性，也方便在不修改 service 主流程的前提下替換來源。
- **Alternatives considered**:
  - 在 service 中直接寫死遠端 URL：太脆弱，測試難以隔離。
  - 一開始就支援多來源合併：超出目前需求，增加對帳與衝突解決複雜度。

### OurAirports 中文欄位策略

- **Decision**: `AirportDirectorySources::OurAirportsAdapter` 以 `airports.csv` 與 `countries.csv` 為主資料來源，並優先解析 `keywords` 欄位中的漢字別名來填入 `localizedNameZh`、`cityName`、`countryName`；若來源未提供可用中文，則回退使用英文 `name`、`municipality` 與 `countries.csv name`。
- **Rationale**: `OurAirports` 主欄位以英文為主，但部分機場與國家資料可從 `keywords` 補出中文別名。先採「中文優先、英文回退」可在不增加第二資料源的前提下改善中文使用者體驗，同時維持同步流程穩定。
- **Consequences**:
  - 中文覆蓋率取決於 `OurAirports keywords` 是否提供中文別名，無法保證所有機場都有完整中文。
  - 搜尋與顯示層必須接受 `localizedNameZh` 可能缺值，且 `cityName`、`countryName` 可能為英文回退值。

### 同步來源標準化輸入契約

為避免 `AirportDirectorySources::ConfigAdapter` 實作時缺乏明確輸入形狀，第一版同步來源必須先轉成下列標準化 payload：

```json
{
  "snapshotVersion": "2026-04-11T01:00:00Z",
  "completeSnapshot": true,
  "records": [
    {
      "sourceIdentifier": "ourairports:RJTT",
      "iataCode": "HND",
      "icaoCode": "RJTT",
      "officialNameEn": "Tokyo Haneda International Airport",
      "localizedNameZh": "東京羽田機場",
      "cityName": "東京",
      "countryName": "日本",
      "countryCode": "JP"
    }
  ]
}
```

- `snapshotVersion`: 來源快照版本、ETag 或時間戳字串。
- `completeSnapshot`: `true` 代表可據此停用缺席機場；`false` 代表只允許 upsert，不可停用。
- `records[*].sourceIdentifier`: 穩定唯一鍵，第一版不得以可變名稱欄位代替。
- `records[*].officialNameEn`, `cityName`, `countryName`: 必填；其中 `cityName`、`countryName` 可為中文優先值，也可在來源缺值時回退為英文。
- `records[*].iataCode`, `icaoCode`, `localizedNameZh`, `countryCode`: 可選，但若存在需在 adapter 內先正規化；`localizedNameZh` 允許因來源缺少中文別名而為空。

`test` 環境必須以 fixture/stub 產生同形資料，避免在 service 測試中直接依賴外部來源原始欄位名稱。

## 決策 2：查找採本地名錄 + 正規化欄位 prefix query

- **Decision**: `airports` 資料表保存代號、名稱、城市的正規化欄位，由 `Airports::LookupService` 對本地資料做 prefix query，再依國家完全匹配與名稱匹配度排序。
- **Rationale**: 規格要求查找不可依賴即時外部查詢，且需要忽略大小寫、全半形與前後空白。把正規化結果寫入資料表，可避免每次查詢都做大量字串轉換，並讓 SQLite 下的查找保持可預測。
- **Alternatives considered**:
  - 查找時即時計算正規化：實作簡單，但在候選量放大後延遲不穩。
  - 導入全文檢索或外部搜尋引擎：超出目前需求，也違反簡單優先原則。

## 決策 3：停用缺漏機場只在完整成功同步後執行

- **Decision**: 同步流程分成「取得完整快照」與「逐筆 upsert」兩段。只有當來源快照完整取得成功時，才把本次未出現在來源中的既有機場標記為停用；若來源請求失敗或資料不完整，則保留舊資料且不做停用。
- **Rationale**: 規格同時要求支援部分成功與缺漏停用。若來源本身暫時不完整卻直接停用缺席機場，會把可用名錄誤刪成停用，與需求衝突。
- **Alternatives considered**:
  - 每次同步都把缺席項目停用：對不完整快照過度敏感。
  - 永遠不停用缺席機場：無法滿足 clarify 後的停用規則。

## 決策 4：同步執行單位採 Active Job，排程由部署環境觸發

- **Decision**: 建立 `AirportDirectorySyncJob` 與可重入的 service；每週一 01:00 由部署環境排程呼叫 job 或對應 rake task/runner。
- **Rationale**: 既有專案已使用 Active Job。把同步核心收斂在 job + service，可同時支援手動執行、測試與正式排程，又不必在本 feature 內新增排程框架。
- **Alternatives considered**:
  - 在 Rails app 內自行維護 scheduler loop：部署複雜且不穩定。
  - 只提供手動同步：不符合規格的固定時程需求。

### 排程落地策略

- 第一版以部署平台 scheduler 或 cron 在每週一 `01:00` 執行 `ruby bin/rails runner "AirportDirectorySyncJob.perform_now"`。
- 規劃與 tasks 必須同時包含：
  - 排程設定檔或部署 runbook
  - 至少一個驗證任務，確認 scheduler 會呼叫正確 job
  - 失敗時可從同步狀態 endpoint 或資料表辨識最近一次執行結果

## 決策 5：前端採 Stimulus autocomplete，不改變既有搜尋送出契約

- **Decision**: 搜尋頁維持既有 `search_request` 送出欄位名稱，使用 Stimulus controller 在輸入期間呼叫查找 endpoint，最終仍把選定的 IATA code 回填到原本 `origin_airport_code` / `destination_airport_code` 欄位。
- **Rationale**: 這樣可以最小化對既有 `SearchRequests::CreateService` 與搜尋結果流程的影響，把變更集中在機場選取前的 UI 與查找 API。
- **Alternatives considered**:
  - 把 `SearchRequest` 直接改存 airport record id：會牽動既有 adapter、測試與 JSON 契約，風險較高。
  - 以前端靜態名錄完成查找：全球機場資料量不適合直接灌入頁面。
