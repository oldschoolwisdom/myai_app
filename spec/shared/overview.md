# MyAi — 產品總覽

> 版本：v0.1.0
> 日期：2026-03-12

---

## 產品定義

MyAi 是一個**本地端執行的 AI IDE**，以 Flutter 桌面 App 作為操作介面，透過本地 OSW-MyAI-Agent 串接 GitHub Copilot CLI，讓使用者能在本機環境中進行 AI 輔助的開發工作。

---

## 目標平台

| 平台 | 狀態 |
|------|------|
| macOS | 主要目標 |
| Windows | 目標 |
| Linux | 目標 |

> 不支援 iOS / Android / Web。

---

## 高階架構

```
Flutter Desktop App（UI 層）
        ↓  HTTP / WebSocket（本地 localhost:7788）
Go OSW-MyAI-Agent（AI 後端）
    內嵌 GitHub Copilot Go SDK
    實作 Tool Execution（bash、檔案操作，sandbox 限制在 work_dir）
    管理多角色 Agent Loop
        ↓  HTTPS（Go Copilot SDK）
GitHub Copilot API（AI 引擎）
```

### 各層職責

| 層 | 說明 |
|----|------|
| **Flutter App** | 使用者介面，IDE 操作畫面；呼叫 OSW-MyAI-Agent API；管理角色設定 |
| **Go OSW-MyAI-Agent** | 管理各角色 session；執行 Agent Loop（AI → tool call → 執行 → 回饋）；實作工具執行 sandbox；路由角色間通知；推播狀態 |

> **注意**：Copilot CLI 不再是必要依賴（見 decisions/260313_004_RemoveCLIDependency.md）

---

## 認證

- **認證由 Copilot CLI 管理**：使用者透過 `gh auth login` 或 `copilot` CLI 登入，憑證由 CLI 本身儲存。
- **Flutter App 不直接處理 GitHub OAuth**：認證狀態由 Local OSW-MyAI-Agent 向 CLI 查詢後回傳給 App。
- **BYOK 支援**：使用者可設定自己的 LLM API key（OpenAI / Azure / Anthropic），不需要 GitHub 訂閱。

---

## 關鍵外部相依

| 元件 | 說明 |
|------|------|
| GitHub Copilot Go SDK | Go library，內嵌於 OSW-MyAI-Agent，處理 Copilot API 通訊 |
| GitHub Copilot 訂閱 | 標準模式必要；BYOK 模式不需要 |

> GitHub Copilot CLI 不再是必要依賴。
