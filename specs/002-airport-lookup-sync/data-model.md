# Data Model：機場查找與名錄同步

## Airport

**用途**: 代表可供搜尋頁查找與選取的單一機場名錄項目。

**欄位**

| 欄位 | 型別 | 必填 | 說明 |
|---|---|---|---|
| `id` | string/UUID | 是 | 主鍵，沿用專案現有字串型主鍵風格 |
| `source_identifier` | string | 是 | 來源資料的穩定唯一識別，供 upsert 使用 |
| `iata_code` | string | 否 | 三碼機場代號；顯示與查找用途 |
| `icao_code` | string | 否 | 四碼機場代號；顯示與查找用途 |
| `official_name_en` | string | 是 | 官方英文名 |
| `localized_name_zh` | string | 否 | 中文名稱 |
| `city_name` | string | 是 | 所在城市名稱 |
| `country_name` | string | 是 | 國家或地區名稱 |
| `country_code` | string | 否 | ISO 國家或地區代碼，供排序與過濾 |
| `normalized_iata_code` | string | 否 | 正規化後 IATA，用於查找 |
| `normalized_icao_code` | string | 否 | 正規化後 ICAO，用於查找 |
| `normalized_official_name_en` | string | 是 | 正規化後英文名 |
| `normalized_localized_name_zh` | string | 否 | 正規化後中文名 |
| `normalized_city_name` | string | 是 | 正規化後城市名 |
| `active` | boolean | 是 | 是否可出現在新查找候選中 |
| `deactivated_at` | datetime | 否 | 被來源移除後標記停用的時間 |
| `last_synced_at` | datetime | 是 | 最後一次成功套用來源資料的時間 |
| `created_at` / `updated_at` | datetime | 是 | Rails 預設欄位 |

**驗證規則**

- `source_identifier` 唯一且不可空白。
- `official_name_en`、`city_name`、`country_name`、`normalized_official_name_en`、`normalized_city_name` 不可空白。
- `iata_code` 若存在，需為 3 碼英數；`icao_code` 若存在，需為 4 碼英數。
- 查找候選只返回 `active = true` 的資料。

**索引**

- unique index: `source_identifier`
- index: `active`
- composite index: `active + normalized_city_name`
- composite index: `active + normalized_iata_code`
- composite index: `active + normalized_icao_code`
- composite index: `active + normalized_official_name_en`

## AirportDirectorySyncRun

**用途**: 記錄最近一次機場名錄同步的執行結果，供維運查詢成功、部分成功、失敗與停用統計。

**欄位**

| 欄位 | 型別 | 必填 | 說明 |
|---|---|---|---|
| `id` | string/UUID | 是 | 主鍵 |
| `source_key` | string | 是 | 同步來源識別 |
| `status` | string enum | 是 | `succeeded` / `partially_succeeded` / `failed` |
| `started_at` | datetime | 是 | 同步開始時間 |
| `completed_at` | datetime | 否 | 同步完成時間 |
| `source_snapshot_version` | string | 否 | 來源快照版本或 ETag |
| `fetched_record_count` | integer | 是 | 來源回傳筆數 |
| `upserted_record_count` | integer | 是 | 成功新增或更新筆數 |
| `deactivated_record_count` | integer | 是 | 本次標記停用筆數 |
| `failed_record_count` | integer | 是 | 逐筆處理失敗筆數 |
| `error_summary` | text | 否 | 最後一筆摘要錯誤 |
| `created_at` / `updated_at` | datetime | 是 | Rails 預設欄位 |

**驗證規則**

- `source_key`、`status`、`started_at` 不可空白。
- 計數欄位預設為 `0`，不得為負數。
- `completed_at` 在成功或部分成功時必須存在。

**索引**

- index: `started_at`
- index: `status`

## AirportLookupQuery

**用途**: 非持久化 value object，代表單次查找請求與排序上下文。

**欄位**

| 欄位 | 型別 | 必填 | 說明 |
|---|---|---|---|
| `query` | string | 是 | 使用者原始輸入 |
| `normalized_query` | string | 是 | 去空白、大小寫/全半形正規化後的值 |
| `country_code_hint` | string | 否 | 前端若已知國家可帶入排序提示；第一版可不使用 |
| `limit` | integer | 是 | 候選數量上限，預設 10 |

## 關聯與狀態轉換

- `Airport` 與 `AirportDirectorySyncRun` 沒有硬性 foreign key；同步結果以時間與來源版本關聯，避免在每筆機場上記錄大量 run 細節。
- `Airport.active` 狀態轉換：
  - `active -> active`: 來源仍存在且本次同步成功 upsert
  - `active -> inactive`: 來源完整成功，但本次缺席
  - `inactive -> active`: 後續同步重新出現
- `AirportDirectorySyncRun.status` 狀態轉換：
  - `started -> succeeded`
  - `started -> partially_succeeded`
  - `started -> failed`
