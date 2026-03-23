# Project Setup Wizard

> 版本：v1.1.0  
> 日期：2026-03-17  
> 來源：Request #28（decisions/260317_005_AppBootstrap.md）、decisions/260317_007_BootstrapTemplate.md

---

## 概覽

**Project Setup Wizard** 引導使用者完成 OSW-MyAI 系統的初始化設定，取代手動執行 `bootstrap-forgejo.sh` 和 `setup.sh` CLI 腳本。

Wizard 分三個階段依序執行：

```
Phase 1 — Forgejo 連線設定
  ↓（測試連線成功）
Phase 2 — Bootstrap（建立 Forgejo 資源）
  ↓（所有資源就緒）
Phase 3 — Local Setup（git clone + .env 產生）
  ↓（完成）
主畫面
```

---

## 觸發條件

| 條件 | 行為 |
|------|------|
| App 首次啟動（workspace 未設定）| WorkspaceSetupPage → 選擇目錄後跳轉 Project Setup Wizard |
| workspace 已設定，但 `forgejo.baseUrl` 未設定 | App 啟動後跳轉 Project Setup Wizard（Phase 1） |
| 使用者從系統設定頁手動觸發 | 直接開啟 Project Setup Wizard（Phase 1） |

---

## Phase 1 — Forgejo 連線設定

### 輸入欄位

| 欄位 | 說明 | 範例 |
|------|------|------|
| Forgejo URL | Forgejo 伺服器根 URL（不含 `/api/v1`）| `https://git.example.com` |
| Organization | Forgejo organization 名稱 | `my-org` |
| Admin Token | 管理員 Personal Access Token（`write:admin` 權限）| `xxxxxxxx` |
| AI Template Repo URL | ai repo 的 git URL，作為 bootstrap template 來源 | `http://git.example.com/my-org/ai` |

### 驗證

使用者點擊「測試連線與讀取 Template」：
1. 呼叫 `GET {baseUrl}/api/v1/user`（帶 adminToken）
2. 確認 HTTP 200 且回傳使用者具管理員權限
3. 成功 → 顯示「連線成功」
4. 失敗 → 顯示錯誤訊息（URL 無效 / Token 無效 / 無管理員權限）
5. 從 `aiTemplateRepoUrl` shallow clone `roles.yaml`（讀取 template 角色定義）
6. 解析角色清單 → 顯示「已讀取 N 個角色：{role_id, ...}」
7. 成功 → 啟用「下一步」按鈕；失敗 → 顯示錯誤（URL 無效 / `roles.yaml` 不存在或格式錯誤）

### 儲存

通過驗證後點擊「下一步」，寫入 `{projectRoot}/.osw_myai/config.json`：
```json
{
  "forgejo": {
    "baseUrl": "...",
    "orgName": "...",
    "adminToken": "..."
  },
  "aiTemplateRepoUrl": "..."
}
```

---

## Phase 2 — Bootstrap

App 讀取 Phase 1 取得的 `roles.yaml`，依序對每個 `builtin: false` 的角色執行以下步驟。  
每步驟顯示進度與結果：

| 步驟 | 操作 | 已存在時 |
|------|------|---------|
| 1 | 建立 Forgejo org（`orgName`）| 跳過（冪等） |
| 2 | 根據 `roles.yaml`，為每個 `builtin: false` 的角色建立 repo（`role_repo`）；若 `role_repo_ref` 不為空，從該 URL seed 初始內容 | 跳過 |
| 3 | 根據 `roles.yaml`，為每個 `builtin: false` 的角色建立帳號（`role_account`）| 跳過 |
| 4 | 為各帳號生成 API token，存入 `{projectRoot}/.osw_myai/config.json` → `roleTokens`（key 為 `role_id`）| 重新生成 |
| 5 | 建立 readers team（只讀所有 repo）及各角色 write team | 跳過 |
| 6 | 為各 repo 建立標準 Issue Labels | 跳過 |

> **冪等原則**：所有步驟在資源已存在時跳過，不報錯。Bootstrap 可安全重複執行。

### 標準 Issue Labels

| 名稱 | 顏色 | 說明 |
|------|------|------|
| `status: pending-review` | `#fbca04` | 等待審核 |
| `status: in-progress` | `#1d76db` | 處理中 |
| `status: pending-qa` | `#e4e669` | 等待 QA |
| `status: pending-confirmation` | `#0e8a16` | 等待發起人確認 |
| `status: rejected` | `#ee0701` | 已退回 |
| `type: request` | `#0052cc` | 規格請求 |
| `type: task` | `#5319e7` | 實作任務 |
| `type: bug` | `#d93f0b` | 缺陷 |

### 失敗處理

- 任一步驟失敗 → 顯示錯誤訊息，提供「重試」按鈕
- 成功完成所有步驟 → 啟用「下一步」按鈕

---

## Phase 3 — Local Setup

依序執行以下步驟：

| 步驟 | 操作 |
|------|------|
| 1 | 從 `aiTemplateRepoUrl` clone → `{projectRoot}/ai/`（ai repo 作為 template 來源）|
| 2 | 根據 `roles.yaml`，為每個 `builtin: false` 且 `role_repo` 不為空的角色：`git clone {role_repo_url} {projectRoot}/{role_id}/code/` |
| 3 | 根據 `roles.yaml` 分發 prompts：建立 `{projectRoot}/{role_id}/ai/prompts/`；複製 `ai/prompts/common_*.md`（按檔名升序）給所有角色；複製 `ai/prompts/{role.prompt_file}` 給對應角色 |
| 4 | 複製 `{projectRoot}/ai/scripts/` → 各角色 `{projectRoot}/{role_id}/ai/scripts/` |
| 5 | 為各角色產生 `{projectRoot}/{role_id}/ai/.env`（含 `FORGEJO_TOKEN={roleToken}`）|

### ai repo URL

`aiTemplateRepoUrl` 由使用者在 Phase 1 輸入，clone 至 `{projectRoot}/ai/`。

### 角色 repo URL

`role_repo_url` = `{forgejo.baseUrl}/{forgejo.orgName}/{role.role_repo}.git`（由 roles.yaml 的 `role_repo` 組合）

### prompt 分發規則

依 `ai/prompts/` 命名慣例（詳見 decisions/260317_007_BootstrapTemplate.md）：

| 命名模式 | 分發對象 |
|---------|--------|
| `common_*.md` | 所有角色（按檔名升序排列） |
| `{role.prompt_file}` | 對應 `role_id` 的角色目錄 |

### 失敗處理

- clone 失敗 → 顯示錯誤，提供「重試」按鈕（冪等：目錄已存在時 `git pull` 而非重新 clone）
- 完成 → 顯示摘要，提供「完成」按鈕 → 關閉 Wizard，執行 `initialize()`

---

## 儲存一覽

| 資料 | 儲存位置 |
|------|---------|
| Forgejo 連線設定 | `{projectRoot}/.osw_myai/config.json` → `forgejo` |
| AI Template Repo URL | `{projectRoot}/.osw_myai/config.json` → `aiTemplateRepoUrl` |
| 角色 tokens | `{projectRoot}/.osw_myai/config.json` → `roleTokens`（唯一儲存位置）|
| 角色 code repo | `{projectRoot}/{role_id}/code/`（git clone） |
| 角色 prompts | `{projectRoot}/{role_id}/ai/prompts/`（依命名慣例選擇性分發）|
| 角色 scripts | `{projectRoot}/{role_id}/ai/scripts/`（複製自 ai/）|
| 角色 .env | `{projectRoot}/{role_id}/ai/.env` |

---

## 重新執行 Setup

使用者可從系統設定頁（Section 11）手動觸發 Project Setup Wizard。  
所有操作均冪等，可安全重新執行（重新 bootstrap、重新 clone、重新產生 .env）。

---

## 注意事項

- **Admin Token 安全性**：adminToken 儲存於 `{projectRoot}/.osw_myai/config.json`（本地 JSON）。日後可考慮改用 macOS Keychain，但目前先以 JSON 儲存（見 decisions/260317_005_AppBootstrap.md）。
- **Setup 與匯入角色的順序**：匯入角色對話框（系統設定頁 Section 4）只在 setup 完成後（`{projectRoot}/ai/prompts/` 存在）才允許操作。
