# 260317_005 — App 整合 Bootstrap + Setup 流程

> 日期：2026-03-17  
> 狀態：已採納  
> 影響範圍：shared/workspace_config.md、shared/roles.md、app/screens/project_setup.md（新增）、app/screens/system_status.md

---

## 背景

app 角色 Request #28 請求將 `bootstrap-forgejo.sh` 與 `setup.sh` CLI 流程整合進 App GUI，並提出 5 個需要裁決的設計問題。

---

## 決定

### Q1. App 角色定位

**裁決：App 是全功能管理介面。**

Bootstrap（建立 Forgejo org / repo / 帳號 / team / labels）與 Local Setup（git clone repos + 產生 .env）均在 App 內執行。  
目標是讓 App 成為 OSW-MyAI 系統的唯一管理介面，無需手動執行 CLI 腳本。

> 取捨：讓 Admin 操作進 App 增加了複雜度，但換來的是零 CLI 依賴的完整使用體驗。

---

### Q2. Forgejo 連線設定放在哪裡

**裁決：擴充 `~/.osw_myai/config.json`，新增 `forgejo` 區塊。**

不建立獨立的 ForgejoConfigService；WorkspaceConfigService 統一管理全局設定。

新增欄位：
```json
{
  "workspace": "...",
  "forgejo": {
    "baseUrl": "https://git.example.com",
    "orgName": "my-org",
    "adminToken": "admin-personal-access-token"
  },
  "roleTokens": {
    "spec": "token_for_spec",
    "app": "token_for_app"
  }
}
```

> 取捨：将 adminToken 存在本地 JSON 有安全風險，但對本地桌面工具而言是可接受的做法（與 .env 相當）。日後可改為 macOS Keychain。

---

### Q3. git clone 在 App 內執行

**裁決：Spec 層面不限制；App 角色負責解決技術細節。**

規格要求 App 能執行 `git clone <url> <path>`，具體實作（subprocess / 原生 library / shell script）由 app 角色自行決定。macOS 非沙盒 Flutter Desktop app 通常不受限。

---

### Q4. Prompt 來源

**裁決：維持選項 A（本地掃描），不引入 Forgejo API 下載。**

Setup 流程會確保 `{projectRoot}/ai/` repo 已 clone 至本地，因此 `{projectRoot}/ai/prompts/` 掃描路徑在 setup 完成後一定可用。

匯入角色對話框：只在 setup 完成後（ai/ 已 clone）才允許進入。若 setup 未完成，對話框顯示提示引導使用者先完成 setup。

> 取捨：避免引入 Forgejo API 整合複雜度；缺點是需要先完成 setup 才能匯入角色，但這符合預期使用流程。

---

### Q5. Tokens 儲存

**裁決：儲存在 `~/.osw_myai/config.json` 的 `roleTokens` 欄位。**

不使用 `{workspace}/ai/.env`，理由：
- config.json 已是全域設定的統一入口
- .env 是 AI 角色執行時讀取的環境設定，與使用者設定分離更清晰

---

## 影響範圍

- `shared/workspace_config.md` v1.1.0：新增 forgejo + roleTokens 欄位定義
- `shared/roles.md` v2.2.0：匯入流程 step 6 改為 App 執行 git clone
- `app/screens/project_setup.md` v1.0.0：新增 Project Setup Wizard 規格
- `app/screens/system_status.md` v1.8.0：新增 Section 11 Forgejo 連線設定
