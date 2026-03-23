# 260315_001 — App 啟動流程、Project Root 偵測、Binary 路徑規則

> 日期：2026-03-15  
> 狀態：已決定  
> 關聯：spec/app/screens/main_ide.md（啟動流程章節）、spec/app/screens/settings.md（SDK Server section）  
> 觸發：Request #9

---

## 背景

App 的核心功能之一是自動啟動 Go SDK Server binary，並進行 POST /configure + WebSocket 連線。  
啟動流程涉及三個需要決策的問題：

1. **Project root** 如何正確偵測（在 macOS App sandbox 中 `Directory.current` 不可靠）
2. **SDK Server binary 路徑**的優先序與設定方式
3. **降級行為**：Server 無法啟動時 App 應該怎麼做

---

## 問題一：Project Root 偵測

### 候選方案

| 方案 | 說明 | 問題 |
|------|------|------|
| A：`Directory.current.path` | 最簡單 | macOS sandbox 下 CWD 是 Container 路徑，不是專案目錄 |
| B：`Platform.executable` 向上兩層 | 開發時有效 | 依賴 build 目錄結構，不穩定 |
| C：走訪 `Platform.executable` 向上，找到含 `server/` + `ai/` 的目錄 | 通用性最高 | 稍微複雜 |
| D：絕對路徑寫死 | 最簡單 | 無法跨機器使用 |

### 決定

**採用方案 C**：從 `Platform.executable` 開始向上查找目錄，找到同時包含 `server/` 子目錄與 `ai/` 子目錄的最近祖先目錄作為 project root。

備援鏈：`executable 向上查找` → `Directory.current.path 向上查找` → 最後回退到 `executable 兩層父目錄`。

### 取捨理由

- App sandbox 下 `Directory.current` 指向 Container，但 `Platform.executable` 仍指向真實的 build 產出路徑
- 以 `server/` + `ai/` 共存作為識別條件，避免找到錯誤的父目錄
- 備援鏈確保在非 sandbox 環境（如 CI、直接執行 binary）也能工作

---

## 問題二：SDK Server Binary 路徑優先序

### 候選方案

| 優先序 | 來源 | 說明 |
|--------|------|------|
| 1（最高）| App 設定畫面使用者輸入 | 記憶體中，重啟後消失 |
| 2 | `.env` 的 `AI_SERVER_BINARY` 欄位 | 持久化於磁碟 |
| 3（最低）| `$projectRoot/server/code/sdk-server` | 預設值 |

### 決定

**採用以上三層優先序**。設定畫面的路徑覆寫**不**寫回磁碟，僅在記憶體中生效。  
若需永久覆寫，使用者應修改 `.env` 的 `AI_SERVER_BINARY`。

### 取捨理由

- 開發期間可能需要臨時換 binary 測試，不想污染 `.env`
- App 本身不維護獨立設定檔（見 decisions/260312_001_NoDBNoSync.md），設定持久化依賴 `.env`
- 簡化 App 設定層：目前只有 binary 路徑需要覆寫，不值得引入額外持久化機制

---

## 問題三：降級行為（Server 不可用）

### 候選方案

| 方案 | 說明 | 問題 |
|------|------|------|
| A：離線 demo 模式（假資料）| 讓使用者看到 UI | 維護成本高，假資料容易與真實行為脫節 |
| B：空狀態 + 提示修正 | 未連線時顯示空角色清單 | UI 看起來「壞掉」，但誠實 |
| C：啟動序列診斷日誌 + 手動重連 | 告訴使用者哪裡出錯 | 需要實作診斷日誌 |

### 決定

**採用方案 B + C**：不提供假資料。  
Server 不可用時：
- 主畫面顯示空狀態（無角色）
- TopBar 顯示「未連線」+ 連線按鈕
- 設定畫面顯示診斷日誌（每個啟動步驟的成功 / 失敗記錄）
- 使用者可修改 binary 路徑後手動重連

### 取捨理由

- MyAi 目標使用者是開發者，不需要離線 demo
- 診斷日誌讓使用者可以快速定位問題（binary 不存在、sandbox 阻擋、port 被佔用等）
- 簡化 App 實作，不維護 mock 資料

---

## 影響範圍

| 檔案 | 變更 |
|------|------|
| `spec/app/screens/main_ide.md` | 新增「App 啟動流程」與「連線狀態管理」章節 |
| `spec/app/screens/settings.md` | 新增 Section 1（連線狀態）、Section 2（SDK Server）|
| `code/lib/providers/app_startup_provider.dart` | 實作上述三項決策（已完成）|
| `code/macos/Runner/DebugProfile.entitlements` | `app-sandbox = false`（已完成，見 PR history）|
