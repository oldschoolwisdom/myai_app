# 決策紀錄索引

| 編號 | 日期 | 關鍵字 | 摘要 |
|------|------|--------|------|
| 260312_001 | 2026-03-12 | NoDBNoSync | App 不採用本地資料庫與後端同步 |
| 260312_002 | 2026-03-12 | DesktopArch | 桌面平台架構、Local SDK Server 橋接、移除 Keycloak |
| 260312_003 | 2026-03-12 | DarkModeSupport | 支援 Light/Dark 雙模式，Dark mode primary = Cyan |
| 260312_004 | 2026-03-12 | MinFontSize18sp | 全 App 字級下限 18sp |
| 260313_001 | 2026-03-13 | AppScreenSpec | 新增 App 畫面規格與設計系統文件（逆向正規化），角色狀態移至 shared |
| 260313_003 | 2026-03-13 | ServerArchitecture | Server 架構：Go 實作語言、角色管理、角色間通知路由設計 |
| 260313_004 | 2026-03-13 | RemoveCLIDependency | 移除 Copilot CLI 依賴，Go Server 直接整合 Go SDK + Tool Execution，架構改為兩層 |
| 260313_005 | 2026-03-13 | GoSDKPackage | Go SDK 套件確認（github/copilot-sdk/go）、認證方式、架構修正（SDK auto-embed CLI，Tool Execution 由 CLI 負責）|
| 260313_006 | 2026-03-13 | MaestroTesting | Flutter App Maestro 自動化測試策略（YAML E2E + Dart 整合測試、macOS Desktop、Widget Key 命名規範）|
| 260313_007 | 2026-03-13 | WaitingStateDesign | 新增 waiting 狀態、PermissionCard inline 互動模式、橘色狀態燈快速 Pulse |
| 260314_001 | 2026-03-14 | ResizablePanels | 三欄 resizable panels、面板折疊 toggle、auto-collapse 門檻（120px）、卡片自適應門檻（160px）|
| 260315_001 | 2026-03-15 | AppStartupFlow | App 啟動流程、project root 偵測策略（走訪 executable）、binary 路徑三層優先序、降級行為（空狀態 + 診斷日誌，無 demo mode）|
| 260315_002 | 2026-03-15 | StartupPrefsEnvFile | myai.env（由 .env 更名）儲存 AUTO_START_SERVER / AUTO_CONNECT；EnvService 擴充 set() + persist() 寫回策略 |
| 260315_003 | 2026-03-15 | RoleEnableToggle | 角色啟用開關：KNOWN_ROLES + ENABLED_ROLES 雙鍵設計，新角色自動啟用，停用後重連不重啟 |
| 260316_001 | 2026-03-16 | NewConversationReset | 開新對話：Session Reset 採 DELETE + POST /configure 序列；UI 先清、Server 後重置的非同步策略 |
| 260316_002 | 2026-03-16 | RoleErrorClassification | role.error 錯誤分類：Phase 1 採 App 端關鍵字比對（quota/rate_limit/connection/general），Server 端補欄位列為未來優化 |
| 260316_003 | 2026-03-16 | ReasoningEffort | Reasoning Effort 設計：靜態 options 欄位、只在支援模型時顯示選擇器、per-role 獨立設定、預設 medium |
| 260316_004 | 2026-03-16 | ReasoningEffortDynamicOptions | Reasoning Effort 改為動態 options；API 傳遞 SDK 原始 token，App Phase 1 以 humanize 規則顯示，預設 medium / fallback 第一項 |
| 260316_005 | 2026-03-16 | ConditionalAutoScroll | 條件式自動捲動（`isAtBottom` 閾值 56dp）+ 返回底部 AssistChip 按鈕；送出訊息 / 切換角色強制重置 |
| 260316_006 | 2026-03-16 | ModelSelectorVisibility | 模型選擇器改為條件顯示（`GET /models` 成功後才顯示）；移除靜態 fallback 清單；連線中斷時隱藏選擇器 |
| 260316_007 | 2026-03-16 | DispatcherBuiltinRole | 引入 built-in role 概念；dispatcher 改為 mandatory built-in role；`POST /configure` 新增 `builtin_id` 與內建 prompt fallback |
| 260316_008 | 2026-03-16 | PermissionCardChoiceHandling | PermissionCard 改為依 `choices` 動態渲染；`allowed` 表示是否提交回答；獨立「拒絕」按鈕代表取消 request，而非 choice 語意 |
| 260317_001 | 2026-03-17 | ImportedRoleContent | 廢棄掃描型角色；引入匯入型角色（imported roles）；App 持久化 prompt_content；`POST /configure` 新增 `prompt_content` 欄位 |
| 260317_002 | 2026-03-17 | PhysicalIsolation | 角色物理隔離原則；`work_dir` 固定為 `{projectRoot}/{role_id}/code`；角色模型加 `repo_url`；各角色各自 clone reference repo |
| 260317_003 | 2026-03-17 | WorkspaceConfig | Workspace 全域設定 `~/.osw_myai/config.json` 取代啟發式路徑偵測；新增 Step 0 workspace 解析；WorkspaceSetupPage |
| 260317_004 | 2026-03-17 | RenameOswMyaiAgent | 改名：SDK Server → OSW-MyAI-Agent；binary `sdk-server` → `osw-myai-agent`；class `SdkServerService` → `OswMyaiAgentService` |
| 260317_005 | 2026-03-17 | AppBootstrap | App 整合 Bootstrap + Setup 流程；5 個設計決策（App 定位、Forgejo config 位置、git clone、prompt 來源、tokens 儲存）|
| 260317_006 | 2026-03-17 | ConfigSplit | 設定檔分層：`~/.osw_myai/default.json`（全域 lastWorkspace）+ `{workspace}/.osw_myai/config.json`（專案 Forgejo + tokens）|
| 260317_007 | 2026-03-17 | BootstrapTemplate | Bootstrap template 驅動架構：`ai/roles.yaml` 取代硬編碼角色清單；`ai/prompts/` 命名慣例（`common_*.md` / `dispatcher.md` / 角色專屬）；角色 token 唯一存於 workspace config |
| 260322_001 | 2026-03-22 | macOSEntitlements | macOS App Sandbox entitlements 規格化；新增 `spec/app/platform/macos.md`；補入 file_picker；ad-hoc code sign 要求 |
