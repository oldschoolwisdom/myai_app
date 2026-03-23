# MyAi — 角色定義與來源

> 版本：v2.2.0
> 日期：2026-03-16
> 修訂：2026-03-16（新增內建角色 dispatcher 與角色來源規則，見 decisions/260316_007_DispatcherBuiltinRole.md，Request #24）
> 修訂：2026-03-17（引入匯入型角色，廢棄掃描型角色，見 decisions/260317_001_ImportedRoleContent.md，Request #25）
> 修訂：2026-03-17（物理隔離原則；work_dir 改為固定慣例；角色模型加 repo_url，見 decisions/260317_002_PhysicalIsolation.md）
> 修訂：2026-03-17（匯入流程 step 6 改為 App 執行 git clone；見 decisions/260317_005_AppBootstrap.md，Request #28）

---

## 概覽

MyAi 的角色目錄（role catalog）由 **內建角色（built-in roles）** 與 **匯入型角色（imported roles）** 組成。  
App 啟動時先建立角色目錄，再以 `offline` 狀態預填 UI；連線成功後再由 Server 實際 session 狀態覆蓋。

---

## 角色來源類型

| 類型 | 來源 | 說明 |
|------|------|------|
| `builtin` | 產品內建 | 不依賴本地 prompt 掃描即可成立；由 App / Server 以保留定義建立 |
| `imported` | App 本地角色庫 | 一般角色；由使用者從 ai repo 匯入並持久化，prompt 內容保存於 App 本地 |
| ~~`scanned`~~ | ~~`ai/prompts/ltc-*.md`~~ | **已廢棄**；見遷移規則 |

> Phase 1 只有一個內建角色：`dispatcher`。

---

## 內建角色：dispatcher

| 欄位 | 定義 |
|------|------|
| `id` | `dispatcher` |
| `source` | `builtin` |
| 職責 | intake 分流、全局狀態掃描、跨角色協調 |
| prompt 來源 | Server 內建 `dispatcher` prompt；若本地 `ai/prompts/dispatcher.md` 存在，可作為 override |
| `work_dir` | project root |
| 專用 repo | 無；dispatcher 相關 issue 仍落在 ai repo |
| 認證 | `ADMIN_TOKEN` / `ADMIN_ACCOUNT` |
| 啟用規則 | **強制存在、強制啟用**；不可在 App UI 停用或刪除 |
| UI 行為 | 與一般角色同樣顯示於 Sidebar / 系統設定頁，但不得被視為「prompt 遺失」孤立角色 |

### prompt fallback 規則

- 若 `ai/prompts/dispatcher.md` 存在，App 可將其作為本地 override 傳給 Server
- 若本地檔不存在、不可讀或未提供，Server 仍必須以內建 `dispatcher` prompt 建立角色
- 因此 **「找不到 `dispatcher.md`」不是建立 dispatcher 失敗的理由**

### 工作目錄規則

dispatcher 沒有專用 repo，因此 `work_dir` 採 **project root**。  
這讓 dispatcher 可以在 project root 範圍內跨 repo 協調，但仍不得離開 project root sandbox。

---

## 一般匯入型角色（Imported Roles）

### 概念

一般角色由使用者從 ai repo 的 prompt 檔案**主動匯入**，App 將 prompt 內容持久化至本地角色庫。  
執行期只依賴本地角色庫，不再直接掃描 ai repo 檔案路徑。

### 物理隔離原則

每個角色擁有獨立的目錄結構，彼此完全隔離：

```
{projectRoot}/
├── {role_id}/
│   ├── code/          ← primary repo（角色負責的 codebase，讀寫）
│   └── {ref_role}/    ← reference repo clone（需參考的其他 repo，唯讀）
│       └── ...
```

- **`{role_id}/code/`** — 角色的唯一讀寫工作目錄（`work_dir`）
- **`{role_id}/{ref_role}/`** — 角色需要參考的其他 repo，各自 clone，唯讀存取
- 同一份 repo 會在多個角色下各自 clone 一份；這是刻意設計，以確保物理隔離（見 `decisions/260317_002_PhysicalIsolation.md`）

> `work_dir` 由 role_id 唯一決定：永遠是 `{projectRoot}/{role_id}/code`。App 不需要推導或詢問使用者。

### 匯入來源

匯入時，App 掃描以下路徑取得可匯入的候選角色：

- `{projectRoot}/ai/prompts/osw-*.md`（當前命名規則）
- `{projectRoot}/ai/prompts/ltc-*.md`（向後相容）

App 讀取候選檔案的 metadata（檔名 → role_id、first-line title → display_name）供使用者選擇。

### 本地角色庫資料模型

每筆匯入的角色紀錄包含：

| 欄位 | 型別 | 說明 |
|------|------|------|
| `role_id` | string | 唯一識別碼（從檔名解析，例如 `osw-spec.md` → `spec`）|
| `display_name` | string | 顯示名稱（從 prompt 第一行標題解析）|
| `prompt_content` | string | 完整 prompt 文字（匯入時讀取並保存）|
| `work_dir` | string | 固定為 `{projectRoot}/{role_id}/code`（物理隔離慣例，不由使用者指定）|
| `repo_url` | string | primary repo 的 git remote URL（用於 clone / 重建工作目錄）|
| `source_kind` | string | 固定為 `"imported"` |
| `source_repo` | string | 來源 ai repo 的路徑（例如 `/path/to/project/ai`）|
| `source_ref` | string | 來源檔案路徑（例如 `ai/prompts/osw-spec.md`）|
| `imported_at` | string | 匯入時間（ISO 8601）|
| `local_revision` | int | 本地版本計數器（初次匯入為 1，每次重新匯入遞增）|
| `enabled` | bool | 是否在 effective enabled set 中 |

> 持久化實作（儲存格式、路徑、加密等）由 App 層自主決定，不在 spec 規範範圍內。

### 匯入流程

1. 使用者在系統設定頁（`/status`）點擊「匯入角色」
2. App 掃描 ai repo prompts 目錄，列出可匯入的候選角色（含已匯入的，以 revision 標注）
3. 使用者選擇一或多個角色，填寫各角色的 `repo_url`（首次匯入；重新匯入時預填已儲存值）
4. 使用者點擊「確認匯入」
5. App 讀取所選 prompt 檔案內容，解析 role_id、display_name
6. App 計算 `work_dir = {projectRoot}/{role_id}/code`；若目錄不存在，**執行 `git clone {repo_url} {work_dir}`**（對話框顯示進度）；clone 失敗則顯示錯誤，停止匯入該角色
7. 若該 role_id 已存在：**覆蓋**（prompt_content、repo_url 更新，local_revision 遞增，imported_at 更新）
8. 若 role_id 為 `dispatcher`：忽略（dispatcher 為 built-in role，不允許以匯入方式覆蓋）
9. App 將角色寫入本地角色庫，加入 `KNOWN_ROLES`，預設 `enabled = true`（新角色）
10. App 對新匯入的啟用角色執行 `POST /configure`（傳 `prompt_content`）建立 session

### 重複匯入規則

| 情況 | 行為 |
|------|------|
| 相同 role_id，再次匯入 | 覆蓋（latest import wins），local_revision 遞增 |
| 相同 role_id，已在執行中 | 覆蓋本地庫後，執行 Session Reset（DELETE → POST /configure）以套用新 prompt |
| 相同 role_id，已停用 | 覆蓋本地庫，不觸發 configure（停用中不重連）|

---

## 角色合併規則

App 建立角色目錄時，順序如下：

1. 注入 mandatory built-in roles（目前只有 `dispatcher`）
2. 從本地角色庫載入所有匯入型角色（`source_kind = "imported"`）
3. 合併成單一角色目錄
4. 套用啟用規則：
   - mandatory built-in roles 永遠加入 effective enabled set
   - 匯入型角色依 `KNOWN_ROLES` + `ENABLED_ROLES` 決定

### ID 衝突規則

若匯入型角色與內建角色發生同名衝突（例如嘗試匯入 `dispatcher`）：

- 內建角色定義優先
- App 應拒絕匯入，並顯示提示
- App 應記錄一筆 warning 供診斷

---

## 遷移規則（scanned → imported）

對於**首次升級**到匯入型架構的既有環境：

1. App 啟動時偵測到本地角色庫為空，且 `KNOWN_ROLES` 中包含非內建角色
2. App **自動嘗試 migration**：掃描 `ai/prompts/ltc-*.md` 與 `ai/prompts/osw-*.md`，讀取內容，寫入角色庫
3. Migration 成功 → 照常啟動，無需使用者介入
4. Migration 失敗（來源檔案不存在 / 不可讀）→ 角色庫留空，主畫面顯示「角色庫為空，請至系統設定頁匯入角色」提示
5. Migration 後移除 `KNOWN_ROLES` 中舊的 `prompt_path` 相關設定，改由角色庫管理

---

## 與 `POST /configure` 的關係

App 對 Server 傳送角色清單時：

- 匯入型角色：使用 `prompt_content`（首選）；向後相容情況可用 `prompt_path`（已廢棄）
- 內建角色：需帶 `builtin_id`
- 對 `dispatcher` 而言，`prompt_path` 可省略；`work_dir` 使用 project root

Server 端具體 request contract 見：

- `spec/server/api.md`
- `spec/server/overview.md`

