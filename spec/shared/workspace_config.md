# Workspace 設定檔架構

> 版本：v1.4.0  
> 日期：2026-03-18  
> 來源：Request #26（v1.0.0）、Request #28（v1.1.0）、Request #30（v1.2.0 重構為雙層架構）、decisions/260317_007_BootstrapTemplate.md（v1.3.0）、補充 roles.yaml（v1.4.0）  
> 決策：decisions/260317_006_ConfigSplit.md、decisions/260317_007_BootstrapTemplate.md

---

## 概覽

設定檔分為兩層：**全域層**（記錄最後開啟的 workspace）與 **Workspace 層**（專案相關設定）。  
`roles.yaml` 是 workspace 的角色定義來源，隨 ai template repo 一起存在於 `{projectRoot}/ai/`。

```
~/.osw_myai/
└── default.json              ← 全域：最後開啟的 workspace 路徑

{workspace}/
├── .osw_myai/
│   └── config.json           ← 專案：Forgejo 設定、角色 tokens
└── ai/
    └── roles.yaml            ← 角色定義：角色清單、帳號、repo、prompt 對應
```

---

## 全域設定：`~/.osw_myai/default.json`

| 項目 | 值 |
|------|-----|
| 路徑 | `~/.osw_myai/default.json` |
| 建立時機 | App 首次啟動時，若 `~/.osw_myai/` 不存在則自動建立 |

### 格式

```json
{
  "lastWorkspace": "/Users/username/projects/myai"
}
```

### 欄位說明

| 欄位 | 型別 | 說明 |
|------|------|------|
| `lastWorkspace` | string | 最後開啟的 workspace 絕對路徑（即 `projectRoot`）；首次啟動時為 null |

---

## Workspace 設定：`{workspace}/.osw_myai/config.json`

| 項目 | 值 |
|------|-----|
| 路徑 | `{projectRoot}/.osw_myai/config.json` |
| 建立時機 | Project Setup Wizard Phase 1 完成後；或 Bootstrap 寫入 roleTokens 時 |

### 格式

```json
{
  "forgejo": {
    "baseUrl": "https://git.example.com",
    "orgName": "my-org",
    "adminToken": "admin-personal-access-token"
  },
  "aiTemplateRepoUrl": "https://git.example.com/my-org/ai",
  "roleTokens": {
    "spec": "token_for_spec_role",
    "app": "token_for_app_role"
  }
}
```

### 欄位說明

| 欄位 | 型別 | 說明 |
|------|------|------|
| `forgejo.baseUrl` | string | Forgejo 伺服器 URL（不含 `/api/v1`）|
| `forgejo.orgName` | string | OSW-MyAI 使用的 Forgejo organization 名稱 |
| `forgejo.adminToken` | string | 具有管理員權限的 Forgejo Personal Access Token（用於 bootstrap）|
| `aiTemplateRepoUrl` | string | ai repo 的 git URL，作為 bootstrap template 來源；由 Project Setup Wizard Phase 1 寫入 |
| `roleTokens` | object | 各角色的 Forgejo API token（map: `roleId → token`）；由 bootstrap 自動填入。**唯一的角色 token 儲存位置，不使用 `.env` 或其他檔案。** |

---

## 角色定義：`{projectRoot}/ai/roles.yaml`

| 項目 | 值 |
|------|-----|
| 路徑 | `{projectRoot}/ai/roles.yaml` |
| 來源 | ai template repo（由 Project Setup Wizard Phase 1 clone 下來） |
| 讀取時機 | Bootstrap Phase 2 啟動前；App 啟動時讀取角色清單 |

### 格式

```yaml
- role_id: spec
  role_account: osw-myai-spec
  role_repo: spec
  role_repo_ref: ""
  prompt_file: osw-spec.md
  description: 規格管理
  builtin: false
  ref_repos: ["ai", "spec"]
```

### 欄位說明

| 欄位 | 型別 | 必填 | 說明 |
|------|------|------|------|
| `role_id` | string | ✅ | 角色識別字（小寫），作為目錄名與 roleTokens key |
| `role_account` | string | ✅ | Forgejo 帳號名，issue assign 與 @mention 的唯一對象 |
| `role_repo` | string | ✅ | Forgejo repo 名稱；`builtin: true` 時為空字串 |
| `role_repo_ref` | string | — | 初始 seed 的 git URL；留空不 seed |
| `prompt_file` | string | ✅ | `ai/prompts/` 下的 prompt 檔名 |
| `description` | string | ✅ | UI 顯示用的人類可讀說明 |
| `builtin` | boolean | ✅ | `true` → App 不建立 Forgejo repo 與帳號（如 dispatcher） |
| `ref_repos` | string[] | ✅ | 角色啟動時需唯讀 clone 的 repo 清單 |

> Schema 的設計決策詳見 `decisions/260317_007_BootstrapTemplate.md`。

---

## `projectRoot` 定義

`projectRoot` 為 `~/.osw_myai/default.json` 中 `lastWorkspace` 欄位的值。

所有規格中出現的 `{projectRoot}` 均指此路徑，例如：
- `{projectRoot}/myai.env`
- `{projectRoot}/ai/prompts/`
- `{projectRoot}/ai/roles.yaml`（角色定義）
- `{projectRoot}/{role_id}/code`（角色 work_dir）
- `{projectRoot}/.osw_myai/config.json`（workspace 專案設定）

---

## 讀取邏輯

```
App 啟動 Step 0
  ├── 讀取 ~/.osw_myai/default.json
  │     若 ~/.osw_myai/ 不存在 → 建立目錄
  │     若 lastWorkspace 為空 → phase = needsWorkspace → 顯示 WorkspaceSetupPage（阻斷後續步驟）
  │     若 lastWorkspace 存在 → projectRoot = lastWorkspace
  │                           → 讀取 {projectRoot}/.osw_myai/config.json（不存在時為空物件）
  │
  └── 繼續啟動序列（Step 0b 工具檢查...）
```

---

## WorkspaceSetupPage

首次啟動或 `lastWorkspace` 未設定時顯示，取代主畫面。

| 項目 | 說明 |
|------|------|
| 說明文字 | 「請選擇 myai 專案的根目錄。選擇後設定將儲存至 ~/.osw_myai/default.json。」|
| 「選擇目錄」按鈕 | 開啟原生 macOS 資料夾選擇對話框 |
| 選定後行為 | 寫入 `~/.osw_myai/default.json` → 設定 `projectRoot` → 繼續啟動序列 |
| 目錄驗證 | 不驗證目錄內容（選定即接受）|

---

## 變更 workspace

使用者可在系統設定頁（`/status`）的 Workspace section 更改：

- 顯示目前 `projectRoot` 路徑
- 「變更」按鈕 → 開啟資料夾選擇對話框 → 寫入 `~/.osw_myai/default.json` → 讀取新 workspace 的 `.osw_myai/config.json` → 重新執行 `initialize()`

