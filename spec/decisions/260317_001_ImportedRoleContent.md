# 260317_001 — 角色 prompts 改為匯入至 App 並以內容型持久化管理

> 日期：2026-03-17
> 影響規格：`shared/roles.md`、`server/api.md`、`app/screens/main_ide.md`、`app/screens/system_status.md`
> 來源：Request #25

---

## 背景

App 目前在啟動時直接掃描 `ai/prompts/ltc-*.md` 作為一般角色來源，並在 `POST /configure` 時以 `prompt_path` 傳給 Server。這讓 App 與 ai repo 在**執行期存在過強耦合**：ai repo 的目錄結構或命名規則變動（例如 `ltc-*.md` → `osw-*.md`），會直接導致 App 無法取得角色 prompts，進而中斷使用。

觸發本次決策的具體原因是：ai repo 已將 prompts 改名為 `osw-*.md`，而 App 仍以 `ltc-*.md` 規則掃描，造成一般角色全部失效。

---

## 問題核心

| 問題 | 說明 |
|------|------|
| 執行期耦合 | App 啟動流程直接依賴 ai repo 的 prompt 檔案路徑結構 |
| 不穩定 | ai repo 更名 → App 掃描失效 → 角色消失 |
| 不可追蹤 | 無法知道使用的是哪個版本的 prompt |
| 不可控 | ai repo 更新直接影響正在使用中的角色行為 |

---

## 候選方案

### 方案 A：更新掃描規則（`osw-*.md`）

- 最小改動，App 只需更新 glob pattern
- **缺點**：治標不治本，下次命名規則改變仍會斷；耦合問題未解決

### 方案 B：內容型持久化（本決策採用）

- App 從 ai repo 匯入角色時，讀取並保存 `prompt_content`
- 執行期只依賴本地角色庫，不再直接依賴 ai repo 結構
- 角色更新時使用者主動重新匯入

### 方案 C：設定檔指定 prompt 路徑

- 在 `myai.env` 或專用設定檔中明確列出每個角色的 prompt 路徑
- 比掃描明確，但仍依賴 ai repo 的檔案存在
- **缺點**：仍是路徑依賴，ai repo 搬移或重命名仍需手動更新設定

---

## 決定

採用**方案 B：內容型持久化（imported roles）**。

- 廢棄 `scanned` 類型的角色來源
- 引入 `imported` 類型：由使用者主動匯入，App 持久化 `prompt_content`
- `POST /configure` 新增 `prompt_content` 欄位，作為 `prompt_path` 的替代（首選）
- 系統設定頁新增「匯入角色」入口

---

## 取捨理由

**得到的**：
- App 解除對 ai repo 命名結構的直接執行期依賴
- 匯入後的角色在 App 重啟後仍可用，不受 ai repo 更新影響
- 可追蹤角色來源（`source_ref`）與本地版本（`local_revision`）
- 使用者可自行控制何時採用 ai repo 的最新 prompt 版本

**代價**：
- 角色 prompt 更新時（ai repo 改版），使用者需要主動重新匯入（非自動同步）
- App 需要管理本地角色庫的持久化（增加儲存層複雜度）
- 首次升級需要一次 migration（自動嘗試，失敗時提示手動匯入）

---

## 主要規格決策

### 資料模型

匯入型角色包含：`role_id`、`display_name`、`prompt_content`、`work_dir`、`source_kind`、`source_repo`、`source_ref`、`imported_at`、`local_revision`、`enabled`。  
持久化實作由 App 層自主決定（不在 spec 規範範圍）。

### 匯入觸發方式

- **使用者主動匯入**（正常路徑）：系統設定頁「匯入角色」按鈕 → 選擇 → 確認
- **自動 migration**（首次升級）：角色庫為空時，App 嘗試自動從 ai/prompts/ 讀取並寫入

### 重複匯入規則

覆蓋（latest import wins）：相同 `role_id` 重新匯入時，`prompt_content` 更新，`local_revision` 遞增。  
不採用「版本並存」或「使用者確認覆蓋 or 跳過」，以降低 UI 複雜度。

### `prompt_path` 向後相容

`prompt_path` 仍被 Server 接受，但 App 端標記為已廢棄（deprecated）。  
匯入型角色應使用 `prompt_content`；`prompt_path` 保留供邊緣場景（例如測試、手動設定）。

### 安全

Server 不得將完整 `prompt_content` 輸出至 log（避免大型 prompt 汙染 log），僅記錄長度或 hash。

---

## 影響範圍

| 文件 | 變更 |
|------|------|
| `shared/roles.md` | 廢棄 `scanned` 類型；引入 `imported` 類型；定義資料模型、匯入流程、遷移規則 |
| `server/api.md` | `POST /configure` 新增 `prompt_content` 欄位；更新必填規則與安全說明 |
| `app/screens/main_ide.md` | 啟動流程 Step 5/6 改為載入本地角色庫；補充 migration 流程與降級提示 |
| `app/screens/system_status.md` | Section 4 改為匯入型角色管理；新增「匯入角色」按鈕與對話框規格 |
