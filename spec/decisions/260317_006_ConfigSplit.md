# 260317_006 — 設定檔分層架構：default.json + workspace config.json

> 日期：2026-03-17  
> 狀態：已採納  
> 影響範圍：shared/workspace_config.md、app/screens/main_ide.md、app/screens/project_setup.md、app/screens/system_status.md

---

## 背景

v1.1.0（決策 260317_003 + 260317_005）將所有設定集中於 `~/.osw_myai/config.json`：workspace 路徑、Forgejo 設定、roleTokens 全混在一個全域檔案中。

問題：**Forgejo 設定與 tokens 是「專案」設定，不是「使用者全域」設定**。若同一台機器有多個 workspace（不同專案），應各自有獨立的 Forgejo 設定，而不共用一個全域 config。

---

## 決定

採用雙層設定架構：

| 層級 | 路徑 | 內容 |
|------|------|------|
| 全域層 | `~/.osw_myai/default.json` | 只記錄 `lastWorkspace`（最後開啟的 workspace 路徑）|
| Workspace 層 | `{workspace}/.osw_myai/config.json` | Forgejo 設定、roleTokens（跟著 workspace 走）|

---

## 取捨理由

- **多 workspace 支援**：每個 workspace 可獨立設定 Forgejo，互不干擾
- **設定隨專案遷移**：`{workspace}/.osw_myai/` 可納入 gitignore，但設定跟著目錄走
- **全域層保持精簡**：`default.json` 只有一個欄位，職責清晰

> 缺點：App 需讀取兩個不同路徑的設定檔，略增複雜度。但這是可接受的取捨。

---

## `lastWorkspace` vs `workspace` 命名

舊欄位名稱為 `workspace`，新名稱改為 `lastWorkspace`，以明確表達「這是 App 最後開啟的記錄」而非絕對的預設值，預留日後支援多 workspace 列表的空間。

---

## 影響範圍

- `shared/workspace_config.md` v1.2.0：全文重寫
- `app/screens/main_ide.md` v1.19.0：Step 0 改為讀取 default.json + workspace config.json
- `app/screens/project_setup.md`：Phase 1 儲存目標改為 `{projectRoot}/.osw_myai/config.json`
- `app/screens/system_status.md`：Section 6 Workspace 說明更新
