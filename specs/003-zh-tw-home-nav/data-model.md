# Data Model：zh-TW 語系與首頁返回入口

## 概述

本功能不新增資料庫實體；資料模型聚焦於前台頁面的文案與導覽契約，確保 `zh-TW` 語系與返回首頁入口可被一致地設計、實作與驗證。

## 實體

### 1. 前台頁面（Frontstage Page）

| 欄位 | 型別 | 必填 | 說明 |
|------|------|------|------|
| `page_key` | string | 是 | 穩定頁面識別，例如 `search_requests.new`、`search_requests.show`、`search_results.show` |
| `audience` | enum | 是 | 固定為 `traveler`，代表此頁面屬於旅客可見前台範圍 |
| `default_locale` | string | 是 | 本功能固定為 `zh-TW` |
| `core_actions` | array<string> | 是 | 頁面上的核心操作，例如提交搜尋、查看結果、回到首頁 |
| `copy_groups` | array<string> | 是 | 此頁面所需文案群組，例如標題、欄位標籤、空狀態、flash、驗證提示 |

**驗證規則**

- `page_key` 必須唯一，避免不同頁面共用模糊識別。
- 只納入目前旅客可見前台頁面，不包含後台或管理頁。
- 每個前台頁面都必須對應至少一組可測試的 `core_actions` 與 `copy_groups`。

### 2. 文案鍵（Copy Key）

| 欄位 | 型別 | 必填 | 說明 |
|------|------|------|------|
| `key` | string | 是 | I18n 文案鍵，例如 `search_requests.new.title` |
| `locale` | string | 是 | 目前設計至少包含 `zh-TW`，英文可作為 fallback |
| `surface` | enum | 是 | 文案顯示位置：`view`、`flash`、`validation`、`button`、`empty_state` |
| `text` | string | 是 | 對應語系顯示文字 |
| `accessibility_name` | string | 否 | 若文案對應互動元件，可額外定義供輔助工具理解的名稱 |

**驗證規則**

- `zh-TW` 文案不得為空，且應避免保留核心英文導覽詞。
- 同一 `key + locale` 組合必須唯一。
- 若 `surface = button` 或其他互動元件，`text` 必須足以描述操作意圖。

### 3. 搜尋結果頁返回入口（Results Home Action）

| 欄位 | 型別 | 必填 | 說明 |
|------|------|------|------|
| `action_key` | string | 是 | 穩定識別，固定為 `search_results.back_to_home` |
| `target_path` | string | 是 | 導向首頁的站內路徑 |
| `visible_states` | array<string> | 是 | 需包含 `with_results`、`empty_results`、`error_notice` |
| `label_key` | string | 是 | 對應 I18n 文案鍵 |
| `keyboard_operable` | boolean | 是 | 是否可透過鍵盤啟用；本功能固定為 `true` |

**驗證規則**

- `target_path` 必須為首頁，不得導向中間頁。
- `visible_states` 必須覆蓋所有搜尋結果頁狀態，不得只在空狀態顯示。
- `label_key` 對應的 `zh-TW` 文案需與首頁導覽語意一致。

## 關係

- 一個 **前台頁面** 會關聯多個 **文案鍵**。
- 搜尋結果頁這個 **前台頁面** 必須關聯一個 **搜尋結果頁返回入口**。
- **搜尋結果頁返回入口** 依賴一個 **文案鍵** 作為按鈕/連結名稱。

## 狀態與轉換

### 前台頁面語系狀態

| 狀態 | 說明 |
|------|------|
| `legacy_english` | 頁面仍存在硬編碼英文核心文案 |
| `localized_zh_tw` | 頁面主要文案已由 `zh-TW` 提供，並納入前台驗收範圍 |

**轉換規則**

- 首頁、搜尋狀態頁、搜尋結果頁都需由 `legacy_english` 轉為 `localized_zh_tw`。
- 任一前台頁面若仍保留英文核心導覽按鈕，不可視為完成轉換。

### 搜尋結果頁返回入口狀態

| 狀態 | 說明 |
|------|------|
| `missing` | 頁面沒有清楚的返回首頁入口，或僅部分狀態可見 |
| `available` | 頁面主要操作區可見返回首頁入口，且所有結果狀態皆可操作 |

**轉換規則**

- 搜尋結果頁需由 `missing` 轉為 `available`。
- 若入口只存在空狀態，不視為 `available`。
