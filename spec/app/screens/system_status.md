# 系統設定頁（System Settings Page）

> 版本：v1.13.0
> 日期：2026-03-22
> 來源：app 角色 Request #11，逆向正規化
> 修訂：2026-03-15（頁面重命名為「系統設定」，整合原設定 Bottom Sheet 內容，新增常用語管理 section，Request #13 #14）
> 修訂：2026-03-16（補記「重啟 Server」與「開新對話」的操作層級差異，Request #16 follow-up）
> 修訂：2026-03-16（dispatcher 定義為 mandatory built-in role；角色列表與 env 規則補充，Request #24）
> 修訂：2026-03-17（匯入對話框 Step 3 repo_url 自動推導、Step 4 改為 App 執行 git clone 並顯示進度，Request #31）
> 修訂：2026-03-17（匯入對話框改為 repo_url 欄位；移除 work_dir 確認步驟，見 decisions/260317_002_PhysicalIsolation.md）
> 修訂：2026-03-17（新增 Section 6 Workspace 設定，見 decisions/260317_003_WorkspaceConfig.md，Request #26）
> 修訂：2026-03-17（全域改名：SDK Server → OSW-MyAI-Agent，Request #27）
> 修訂：2026-03-22（Section 2 補充 WS 連線成功後自動重新 configure roles 規格，spec#37）
> 修訂：2026-03-22（myai.env 補充 AUTH_MODE 鍵，spec#36）
> 修訂：2026-03-22（Section 1 整合 Binary 路徑輸入欄，移除獨立 Section 5，spec#34）

## 概覽

獨立頁面，路由 `/status`。由左側 Sidebar 底部的**系統設定**按鈕進入（`context.push('/status')`）。  
整合系統狀態監控（OSW-MyAI-Agent、WebSocket、啟動序列、角色狀態）與應用程式設定（Server 設定、外觀、API 金鑰、常用語）於同一頁面。

> **此頁面取代原有的設定 Bottom Sheet**（`spec/app/screens/settings.md` 已標記為廢棄）。

---

## 觸發方式

- Sidebar 底部「系統設定」按鈕（expanded：icon + 文字；collapsed：icon only）
- 按鈕右下角有彩色圓點：
  - 綠：server running + WS connected
  - 紅：server error 或 WS error
  - 灰：其他（未連線、待機）

---

## 頁面結構

AppBar：「← 系統設定」，返回即 `context.pop()`

### Section 1 — OSW-MyAI-Agent

| 欄位 | 說明 |
|------|------|
| 狀態列 | icon + 文字（執行中 / 啟動中 / 已停止 / 錯誤）+ 錯誤訊息（若有） |
| PID | 僅在 running 且有 pid 時顯示 |
| Binary 路徑 | 文字輸入框，填入 OSW-MyAI-Agent binary 的完整路徑；空白時使用預設值（`$projectRoot/server/code/osw-myai-agent`）|
| 啟動時自動執行 | Switch，對應 `myai.env` `AUTO_START_SERVER`；toggle 即時寫回檔案 |
| 按鈕組 | `啟動 Server`（非 running 時）/ `停止 Server`（running 時）+ `重啟 Server`（始終顯示） |

按鈕行為：
- 啟動 Server → `AppStartup.startServerOnly()`
- 停止 Server → `serverProcessProvider.stop()`
- 重啟 Server → `AppStartup.restart()`
- 啟動中時按鈕停用（loading spinner）

> Binary 路徑優先序：UI 填入值 > `myai.env` 的 `AI_SERVER_BINARY` > 預設值。  
> 路徑修改後需點擊「重啟 Server」才會生效；目前不自動持久化到磁碟（App 重啟後恢復 myai.env / 預設值）。
>
> **操作層級說明**：「重啟 Server」屬於 **process 級**操作，會停止目前 OSW-MyAI-Agent binary 並重跑完整啟動序列。  
> 這與主畫面的「開新對話」不同；後者僅重置單一角色 session，不重啟整個 Server process。

### Section 2 — WebSocket 連線

| 欄位 | 說明 |
|------|------|
| 狀態列 | 彩色圓點 + 文字（已連線 / 連線中 / 未連線 / 連線錯誤） |
| Port | 讀自 `myai.env` `AI_SERVER_PORT`（預設 7788） |
| 啟動時自動連線 | Switch，對應 `myai.env` `AUTO_CONNECT`；toggle 即時寫回檔案 |
| 按鈕 | `連線`（非 connected 時）/ `中斷連線`（connected 時） |

按鈕行為：
- 連線 → `AppStartup.connectWs()`（先 configure 再連 WS）（連線中時停用）
- 中斷連線 → `connectionProvider.disconnect()`

> 連線按鈕會先執行 POST /configure（僅送**有效啟用角色**：`ENABLED_ROLES` + mandatory built-in roles），再建立 WebSocket 連線。

**WS 重連後自動重新 Configure**

WebSocket 連線成功（含斷線後自動重連）後，App 應**自動執行一次 `POST /configure`**，帶入目前所有有效啟用角色。

> 原因：Server process 可能已重啟（roles 為 ephemeral），若未重新 configure，後續 `POST /roles/{id}/message` 將返回 404。此行為以 fire-and-forget 方式執行（不阻塞 UI）。

### Section 3 — 啟動序列

- 右上角顯示 phase badge（就緒 / 載入設定 / 啟動 Server / 設定中 / 連線中 / 錯誤）
- 列出所有 `StartupLog`（icon + 文字，依 LogLevel 著色）
- 無記錄時顯示「（尚無記錄）」

### Section 4 — 角色狀態

- 右上角顯示「N / M 個啟用」（N=啟用數, M=所有已知角色數）+ 「匯入角色」按鈕
- 每列：status dot + role id + 來源標注 + 啟用/停用 toggle switch
  - **內建角色**（目前只有 `dispatcher`）：顯示「內建」badge；toggle 固定 ON 且不可切換；不提供刪除鈕；不顯示「prompt 遺失」
  - **匯入型角色**（`source_kind = "imported"`）：status dot 顯示實際狀態，toggle 可切換；顯示 `local_revision`（例如 `r3`）供版本追蹤
    - Toggle ON → `AppStartup.enableRole(roleConfig)`：POST /configure 該角色（帶 `prompt_content`）+ 寫 myai.env
    - Toggle OFF → `AppStartup.disableRole(roleId)`：DELETE /roles/{id} + 寫 myai.env
    - 刪除鈕 → `AppStartup.removeRoleEntry(roleId)`：DELETE /roles/{id} + 從本地角色庫移除 + 從 myai.env 移除
- 停用角色：status dot 顯示 disconnected（灰）
- 角色庫為空（migration 尚未完成）：顯示「角色庫為空，請點擊「匯入角色」匯入」提示

#### 匯入角色對話框

點擊「匯入角色」後，開啟 Dialog：

1. App 掃描 `ai/prompts/osw-*.md` 與 `ai/prompts/ltc-*.md`，列出候選角色清單
2. 每列顯示：role_id、display_name、來源檔案名稱；已匯入的顯示「已匯入（r{local_revision}）」badge
3. 使用者勾選一或多個角色；每個已勾選角色顯示可編輯的 `repo_url` 文字欄位：
   - 已匯入的角色：預填角色庫中已儲存的 `repo_url`
   - 首次匯入：若 `forgejo.baseUrl` 與 `forgejo.orgName` 已設定，預填 `{forgejo.baseUrl}/{forgejo.orgName}/{role_id}`；否則空白
   - 無論是否預填，使用者皆可手動覆寫
4. 使用者點擊「確認匯入」：
   - 若任何已勾選角色的 `repo_url` 為空，阻止提交並提示「請填寫 repo URL」
   - App 計算 `work_dir = {projectRoot}/{role_id}/code`；若目錄不存在：
     - 執行 `git clone {repo_url} {work_dir}`
     - 對話框內即時逐行顯示 git stdout/stderr（log 風格捲動區）
     - clone 失敗 → 顯示錯誤，停止匯入該角色
     - clone 成功 → 繼續匯入流程
   - App 讀取所選 prompt 內容，帶入 `repo_url`，寫入本地角色庫（覆蓋同 role_id、遞增 local_revision）
   - 新匯入且 `enabled = true` 的角色：自動執行 `POST /configure`（帶 `prompt_content`）建立 session
5. `dispatcher` 不可匯入（若出現在候選清單，顯示為不可選）
6. 掃描結果為空時顯示「未找到可匯入的角色」提示

---

## myai.env 控制旗標

| Key | 預設 | 說明 |
|-----|------|------|
| `AUTO_START_SERVER` | `true` | App 啟動時是否自動執行 OSW-MyAI-Agent |
| `AUTO_CONNECT` | `true` | App 啟動時是否自動建立 WebSocket 連線 |
| `ENABLED_ROLES` | `""` | 逗號分隔的**使用者可切換角色** ID；mandatory built-in roles 不依賴此值，App 啟動時會強制加入 effective enabled set |
| `KNOWN_ROLES` | `""` | 已知的所有角色 ID（含匯入型與內建）；dispatcher 為內建預設值 |
| `AUTH_MODE` | `none` | 認證模式，傳入 `POST /configure` 的 `auth.mode`；可選值：`none` \| `copilot` |

Toggle 操作後立即寫回 `myai.env`，下次啟動生效。

> `AUTH_MODE` 在 App 啟動時從 `myai.env` 讀取，並傳入 `POST /configure` 的 `auth.mode` 欄位。未設定時 default 為 `none`。

---

## Section 5 — Workspace

| 欄位 | 說明 |
|------|------|
| 目前路徑 | 顯示 `~/.osw_myai/default.json` 中的 `lastWorkspace` 值 |
| 「變更」按鈕 | 開啟原生 macOS 資料夾選擇對話框 → 寫入 `~/.osw_myai/default.json` → 讀取新 workspace 的 `.osw_myai/config.json` → 重新執行 `initialize()` |

> 設定檔架構見 `spec/shared/workspace_config.md`。

---

## Section 6 — 外觀

| 設定項目 | 類型 | 說明 |
|----------|------|------|
| 主題模式 | 三選一（SegmentedButton 或同等元件）| 淺色 / 自動（跟隨系統）/ 深色 |
| 串流時渲染 Markdown | Switch | 開啟時 AI 串流回應過程中即時渲染 Markdown；關閉時顯示純文字 |

---

## Section 7 — 自訂 API 金鑰（BYOK）

| 設定項目 | 類型 | 說明 |
|----------|------|------|
| API 金鑰 | 密碼輸入（隱藏內容，可切換顯示）| 支援 OpenAI / Azure / Anthropic 的 API key |

> BYOK 模式說明：使用者可輸入自己的 LLM API key，不需要 GitHub Copilot 訂閱。

---

## Section 8 — 常用語（Quick Phrases）

讓使用者預先設定常用指令，一鍵填入對話輸入框。

### 常用語資料模型

| 欄位 | 型別 | 說明 |
|------|------|------|
| id | String | 唯一識別碼（毫秒時間戳記字串）|
| label | String | 按鈕顯示名稱 |
| text | String | 填入輸入框的內容 |

### 持久化

- 儲存於 `{projectRoot}/myai_phrases.json`（JSON array）
- App 啟動時自動載入（startup 序列，與讀取 myai.env 同一階段）
- 新增 / 編輯 / 刪除後即時寫回磁碟

### 預設常用語

| label | text |
|-------|------|
| 更新 Issue | 更新 Issue |

### 管理 UI

- 列出所有常用語（名稱 + 內容預覽）
- 右上角「+」按鈕新增
- 每列提供「編輯」和「刪除」按鈕
- 新增 / 編輯使用 AlertDialog（名稱欄位 + 填入內容欄位）

---

## Section 9 — 關於

| 項目 | 說明 |
|------|------|
| 版本號 | 顯示目前 App 版本（如 `v0.1.0`）|

---

## Section 10 — Forgejo 連線設定

顯示目前 Forgejo 連線狀態，並提供 bootstrap / re-setup 入口。

| 項目 | 說明 |
|------|------|
| Forgejo URL | 顯示目前 `forgejo.baseUrl`（未設定時顯示「未設定」）|
| Organization | 顯示目前 `forgejo.orgName` |
| 連線狀態 | `已連線` / `未設定` / `連線失敗` |
| 「設定 / 重新設定」按鈕 | 開啟 Project Setup Wizard（Phase 1）|
| 「重新執行 Bootstrap」按鈕 | 直接開啟 Project Setup Wizard Phase 2（需已完成 Phase 1）|
| 「重新執行 Local Setup」按鈕 | 直接開啟 Project Setup Wizard Phase 3（需已完成 Phase 1）|

> 詳細流程見 `app/screens/project_setup.md`。

---

## 注意事項

- 所有狀態即時反映（`ref.watch` providers）
- 頁面不儲存自身狀態，返回後重進資料仍在（providers 為 keepAlive）
- `AUTO_START_SERVER=false` 仍可在本頁手動啟動 server
- `AUTO_CONNECT=false` 仍可在本頁手動連線
- 角色啟用狀態寫回 `myai.env` (`ENABLED_ROLES`、`KNOWN_ROLES`)，重啟後保留
- BYOK 金鑰為敏感資料，輸入框預設隱藏內容
