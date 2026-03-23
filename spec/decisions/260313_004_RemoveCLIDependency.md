# 260313_004 — 移除 Copilot CLI 依賴，Go Server 直接整合 Go SDK + Tool Execution

> 日期：2026-03-13
> 影響範圍：spec/server/overview.md、spec/shared/overview.md

---

## 背景

原架構（v0.2）假設：App ↔ Go Server（Go Copilot SDK）↔ Copilot CLI ↔ GitHub API。  
在架構討論中，提出了一個問題：**既然已使用 Go Copilot SDK，為什麼還需要獨立的 Copilot CLI？**

---

## 問題

1. Go SDK 能否直接呼叫 Copilot API，不透過 CLI？
2. 若移除 CLI，工具執行（bash、檔案操作）由誰負責？
3. 移除 CLI 後，如何確保安全性？

---

## 候選方案

| 方案 | 說明 | 優點 | 缺點 |
|------|------|------|------|
| A：保留 CLI | Go SDK 管理 CLI session，CLI 負責 tool execution | 不需自行實作工具層 | 需預裝 CLI；打包複雜；多一層依賴 |
| **B：移除 CLI（本決策）** | Go SDK 直呼 Copilot API，Server 自實作 tool execution | 純 Go binary，零外部依賴；更可控 | 需自行實作工具執行層 |

---

## 決定

**移除 Copilot CLI 依賴，架構改為兩層：**

```
App ↔ Go Server（Go Copilot SDK + Tool Execution）↔ Copilot API
```

Go Server 新增：
- **Agent Loop**：呼叫 Copilot API → 解析 tool call → 執行工具 → 結果回饋 → 重複直到完成
- **Tool Execution 層**：bash 執行、檔案讀取/寫入
- **Sandbox**：每個角色的工具執行限制在自己的 `work_dir`，禁止跨目錄操作

---

## 取捨理由

- 移除 CLI 後打包只需一個 Go binary，用戶不需預裝任何 runtime 或 CLI 工具
- Go Server 自行管理 agent loop 對角色狀態追蹤更精確（知道哪個步驟在執行）
- Tool execution sandbox（work_dir 限制）提供基本安全隔離，符合「先用目錄限制，工具種類限制待後續」的需求
- 代價是 Go Server 需要實作工具執行層，但這是標準功能，不是特殊技術

---

## 影響範圍

- `spec/server/overview.md`：全面更新為 v0.3.0
- `spec/shared/overview.md`：高階架構圖更新（移除 CLI 層）
- **外部依賴移除**：GitHub Copilot CLI 不再是必要安裝項目
- **新增關鍵外部相依**：GitHub Copilot Go SDK（library）
- 未來 `spec/server/api.md`：需補充 agent loop 設計細節與支援工具清單

---

## 待確認

| 項目 | 說明 |
|------|------|
| Go SDK tool calling API | 待 server 角色確認 Go SDK 的 tool calling 介面 |
| 支援工具清單 | bash / 檔案讀寫已確認；其他工具（HTTP 呼叫等）待後續決策 |
| BYOK key 傳遞 | App → Server 的 API key 傳遞方式待定 |
