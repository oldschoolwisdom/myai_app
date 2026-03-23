# 260312_002 — 桌面平台架構與認證調整

> 日期：2026-03-12
> 影響範圍：spec/shared/overview.md、spec/server/overview.md、spec/app/tech_stack.md

---

## 背景

確立 MyAi 的核心產品定義：一個本地端執行的 AI IDE，透過 Copilot SDK 與 Copilot CLI 溝通。原技術選型草稿設計目標為 iOS / Android / Web 三平台，並以 Keycloak PKCE 作為認證機制。

## 問題

1. Copilot CLI 在本地執行，只有桌面環境才有意義；行動端不適用
2. Copilot SDK 沒有 Dart 版本，Flutter 無法直接呼叫，需要橋接層
3. Keycloak 在本專案沒有角色，認證由 Copilot CLI 本身管理

## 候選方案（橋接層通訊）

| 方案 | 說明 |
|------|------|
| A：stdio（spawn CLI process 直接溝通） | Flutter 直接 spawn Copilot CLI，省略 SDK |
| B：Flutter 透過 Dart FFI 呼叫 Go SDK | 技術複雜，維護成本高 |
| C：Local HTTP/WebSocket Server（本決策） | SDK 包成本地 server，Flutter 透過 HTTP/WebSocket 溝通 |

## 決定

### 平台
目標調整為 **macOS + Windows + Linux（桌面三平台）**，不支援 iOS / Android / Web。

### 橋接架構
採用**方案 C**：

```
Flutter App → HTTP / WebSocket → Local SDK Server → JSON-RPC → Copilot CLI
```

- Local SDK Server 封裝 Copilot SDK（語言由 server 角色決定）
- SDK Server 管理 CLI process 生命週期
- Flutter 透過 HTTP（REST）與 WebSocket 溝通 SDK Server

### 認證
- 移除 Keycloak / flutter_appauth / flutter_secure_storage
- 認證由 Copilot CLI 管理（`gh auth login` 或 `copilot` CLI login）
- BYOK（自帶 API key）亦支援，不需要 GitHub 訂閱

## 取捨理由

- Local server 模式讓 SDK 選型（Node.js / Go / Python）與 Flutter 解耦，未來可獨立升級
- HTTP/WebSocket 是 Flutter 桌面端最成熟的本地 IPC 選項，無需 FFI 或 platform channel 複雜度
- 認證委由 CLI 管理，避免在 App 層重複處理 OAuth 流程，符合 Copilot SDK 設計意圖

## 影響範圍

- `spec/shared/overview.md`：新增，記錄產品定義與高階架構
- `spec/server/overview.md`：新增，記錄 SDK Server 職責與協定
- `spec/app/tech_stack.md`：移除 Keycloak / health，新增 web_socket_channel，更新平台說明
