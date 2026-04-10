# 資料模型: 機票比價入口

## 1. SearchRequest

### 欄位

| 欄位 | 型別 | 說明 | 驗證 |
|------|------|------|------|
| id | UUID / primary key | 搜尋請求識別碼 | 唯一，不可為空 |
| trip_type | enum | `one_way`、`round_trip`、`multi_city` | 必填 |
| origin_airport_code | string | 主要起飛機場代碼 | 單程/來回必填 |
| destination_airport_code | string | 主要目的地機場代碼 | 單程/來回必填 |
| direct_only | boolean | 是否僅直飛 | 必填，預設 `false` |
| departure_window_start_on | date | 可出發日期區間起始 | 必填 |
| departure_window_end_on | date | 可出發日期區間結束 | 必填，且不得早於起始 |
| stay_length_days | integer | 預計停留天數 | 必填，且大於 0 |
| display_currency | string | 結果顯示幣別 | 必填 |
| status | enum | `queued`、`running`、`partially_completed`、`completed`、`failed` | 必填 |
| requested_at | datetime | 搜尋建立時間 | 必填 |
| completed_at | datetime | 搜尋完成時間 | 視狀態而定 |

### 關聯

- `has_many :itinerary_legs`
- `has_many :source_offers`
- `has_many :source_statuses`
- `has_one :recommendation`
- `has_one :exchange_rate_snapshot`

### 狀態轉移

| 目前狀態 | 事件 | 下一狀態 |
|----------|------|----------|
| queued | 背景工作開始 | running |
| running | 至少一個來源成功且仍有來源進行中 | partially_completed |
| running | 所有來源完成且至少一個成功 | completed |
| partially_completed | 所有來源完成 | completed |
| queued/running/partially_completed | 所有來源失敗或系統錯誤 | failed |

## 2. ItineraryLeg

### 欄位

| 欄位 | 型別 | 說明 | 驗證 |
|------|------|------|------|
| id | UUID / primary key | 航段識別碼 | 唯一，不可為空 |
| search_request_id | foreign key | 所屬搜尋請求 | 必填 |
| position | integer | 航段順序 | 必填，1..4 |
| origin_airport_code | string | 該段起飛機場 | 必填 |
| destination_airport_code | string | 該段目的地機場 | 必填 |
| departure_on | date | 指定出發日 | 多點進出可填明確日期；其他型態可留空 |

### 規則

- `multi_city` 至少 2 段，最多 4 段。
- 航段順序不得重複，且必須連續。
- 相鄰航段的時間順序必須可構成有效行程。

## 3. SourceStatus

### 欄位

| 欄位 | 型別 | 說明 | 驗證 |
|------|------|------|------|
| id | UUID / primary key | 來源狀態識別碼 | 唯一，不可為空 |
| search_request_id | foreign key | 所屬搜尋請求 | 必填 |
| source_key | string | 來源代號 | 必填 |
| status | enum | `pending`、`fetching`、`succeeded`、`no_results`、`timed_out`、`failed`、`disabled` | 必填 |
| fetched_at | datetime | 最後完成抓取時間 | 視狀態而定 |
| error_code | string | 失敗分類碼 | 可空 |
| error_message | string | 使用者可見或內部摘要訊息 | 可空，但不得含敏感資料 |

### 規則

- 每個 `search_request` + `source_key` 只允許一筆最新狀態。
- 來源失敗不得阻塞其他來源狀態更新。

## 4. ExchangeRateSnapshot

### 欄位

| 欄位 | 型別 | 說明 | 驗證 |
|------|------|------|------|
| id | UUID / primary key | 匯率快照識別碼 | 唯一，不可為空 |
| search_request_id | foreign key | 所屬搜尋請求 | 必填 |
| base_currency | string | 顯示幣別 | 必填 |
| rates_payload | json / serialized text | 各幣別對照匯率 | 必填 |
| provider_key | string | 匯率來源代號 | 必填 |
| captured_at | datetime | 快照建立時間 | 必填 |

### 規則

- 一次搜尋對應一份匯率快照。
- 推薦與排序只能使用同一份快照計算出的換算價格。

## 5. SourceOffer

### 欄位

| 欄位 | 型別 | 說明 | 驗證 |
|------|------|------|------|
| id | UUID / primary key | 結果識別碼 | 唯一，不可為空 |
| search_request_id | foreign key | 所屬搜尋請求 | 必填 |
| source_key | string | 來源代號 | 必填 |
| source_offer_reference | string | 來源側唯一辨識值 | 必填 |
| original_currency | string | 原始幣別 | 必填 |
| display_currency | string | 比較用顯示幣別 | 必填 |
| base_fare_amount | decimal | 票面價格 | 不得為負 |
| taxes_and_fees_amount | decimal | 稅金與必要費用 | 不得為負 |
| total_amount | decimal | 原始幣別總價 | 必填，不得為負 |
| normalized_total_amount | decimal | 換算後總價 | 必填，不得為負 |
| direct_flight | boolean | 是否直飛 | 必填 |
| total_travel_minutes | integer | 總旅行時間 | 必填，大於 0 |
| outbound_departure_at | datetime | 去程出發時間 | 必填 |
| outbound_arrival_at | datetime | 去程抵達時間 | 必填 |
| return_departure_at | datetime | 回程出發時間 | 來回可填 |
| return_arrival_at | datetime | 回程抵達時間 | 來回可填 |
| itinerary_payload | json / serialized text | 各航段詳細資料 | 必填 |
| booking_url | string | 購買連結 | 必填 |
| fetched_at | datetime | 抓取完成時間 | 必填 |
| stale_at | datetime | 預估失效時間 | 可空 |

### 規則

- `search_request_id + source_key + source_offer_reference` 唯一。
- `normalized_total_amount` 必須來自同一 `exchange_rate_snapshot`。
- 多點進出結果需在 `itinerary_payload` 中保存最多 4 段明細。

## 6. Recommendation

### 欄位

| 欄位 | 型別 | 說明 | 驗證 |
|------|------|------|------|
| id | UUID / primary key | 推薦識別碼 | 唯一，不可為空 |
| search_request_id | foreign key | 所屬搜尋請求 | 必填且唯一 |
| source_offer_id | foreign key | 被推薦的結果 | 必填 |
| reason_code | string | 推薦原因代碼 | 必填 |
| explanation | string | 顯示給使用者的推薦說明 | 必填 |
| ranked_at | datetime | 推薦計算時間 | 必填 |

### 規則

- 推薦排序依序為：`normalized_total_amount` 最低、`total_travel_minutes` 最短、`outbound_departure_at` 最早。
- 若無任何有效 offer，則不建立 recommendation，改由結果頁顯示無法推薦原因。

## 7. 重要衍生規則

- 搜尋建立時先產生 `SearchRequest`、必要 `ItineraryLeg` 與 `SourceStatus(pending)`。
- 每個來源完成後更新 `SourceStatus` 並新增/覆寫對應 `SourceOffer`。
- 每次成功新增或更新 offer 後，都重新計算 `Recommendation`，讓結果頁能顯示最新最優惠選項。
- UI 排序只針對已保存的 `SourceOffer` 操作，不重新觸發外部來源。
