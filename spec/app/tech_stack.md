# MyAi — App 技術選型

> 版本：v1.2.0
> 日期：2026-02-25
> 修訂：2026-03-12（移除本地資料庫與後端同步，見 decisions/260312_001_NoDBNoSync.md）
> 修訂：2026-03-12（調整為桌面平台，移除 Keycloak / health，見 decisions/260312_002_DesktopArch.md）
> 修訂：2026-03-22（補入 file_picker 套件，見 decisions/260322_001_macOSEntitlements.md）

---

## 核心框架

| 分類 | 套件 | 說明 |
|---|---|---|
| 框架 | **Flutter** | 桌面三平台：macOS / Windows / Linux |
| 語言 | **Dart** | |
| UI 基礎 | **Material 3** | Flutter 預設，支援 Light / Dark 雙模式 |

---

## 狀態管理與架構

| 分類 | 套件 | 說明 |
|---|---|---|
| 狀態管理 | **Riverpod** | `@riverpod` code generation，管理 CLI 連線狀態、Agent 回應等複雜反應式場景 |
| 路由 | **go_router** | Flutter 官方維護，支援 deep link、認證 redirect guard |
| 資料模型 | **freezed + json_serializable** | Immutable model、copyWith、JSON 序列化自動產生 |

---

## 本地通訊

| 分類 | 套件 | 說明 |
|---|---|---|
| HTTP Client | **dio** | 與 Local OSW-MyAI-Agent 溝通（REST API） |
| WebSocket | **web_socket_channel** | 接收 Agent 串流回應與即時狀態推播 |
| 檔案選擇 | **file_picker** | macOS 原生資料夾選擇對話框（WorkspaceSetupPage、ImportRoleDialog、ProjectSetupWizard）|

> 認證由 Copilot CLI 本身管理，Flutter App 不直接處理 GitHub OAuth。

---

## AI 回應渲染

AI（Copilot）的回應內容大量使用 Markdown 與 Mermaid 圖表，需要對應的渲染套件。

| 分類 | 套件 | 說明 |
|---|---|---|
| Markdown 渲染 | **flutter_markdown** | Flutter 官方維護，渲染 AI 回應的 Markdown 內容 |
| Mermaid 渲染 | **flutter_inappwebview** | 嵌入 WebView，載入 mermaid.js 渲染 Mermaid 圖表 |

> Mermaid 無 Dart 原生實作，以 WebView 載入 mermaid.js 渲染為最可行方案。

---

## 圖表與工具

| 分類 | 套件 | 說明 |
|---|---|---|
| 圖表 | **fl_chart** | 資料視覺化圖表 |
| UI 工具 | **nb_utils** | Toast、Loader、Navigator 擴充、間距工具 |
| 媒體格式 | **Animated WebP** | 動畫（高壓縮比、支援透明背景） |
| UUID | **uuid** | Client 端產生 UUID v4 |

---

## Code Generation（build_runner）

| 套件 | 產出 |
|---|---|
| riverpod_generator | Provider 程式碼 |
| freezed | Immutable model classes |
| json_serializable | JSON fromJson/toJson |

---

## 套件清單

> 版本以 `flutter pub add` 時的最新穩定版為準，不在規格中指定。

```yaml
dependencies:
  flutter_riverpod:
  riverpod_annotation:
  go_router:
  dio:
  web_socket_channel:
  file_picker:
  freezed_annotation:
  json_annotation:
  fl_chart:
  nb_utils:
  uuid:
  flutter_markdown:
  flutter_inappwebview:

dev_dependencies:
  riverpod_generator:
  build_runner:
  freezed:
  json_serializable:
  maestro_test:
```

---

## 測試

| 層次 | 工具 | 說明 |
|------|------|------|
| E2E | Maestro YAML Flow（`.maestro/*.yaml`）| 完整使用者流程驗收 |
| Component 整合 | `maestro_test` Dart 套件（`integration_test/maestro/`）| 單一元件互動驗收 |
| 單元測試 | `flutter_test` | 商業邏輯、model、utils |

> 詳細 testability 規範與 Key 命名規則見 `spec/app/testing.md`。

---

## 不採用項目

以下套件原列於技術選型草稿，本專案**不採用**：

| 套件 | 原始用途 | 不採用原因 |
|------|----------|------------|
| `drift` / `drift_dev` | 本地 SQLite 資料庫 | 本專案不需要本地資料庫 |
| 自製 Sync API | `/sync/pull` + `/sync/push` 雲端同步 | 本專案不需要後端同步 |
| `connectivity_plus` | 監聽網路狀態、恢復時觸發 sync | sync 已移除，不需要此套件 |
| `flutter_appauth` | Keycloak PKCE OAuth2/OIDC | 本專案無 Keycloak，認證由 Copilot CLI 管理 |
| `flutter_secure_storage` | 安全儲存 access/refresh token | token 由 CLI 本身儲存，App 層不需要 |
| `health` | Apple HealthKit 讀寫 | 僅支援 iOS，本專案目標為桌面平台 |
