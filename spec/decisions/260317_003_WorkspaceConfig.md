# 260317_003 — Workspace 全域設定：以 ~/.osw_myai/config.json 取代啟發式路徑偵測

> 日期：2026-03-17  
> 狀態：已採納  
> 影響範圍：`shared/workspace_config.md`（新增）、`app/screens/main_ide.md`、`app/screens/system_status.md`

---

## 背景

App 原本以啟發式方式解析 projectRoot：從 `Platform.executable` 路徑往上爬，找到同時包含 `server/` 和 `ai/` 的目錄，備援為 `Directory.current.path`。

此方式在以下情境不穩定：
- 從不同入口點啟動 App（IDE、命令列、Finder double-click）
- Executable 路徑隨建置環境變化
- 未來支援多個 workspace 的擴充難度高

App 角色（commit db72597）已實作以 `~/.osw_myai/config.json` 儲存 workspace 路徑的方案，並補充規格請求（Request #26）。

---

## 候選方案

### 方案 A：啟發式偵測（原做法）
從 executable 往上查找，尋找包含特定子目錄的 parent。

**問題**：依賴固定目錄結構（`server/`、`ai/`）；不同啟動方式結果不一；難以支援多 workspace。

### 方案 B：環境變數
以 `MYAI_WORKSPACE` 環境變數指定 projectRoot。

**問題**：桌面 App 使用環境變數體驗差；使用者難以設定與驗證。

### 方案 C：全域設定檔（本次採納）
將 workspace 路徑儲存於 `~/.osw_myai/config.json`，App 啟動時讀取。首次未設定時顯示 WorkspaceSetupPage 引導使用者選擇。

---

## 決定

採用方案 C：**`~/.osw_myai/config.json` 全域設定檔**。

- 格式：`{"workspace": "/path/to/myai"}`
- App 啟動 Step 0：讀取 config.json → 未設定則進入 WorkspaceSetupPage → 設定後繼續啟動序列
- 移除舊的 Step 2（啟發式 Platform.executable 偵測）
- 系統設定頁新增 Workspace section，提供「變更」按鈕

---

## 取捨理由

| 考量 | 說明 |
|------|------|
| 穩定性 | 不依賴啟動路徑或目錄結構，任何啟動方式結果一致 |
| 使用者可見 | config.json 位置固定，使用者可直接查看或手動修改 |
| 可擴充 | 未來若支援多 workspace，只需擴充 config.json 格式 |
| 首次使用體驗 | WorkspaceSetupPage 明確引導，比無聲失敗更好 |

---

## 影響範圍

- `shared/workspace_config.md`：新增，定義全域設定檔格式、projectRoot 來源、讀取邏輯、WorkspaceSetupPage 規格
- `app/screens/main_ide.md`：啟動流程新增 Step 0（workspace 設定），移除原 Step 2（啟發式偵測），步驟重新編號
- `app/screens/system_status.md`：新增 Section 6 Workspace，舊 Section 6–9 順延為 7–10；main_ide.md 中的 Section 8 常用語引用更新為 Section 9
