# 260317_007 — Bootstrap Template 驅動架構

**日期**：2026-03-17  
**提出者**：spec（設計討論）  
**影響範圍**：`app/screens/project_setup.md`、`shared/workspace_config.md`

---

## 背景

`project_setup.md` Phase 2 原本硬編碼角色清單（`spec`, `app`, `server`, `data`, `qa`, `ops`）。  
隨著 bootstrap 設計演進，需要支援不同的 ai template repo（不同專案有不同角色組合），  
因此改為由 ai repo 中的 `roles.yaml` 動態定義角色集合，取代硬編碼。

同時確立：
- `ai/prompts/` 目錄的命名慣例（區分共用 vs 角色專屬 prompt）
- 角色 token 的唯一儲存位置

---

## 候選方案

### 方案 A：硬編碼角色清單（舊作法）
- App 程式碼內固定 6 個角色
- 新增角色需改動 App

### 方案 B：roles.yaml（template 驅動）
- ai repo 作為 template，包含 `roles.yaml`
- App 讀取 `roles.yaml` 動態產生 bootstrap 步驟
- 支援任意角色組合，無需改 App

---

## 決定採用方案 B。

---

## roles.yaml Schema

**位置**：`{projectRoot}/ai/roles.yaml`（App 在 Phase 1 從 template URL 讀取）

```yaml
- role_id: spec
  role_account: osw-myai-spec        # Forgejo 帳號名（issue assign / @mention 對象）
  role_repo: spec                    # Forgejo repo 名稱（org 內）
  role_repo_ref: ""                  # seed template git URL（選填，留空不 seed）
  prompt_file: osw-spec.md           # ai/prompts/ 下的角色 prompt 檔名
  description: 規格管理              # 人類可讀說明（UI 顯示用）
  builtin: false                     # true = 不建 Forgejo repo/account（如 dispatcher）
  ref_repos: ["ai", "spec"]          # 角色需要唯讀 clone 的 repo 清單
```

### 欄位說明

| 欄位 | 型別 | 必填 | 說明 |
|------|------|------|------|
| `role_id` | string | ✅ | 角色識別字（小寫），作為目錄名 |
| `role_account` | string | ✅ | Forgejo 帳號名，issue assign 與 @mention 的唯一對象 |
| `role_repo` | string | ✅ | Forgejo repo 名稱；`builtin: true` 時留空字串 |
| `role_repo_ref` | string | — | 初始 seed 的 git URL；留空不 seed |
| `prompt_file` | string | ✅ | `ai/prompts/` 下的 prompt 檔名 |
| `description` | string | ✅ | UI 顯示用的人類可讀說明 |
| `builtin` | boolean | ✅ | `true` → App 不建立 Forgejo repo 與帳號 |
| `ref_repos` | string[] | ✅ | 角色啟動時需唯讀 clone 的 repo 清單 |

---

## ai/prompts/ 命名慣例

```
ai/prompts/
├── common_01.md        ← 共用 prompt（注入給所有角色），按檔名升序排列
├── common_02.md        ← 多個共用 prompt 依序合併
├── dispatcher.md       ← dispatcher 角色（builtin: true）
└── osw-spec.md         ← 角色專屬 prompt（對應 roles.yaml[n].prompt_file）
```

### 規則

| 命名模式 | 用途 | App 行為 |
|---------|------|---------|
| `common_*.md` | 共用，注入所有角色 | 掃描 `ai/prompts/common_*.md`，按檔名升序排列後合併注入每個角色 |
| `dispatcher.md` | dispatcher 內建角色 | 固定讀取（對應 `builtin: true` 的 dispatcher entry） |
| 其他 `.md` | 角色專屬 | 僅由 `roles.yaml[n].prompt_file` 指定，不自動掃描 |

**App 掃描時只識別上述兩個命名模式，其他 `.md` 檔不自動處理。**

---

## Token 儲存

角色 token **唯一存放於** `{projectRoot}/.osw_myai/config.json` → `roleTokens`。  
不使用 `.env` 或任何其他檔案存放角色 token。

---

## 取捨與影響

| 面向 | 說明 |
|------|------|
| Bootstrap 耦合 | App 不再對角色清單有任何硬編碼，改為完全 data-driven |
| Template 彈性 | 任何 git repo 只要包含 `roles.yaml` 即可作為 bootstrap template |
| Token 唯一性 | 消除 `.env` 中分散的 `SPEC_TOKEN`、`APP_TOKEN` 等環境變數 |
| ai repo 職責 | ai repo = template（包含 `roles.yaml` + `prompts/` + `scripts/`） |
| prompt 分發 | Phase 3 從「複製整個 prompts/」改為「依角色選擇性分發」 |
