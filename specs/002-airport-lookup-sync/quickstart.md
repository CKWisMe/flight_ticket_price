# Quickstart：機場查找與名錄同步

## 1. 準備環境

```powershell
ruby bin/rails db:prepare
```

確認已提供機場名錄來源設定，例如：

- `config/airport_directory_sources.yml`
- 若來源需要密鑰，放入 Rails credentials 或環境變數

## 2. 手動執行名錄同步

```powershell
ruby bin/rails runner "AirportDirectorySyncJob.perform_now"
```

預期結果：

- 建立或更新 `airports` 名錄資料
- 建立一筆最新的 `airport_directory_sync_runs`
- 若來源完整成功且某機場已不在來源中，該機場會被標記為停用

## 2.1 設定固定排程

正式環境需由部署平台 scheduler 或 cron 在每週一 `01:00` 執行：

```powershell
ruby bin/rails runner "AirportDirectorySyncJob.perform_now"
```

相關設定已寫入 `config/deploy.yml`：

- `AIRPORT_DIRECTORY_SYNC_SCHEDULE: "0 1 * * 1"`
- `airport_sync` alias 會執行 `AirportDirectorySyncJob.perform_now`

驗證要點：

- scheduler 指向正式環境的應用程式與正確 working directory
- 最近一次執行結果可透過 `airport_directory_sync_runs` 或同步狀態 API 查到
- 若 scheduler 失敗，不應影響既有 `active` 名錄被查找使用

## 3. 啟動 Rails server

```powershell
ruby bin/rails server
```

開啟首頁後，在「起飛機場」或「目的地機場」欄位輸入：

- `TPE`
- `台灣桃園`
- `東京`

US1 驗證要點：

- 欄位下方顯示候選機場
- 選定候選後會保留機場代號 hidden value
- lookup API 多次請求的 p95 應低於 200 ms

US2 驗證要點：

- 多機場城市必須要求明確選定一座機場
- 候選列表顯示 `displayName`、城市與國家資訊
- 無匹配時顯示清楚提示

## 4. 驗證 JSON 契約

查找 API：

```powershell
curl "http://localhost:3000/airports/lookup.json?query=%E6%9D%B1%E4%BA%AC"
```

同步狀態 API：

```powershell
curl "http://localhost:3000/airport_directory_sync_status.json"
```

回應格式需符合：

- [airport_lookup_response.schema.json](D:/flight_ticket_price/specs/002-airport-lookup-sync/contracts/airport_lookup_response.schema.json)
- [airport_directory_sync_status_response.schema.json](D:/flight_ticket_price/specs/002-airport-lookup-sync/contracts/airport_directory_sync_status_response.schema.json)

## 5. 執行測試

```powershell
ruby bin/rails test
ruby bin/rails test:system
```

建議至少覆蓋：

- lookup service 排序與正規化
- sync service 的成功、部分成功、缺漏停用
- controller/Jbuilder 的 JSON 契約
- 搜尋頁自動完成與多機場明確選取流程
