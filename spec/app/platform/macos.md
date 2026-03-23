# MyAi — macOS 平台設定規格

> 版本：v1.0.0
> 日期：2026-03-22
> 來源：spec#33（macOS 平台權限規格）、spec#32（App Sandbox entitlement）
> 決策：decisions/260322_001_macOSEntitlements.md

---

## 概覽

MyAi macOS App 啟用 App Sandbox，必須在 `entitlements` 明確宣告所有需要的平台能力。  
本文件列出所有必要的 Entitlements 與 Info.plist Usage Description，以及 Debug 與 Release 的差異。

---

## Entitlements

### 必要項目（Debug + Release）

| Entitlement | 用途 | 對應功能 |
|---|---|---|
| `com.apple.security.app-sandbox` | 啟用 App Sandbox | macOS 強制要求 |
| `com.apple.security.files.user-selected.read-write` | 使用者選擇的檔案/目錄讀寫 | `file_picker.getDirectoryPath()`（WorkspaceSetupPage、ImportRoleDialog、ProjectSetupWizard）|
| `com.apple.security.network.client` | 對外發起網路連線 | HTTP/WebSocket 連至 localhost:7788（OSW-MyAI-Agent）、Forgejo API |
| `com.apple.security.network.server` | 接受本地連線 | 接受來自 OSW-MyAI-Agent 的本地回連 |
| `com.apple.security.files.downloads.read-write` | 讀寫 Downloads 目錄（涵蓋設定檔） | 讀寫 `myai.env`、`.osw_myai/config.json` 等專案設定檔 |
| `com.apple.security.cs.disable-library-validation` | 停用 library 驗證 | 啟動 OSW-MyAI-Agent subprocess（未由同一 App 簽署）|

### Debug 專用項目

| Entitlement | 說明 |
|---|---|
| `com.apple.security.app-sandbox` | Debug Build 可改為 `false` 以簡化開發流程（見下方說明）|

> **Debug Build Sandbox 關閉**：將 `DebugProfile.entitlements` 中 `com.apple.security.app-sandbox` 設為 `false`，可讓 debug build 不受 sandbox 限制（方便開發時存取任意路徑）。Release build 必須保持 `true`。

---

## Info.plist Usage Description

| Key | 說明 | 顯示時機 |
|---|---|---|
| `NSDocumentsFolderUsageDescription` | App 需要存取文件資料夾以讀寫專案設定檔 | 首次存取文件資料夾時 |
| `NSDesktopFolderUsageDescription` | App 需要存取桌面資料夾以讀寫專案設定檔 | 首次存取桌面資料夾時 |
| `NSDownloadsFolderUsageDescription` | App 需要存取下載資料夾以讀寫專案設定檔 | 首次存取下載資料夾時 |

> macOS 的 Usage Description 為強制要求；若 App 嘗試存取相關資料夾但 Info.plist 缺少對應說明，macOS 會直接拒絕且不顯示權限對話框。

---

## OSW-MyAI-Agent Binary 的 Code Sign 要求

macOS 預設拒絕執行未簽署的 binary（`Operation not permitted`）。OSW-MyAI-Agent binary 需在部署前完成 ad-hoc code sign：

```bash
codesign --remove-signature /path/to/osw-myai-agent
codesign --force --sign - /path/to/osw-myai-agent
```

**責任歸屬**：
- server 角色在 build binary 後，CI/CD 流程中自動執行上述 codesign 步驟
- 或由使用者手動執行（安裝文件中記錄此步驟）

> 詳細決策見 `decisions/260322_001_macOSEntitlements.md`。

---

## 未來新增 Entitlement 的流程

若未來新功能需要額外的 entitlement（例如：存取 `~/Library/`、相機、麥克風等），需：

1. 由 app 角色向 spec 角色發 `[Request]`，說明需要的 entitlement 與對應功能
2. spec 角色評估後更新本文件並補充決策紀錄
3. Release entitlements 的變更需評估 Apple 審查影響（目前為 Developer ID 分發，非 App Store）
