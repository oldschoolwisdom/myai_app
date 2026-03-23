# MyAi — 設定畫面規格

> ⚠️ **此文件已廢棄（Deprecated）**
> 
> 版本：v1.3.0（最終版本）
> 廢棄日期：2026-03-15（Request #13）
> 
> **原因**：設定 Bottom Sheet 已移除，所有設定內容整合進「系統設定」頁面。  
> **取代文件**：`spec/app/screens/system_status.md`（v1.2.0 起）

---

> 以下內容保留作為歷史參考。

---

# MyAi — 設定畫面規格（歷史版本）

---

## 概覽

設定畫面以 **DraggableScrollableSheet（Bottom Sheet）** 形式從主畫面右側欄底部呼出，使用者可在此調整外觀、CLI 連線與 API 金鑰等設定。

---

## 觸發方式

- 點擊主畫面右側 Directory 欄位底部的「設定」按鈕
- 從底部滑出（Bottom Sheet 動畫）

---

## 畫面結構

Bottom Sheet 內容以捲動清單排列，分為**六個 Section**：

### Section 1：連線狀態

| 設定項目 | 類型 | 說明 |
|----------|------|------|
| 目前狀態 | 狀態顯示（彩色點 + 文字）| `connected` / `connecting` / `disconnected` / `error` |
| 連線 / 重新連線按鈕 | 按鈕 | 觸發完整啟動序列（讀取 .env → 啟動 binary → POST /configure → WS）|
| 診斷日誌 | 唯讀文字區（可選取複製）| 顯示最近一次啟動序列的逐步記錄，前綴：`·` 資訊 / `✓` 成功 / `⚠` 警告 / `✗` 失敗 |

### Section 2：OSW-MyAI-Agent

| 設定項目 | 類型 | 說明 |
|----------|------|------|
| Binary 路徑 | 文字輸入 | OSW-MyAI-Agent binary 的完整路徑；空白時使用預設值（`$projectRoot/server/code/osw-myai-agent`）|
| 重啟 Server | 按鈕 | 停止目前執行中的 server process，再以新的 binary 路徑重新啟動（執行完整啟動序列）|

> Binary 路徑的優先序：UI 填入值 > `.env` 的 `AI_SERVER_BINARY` > 預設值。  
> 路徑修改後需點擊「重啟 Server」才會生效；目前**不**自動持久化到磁碟（App 重啟後恢復 .env / 預設值）。  
> 啟動序列執行中時按鈕停用，避免重複觸發。

### Section 3：外觀

| 設定項目 | 類型 | 說明 |
|----------|------|------|
| 主題模式 | 三選一（SegmentedButton 或同等元件） | 淺色 / 自動（跟隨系統）/ 深色 |
| 串流時渲染 Markdown | 開關（Switch） | 開啟時，AI 串流回應過程中即時渲染 Markdown；關閉時顯示純文字 |

### Section 4：Copilot CLI

| 設定項目 | 類型 | 說明 |
|----------|------|------|
| CLI 執行路徑 | 文字輸入 | `copilot` CLI 的完整路徑，預設為空（使用 PATH 查找）|
| 測試連線 | 按鈕 | 點擊後嘗試呼叫 CLI，顯示成功 / 失敗結果 |

### Section 5：自訂 API 金鑰（BYOK）

| 設定項目 | 類型 | 說明 |
|----------|------|------|
| API 金鑰 | 密碼輸入（隱藏內容）| 支援 OpenAI / Azure / Anthropic 的 API key |

> BYOK 模式說明：使用者可輸入自己的 LLM API key，不需要 GitHub Copilot 訂閱。詳見 `spec/shared/overview.md` 認證章節。

### Section 6：關於

| 項目 | 說明 |
|------|------|
| 版本號 | 顯示目前 App 版本（如 `v0.1.0`）|
| 規格文件連結 | 可點擊連結，開啟瀏覽器或內部頁面，導向規格文件 |

---

## 狀態儲存

- 設定值以**本地持久化**方式儲存（App 層自主決定實作方式）
- 主題模式變更後**立即套用**，不需要重啟
- CLI 路徑與 BYOK 金鑰在 App 重啟後仍保留

### myai.env 儲存的旗標

以下偏好儲存在 `$projectRoot/myai.env`，toggle 操作後即時寫回（保留原始排版與註解）：

| Key | 說明 |
|-----|------|
| `AUTO_START_SERVER` | App 啟動時是否自動執行 OSW-MyAI-Agent |
| `AUTO_CONNECT` | App 啟動時是否自動建立 WebSocket 連線 |

> 這兩個旗標由系統狀態頁（`/status`）的 Switch 控制；設定畫面目前不重複顯示。

---

## 注意事項

- BYOK 金鑰為敏感資料，輸入框預設隱藏內容，需提供顯示 / 隱藏切換
- 測試連線結果僅顯示於當次操作，不持久儲存
- 此畫面由 App 層管理，不與 Server 端同步設定
