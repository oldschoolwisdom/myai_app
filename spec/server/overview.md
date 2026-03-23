# MyAi — Local OSW-MyAI-Agent 規格

> 版本：v0.8.0
> 日期：2026-03-16
> 修訂：2026-03-13（修正架構：SDK auto-embed CLI，Tool Execution 由 CLI 負責；確認 Go SDK 套件與認證方式，見 decisions/260313_005_GoSDKPackage.md）
> 修訂：2026-03-14（API 節拆出為獨立 api.md，補齊 DELETE /roles/{id} 與所有端點錯誤規格，Request #8）
> 修訂：2026-03-16（新增 server.md 執行時規格，補充 startup flags / logging / panic recovery 參考，Request #17）
> 修訂：2026-03-16（新增 built-in role contract；dispatcher 可在缺少本地 prompt 檔時以內建 prompt 建立，Request #24）

---

## 職責

Local OSW-MyAI-Agent 是 Flutter App 的 AI 後端，負責：

1. 使用 `github.com/github/copilot-sdk/go` 管理 AI 會話（Session）
2. 管理多個 AI 角色的 session（對話狀態、system prompt）
3. 限制每個角色的工作目錄 sandbox（透過 `ClientOptions.Cwd`）
4. 路由角色間通知（角色 A 通知角色 B 有新任務）
5. 以 HTTP + WebSocket 暴露 API 給 Flutter App
6. 推播角色狀態與串流輸出給 App

> **Tool Execution 由 SDK 底層的 embedded CLI 負責**  
> Server 不需要自行實作 bash 執行或檔案操作；工具擴充透過 `SessionConfig.Tools` 定義。

---

## 實作語言

**Go**（見 decisions/260313_003_ServerArchitecture.md）

- 編譯成單一 native binary，無 runtime 依賴
- 跨平台（macOS / Windows / Linux）打包最乾淨
- 隨 Flutter App 一起打包發布

---

## 高階架構

```
Flutter App
    │  HTTP（設定、查詢）
    │  WebSocket（串流輸出、狀態推播）
    ▼
Go OSW-MyAI-Agent
    ├── Role Manager（角色管理）
    │       管理每個角色的 Session（system prompt、對話歷史）
    │       監控 session 健康、維護角色狀態
    │
    ├── Notification Router（通知路由）
    │       角色 A 呼叫 API → 路由通知給角色 B session
    │
    └── Status Tracker（狀態追蹤）
            idle / running / done / error（見 spec/shared/agent_status.md）
            透過 WebSocket 推播狀態變更給 App

    │  github.com/github/copilot-sdk/go（嵌入 Server 的 library）
    ▼
[SDK auto-managed embedded Copilot CLI]
    │  負責 Tool Execution（bash、檔案操作等）
    │  負責 Agent Loop（tool call → 執行 → 結果回饋 → 繼續）
    ▼
GitHub Copilot API（HTTPS）
```

> **說明**：Copilot CLI 由 SDK 自動安裝並管理，使用者不需要手動安裝。  
> 若使用 `go tool bundler`，CLI 會在 build 時打包進 binary（見 decisions/260313_005_GoSDKPackage.md）。

---

## 與舊架構的差異

| 項目 | 舊架構（v0.2） | 修訂後（v0.4） |
|------|--------------|--------------|
| Copilot CLI | 使用者需手動安裝 | SDK 自動管理（auto-embed）|
| Tool Execution | Server 自行實作 | CLI 內建，SDK 負責 |
| Agent Loop | Server 自行實作 | CLI 內建，SDK 負責 |
| Go SDK 套件 | 待定 | `github.com/github/copilot-sdk/go` |
| 認證：標準模式 | 待定 | `ClientOptions.GitHubToken`（App 傳入）|
| 認證：BYOK | 待定 | `SessionConfig.ProviderConfig.APIKey` |

---

## 通訊協定

| 方向 | 協定 | 說明 |
|------|------|------|
| App → OSW-MyAI-Agent | HTTP REST | 設定角色清單、查詢狀態、發送訊息 |
| App ↔ OSW-MyAI-Agent | WebSocket | 角色輸出串流、角色狀態即時推播 |
| OSW-MyAI-Agent → Copilot API | HTTPS（Go SDK）| 呼叫 AI、tool call 結果回饋 |
| 角色 session → OSW-MyAI-Agent | HTTP REST | 角色間通知路由 API |

---

## Tool Execution 安全規則

| 規則 | 說明 |
|------|------|
| 工作目錄限制 | 每個角色的 bash 執行與檔案操作限制在該角色的 `work_dir` 範圍內 |
| 跨目錄禁止 | 角色不得讀取或寫入其他角色的 `work_dir` |
| 工具種類限制 | 待後續規格補充 |

> 內建 `dispatcher` 的 `work_dir` 為 **project root**，因此可在 project root 範圍內跨 repo 協調；仍不得離開 project root。

---

## 角色設定

### 設定來源

Flutter App 在啟動時（或設定變更後）呼叫 `POST /configure`，提供角色清單與認證資訊。  
角色清單與 token 由 App 從本地設定檔（`.env`）讀取後組裝；其中角色清單 = **mandatory built-in roles + `ai/prompts/ltc-*.md` 掃描結果**。

### 認證模式

**標準模式（GitHub Copilot 帳號）**：

```json
{
  "auth": {
    "mode": "copilot",
    "github_token": "ghp_xxxx"
  },
  "roles": [...]
}
```

**BYOK 模式（自訂 API Provider）**：

```json
{
  "auth": {
    "mode": "byok",
    "provider": {
      "type": "openai",
      "base_url": "https://api.openai.com/v1",
      "api_key": "sk-xxxx"
    },
    "model": "gpt-4o"
  },
  "roles": [...]
}
```

> Server 接到 token 後，透過 `ClientOptions.GitHubToken`（標準模式）或 `SessionConfig.ProviderConfig`（BYOK）傳給 SDK。  
> Token 不寫入磁碟；App 重啟後需重新呼叫 `POST /configure`。

### 角色設定結構

```json
{
  "roles": [
    {
      "id": "dispatcher",
      "builtin_id": "dispatcher",
      "work_dir": "/path/to/project-root"
    },
    {
      "id": "spec",
      "prompt_path": "/path/to/ai/prompts/ltc-spec.md",
      "work_dir": "/path/to/spec",
      "model": "claude-sonnet-4.6"
    }
  ]
}
```

| 欄位 | 說明 |
|------|------|
| `id` | 角色唯一識別碼 |
| `builtin_id` | 內建角色識別碼；Phase 1 只定義 `dispatcher` |
| `prompt_path` | System prompt 檔案的本地絕對路徑；一般角色必填，built-in role 可省略 |
| `work_dir` | 該角色的工作目錄（SDK `Cwd`，限制 CLI 的工作範圍）；`dispatcher` 使用 project root |
| `model` | 使用的 AI 模型名稱（BYOK 模式必填）|

> 當 `builtin_id=dispatcher` 時，Server 必須支援 **內建 prompt fallback**：
> - `prompt_path` 缺漏 → 使用內建 `dispatcher` prompt
> - `prompt_path` 有值但檔案不存在 / 不可讀 → 記錄 warning，並回退至內建 `dispatcher` prompt
> 這可確保 dispatcher 不因本地 `dispatcher.md` 缺失而無法建立。

---

## API 規格

完整 API 文件（HTTP Endpoints + WebSocket 事件）見 **[api.md](api.md)**。  
執行時規格（啟動旗標、Logging、Panic Recovery）見 **[server.md](server.md)**。

端點清單：

| Method | Path | 說明 |
|--------|------|------|
| POST | `/configure` | 認證 + 角色清單設定 |
| GET | `/roles` | 取得所有角色狀態 |
| POST | `/roles/{id}/message` | 發訊息給角色（觸發 Agent Loop）|
| POST | `/roles/{id}/notify` | 角色間通知 |
| POST | `/roles/{id}/permission_response` | App 回應 permission request |
| DELETE | `/roles/{id}` | 停止並移除角色 |
| GET | `/auth/status` | 認證狀態查詢 |
| GET | `/ws` | WebSocket 連線（事件串流）|

---

## 啟動模式

- **隨 App 啟動**：Flutter App 負責啟動 OSW-MyAI-Agent process
- **本地監聽**：預設 `localhost:7788`，不對外暴露
- **單一 binary**：Go 編譯輸出，與 Flutter App 一起打包
- **版本耦合**：OSW-MyAI-Agent 與 Flutter App 一起發布

---

## 待定事項（TBD）

| 項目 | 說明 |
|------|------|
| Tool 種類清單 | CLI 內建工具以外，是否需要在 `SessionConfig.Tools` 定義自訂工具 |
| 本地 port 設定 | 預設 `7788`，是否允許 App 設定覆寫 |
