# 260317_004 — 改名：SDK Server → OSW-MyAI-Agent

> 日期：2026-03-17  
> 狀態：已採納  
> 影響範圍：所有非決策類 spec 文件（app/、server/、shared/）

---

## 背景

本地伺服器元件長期以「SDK Server」稱呼，但此名稱只描述了其技術實作細節（wraps the GitHub Copilot SDK），無法反映其實際角色定位：**本地 AI 代理的執行核心**。

App 角色提出改名請求（Request #27），建議改為 **OSW-MyAI-Agent**。

---

## 決定

採用 **OSW-MyAI-Agent** 作為正式名稱。

| 層 | 舊名稱 | 新名稱 |
|---|---|---|
| Spec 文件 / UI 顯示 | SDK Server | OSW-MyAI-Agent |
| Binary 檔名 | `sdk-server` | `osw-myai-agent` |
| App class 命名慣例 | `SdkServerService` | `OswMyaiAgentService` |

---

## 取捨理由

- **OSW-MyAI-Agent** 明確帶有品牌（OSW）與產品名（MyAI）
- 反映「AI Agent 執行核心」的角色定位，而非只是 SDK wrapper
- 與 repo 命名慣例（`osw-myai-*`）一致

> **注意**：決策紀錄（`decisions/`）保留歷史原文，不對舊決策文件做文字取代。

---

## 影響範圍

以下非決策類 spec 文件全文取代（`SDK Server` → `OSW-MyAI-Agent`、`sdk-server` → `osw-myai-agent`、`SdkServerService` → `OswMyaiAgentService`）：

- `app/screens/main_ide.md` v1.17.0
- `app/screens/system_status.md` v1.7.0
- `app/screens/settings.md`
- `app/tech_stack.md`
- `server/overview.md` v0.8.0
- `server/api.md` v1.7.0
- `server/server.md`
- `shared/agent_status.md`
- `shared/overview.md`

App、Server 程式碼的 class / binary 改名由各自角色依此規格更新。
