# 260313_003 — Server 架構：Go 進程管理器 + 角色間通知路由

> 日期：2026-03-13
> 影響範圍：spec/server/overview.md、spec/shared/overview.md

---

## 背景

原有 `spec/server/overview.md` 僅有高層概述，實作語言與通訊架構均為 TBD。  
本次決策討論確立了 SDK Server 的完整架構。

---

## 問題

1. SDK Server 的實作語言選哪個？
2. SDK Server 與 Copilot CLI 的通訊方式？
3. 多個 AI 角色如何管理？
4. 角色間如何即時通知彼此有新任務？
5. SDK Server 如何知道要管理哪些角色？

---

## 候選方案與決定

### 問題 1：實作語言

| 方案 | 說明 |
|------|------|
| Node.js | Copilot SDK 最成熟，但需附帶 Node runtime（~50-80MB）|
| **Go（本決策）** | 編譯成單一 native binary，零 runtime 依賴，跨平台打包最乾淨 |
| Python | 生態豐富，但打包體積肥、啟動較慢 |

**決定：Go**

取捨理由：本產品為桌面 App，需隨 Flutter App 一起打包到三個平台（macOS / Windows / Linux）。Go 的單一 binary 特性最符合這個需求，避免用戶環境需要預裝 runtime。

---

### 問題 2：SDK Server ↔ Copilot CLI 通訊

**決定：透過 GitHub Copilot Go SDK（library）管理 CLI session**

SDK Server 使用 Go 語言，內嵌 GitHub Copilot 官方 Go SDK library。SDK 負責管理 Copilot CLI session 的生命週期，並以 JSON-RPC 與 CLI 通訊（協定細節由 SDK 封裝，開發者使用 SDK API 即可）。

架構仍為三層：App ↔ Go Server（內嵌 Go SDK）↔ Copilot CLI。SDK 是 library，不是獨立進程或部署單元。

---

### 問題 3：多角色管理

**決定：每個角色一個獨立 CLI 進程**

| 方案 | 說明 |
|------|------|
| 共用一個 CLI 進程 | 輕量，但需複雜的 session/context 管理 |
| **每角色一進程（本決策）** | 完全隔離，進程崩潰不影響其他角色；狀態管理簡單 |

---

### 問題 4：角色間即時通知

**決定：角色呼叫 SDK Server HTTP API，由 Server 路由**

流程：
1. 角色 A 的 CLI 進程寫入 Forgejo Issue（持久紀錄）
2. 角色 A 呼叫 `POST /roles/{target_id}/notify`（即時觸發）
3. SDK Server 路由通知至角色 B 的 CLI 進程 stdin
4. 角色 B 開始處理

Forgejo Issues 是非同步持久紀錄；SDK Server 是即時路由層。兩者並存，互補不重複。

**未採用：Forgejo polling**  
SDK Server 定時 polling Forgejo 效率低且有延遲；由角色主動通知更即時、更可控。

**未採用：Forgejo webhook**  
本機部署環境不一定有公開 IP，webhook 不適用。

---

### 問題 5：角色清單來源

**決定：App 讀取 `.env` 後 POST 給 SDK Server**

- App 從本地 `.env` 讀取角色設定（id、prompt 路徑、工作目錄、模型）
- 啟動時呼叫 `POST /configure` 傳給 SDK Server
- SDK Server 依此啟動各角色 CLI 進程

未採用「Server 自行掃描 prompts 目錄」方案，因為 Server 不應該有關於 App 設定位置的假設；由 App 作為設定的唯一來源更符合單一責任原則。

---

## 影響範圍

- `spec/server/overview.md`：重寫為完整架構規格
- `spec/shared/overview.md`：高階架構圖需更新（架構由 JSON-RPC SDK 改為 stdin/stdout 進程管理）
- 未來 `spec/server/api.md`：待 server 角色開始實作時建立完整 API 文件
