# 260313_005 — Go SDK 套件選型、認證方式與架構修正

## 背景

spec #4 由 `osw-myai-server` 發起，要求確認 Go SDK 的具體套件與認證方式。  
前一版本 `260313_004_RemoveCLIDependency.md` 宣稱「移除 CLI 依賴，Server 自行實作 Tool Execution」，  
但在實際查閱 `github/copilot-sdk` 的 Go 套件後發現此描述有誤，需要修正。

---

## SDK 調查結果

### 套件資訊

- **Import path**: `github.com/github/copilot-sdk/go`
- **Go module name**: `github.com/github/copilot-sdk/go`
- **安裝**: `go get github.com/github/copilot-sdk/go`
- **狀態**: Technical Preview（API 可能有 breaking changes）

### 重要發現：SDK 仍使用 CLI，但自動管理

SDK **並非直接呼叫 Copilot HTTP API**，而是在底層啟動/連接一個 Copilot CLI 程序。

> "When your application calls `copilot.NewClient` without a `CLIPath` nor the `COPILOT_CLI_PATH` environment variable,  
>  the SDK will automatically install the embedded CLI to a cache directory and use it for all operations."

選項：
1. **auto-embed**：SDK 自動安裝 embedded CLI 到 cache 目錄（預設行為）
2. **bundler 工具**：在 build 時執行 `go tool bundler` 將 CLI 打包進 binary
3. **連接現有 CLI server**：透過 `CLIUrl` 選項指向已執行的 CLI server

### 意義

- 使用者**不需要手動安裝** Copilot CLI
- 但 CLI **仍然存在於底層**（由 SDK 自動管理）
- Tool execution（bash、檔案操作等）由 CLI 負責，**不需要 Go Server 自行實作**
- `ClientOptions.Cwd` 可設定 CLI 的工作目錄（用於 sandbox 限制）

### 認證方式

**標準模式（GitHub Copilot 帳號）**：

```go
client := copilot.NewClient(&copilot.ClientOptions{
    GitHubToken: configuredToken, // App 透過 POST /configure 傳入
})
```

**BYOK 模式（自訂 API Provider）**：

```go
session, err := client.CreateSession(ctx, &copilot.SessionConfig{
    Model: "gpt-4",
    Provider: &copilot.ProviderConfig{
        Type:    "openai",          // "openai" / "azure" / "anthropic"
        BaseURL: "https://...",
        APIKey:  byokApiKey,        // App 透過 POST /configure 傳入
    },
})
```

### 核心 API 模式

```go
// 1. 建立 Client（整個 Server 生命週期共用一個）
client := copilot.NewClient(&copilot.ClientOptions{
    GitHubToken: token,
    Cwd: roleWorkDir, // sandbox：限制在角色工作目錄
})
client.Start(ctx)

// 2. 每個 AI 角色建立或恢復一個 Session
session, _ := client.CreateSession(ctx, &copilot.SessionConfig{
    Model:     "gpt-5",
    Streaming: true,
    Tools:     customTools, // 可擴充自訂工具
    OnUserInputRequest: handleAskUser, // 支援 ask_user tool
})

// 3. 傳送訊息（含 streaming 回應）
session.On(func(event copilot.SessionEvent) { ... })
session.Send(ctx, copilot.MessageOptions{Prompt: "..."})
```

---

## 候選方案

| 方案 | 說明 | 取捨 |
|------|------|------|
| A. `github/copilot-sdk/go` | 官方 SDK，技術預覽 | 功能完整、有 BYOK；Technical Preview，API 可能變動 |
| B. `sashabaranov/go-openai` | 社群 OpenAI 相容 wrapper | 穩定；不支援 GitHub Copilot 認證、Session 管理 |
| C. 直接呼叫 REST API | 自行實作 HTTP client | 最彈性；工程量大、需自行處理 tool calling、streaming |

---

## 決定

**採用 `github/copilot-sdk/go`（方案 A）**。

---

## 取捨理由

1. 這是 GitHub 官方 SDK，與 GitHub Copilot 帳號認證整合最完整
2. BYOK 支援（openai/azure/anthropic）符合產品需求
3. Tool execution、Session 管理、Streaming 均已內建，不需要自行實作
4. Technical Preview 狀態雖有 breaking change 風險，但目前無更好替代方案

---

## 架構修正（修訂 260313_004）

`260313_004_RemoveCLIDependency.md` 宣稱「架構改為兩層，完全移除 CLI」，  
此描述有誤，需要修正為：

**修正後架構**：
```
App ↔ Go Server（github/copilot-sdk/go）↔ [SDK 自動管理的 embedded CLI] ↔ Copilot API
```

**修正要點**：

| 項目 | 260313_004 描述（有誤） | 本決策修正後 |
|------|----------------------|------------|
| CLI 是否存在 | 已完全移除 | SDK 自動管理（auto-embed），使用者不需手動安裝 |
| Tool Execution | Go Server 自行實作 | CLI 的內建功能，SDK 透過 `Tools` 支援擴充 |
| 架構層數 | 兩層（App / Server） | 實質三層（App / Go Server+SDK / embedded CLI），但使用者視角仍為兩層 |

**保留不變的核心決策**：
- 使用者不需要手動安裝或管理 CLI（SDK 自動處理）
- 每個角色的工作目錄 sandbox 限制（`ClientOptions.Cwd`）
- Go 實作語言
- App 透過 `POST /configure` 傳遞 Token 給 Server

---

## 影響範圍

- `spec/server/overview.md` — 更新 SDK 套件名稱、認證方式、Tool Execution 說明，修正架構圖
- `spec/shared/overview.md` — 修正架構層次說明（SDK auto-embed CLI）
- server 角色 — 實作 `github.com/github/copilot-sdk/go`；不需實作 Tool Execution layer
