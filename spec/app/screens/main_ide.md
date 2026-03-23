# MyAi — 主畫面（IDE 主畫面）規格

> 版本：v1.20.0
> 日期：2026-03-22
> 來源：app 角色 Request #2，首版 demo 實作逆向正規化
> 修訂：2026-03-13（新增 waiting 狀態卡片規則、角色卡片欄位補充、PermissionCard，見 decisions/260313_007_WaitingStateDesign.md）
> 修訂：2026-03-14（三欄 resizable panels、面板折疊 toggle、auto-collapse、卡片自適應，見 decisions/260314_001_ResizablePanels.md，Request #6 #7）
> 修訂：2026-03-15（補充 App 啟動流程章節，見 decisions/260315_001_AppStartupFlow.md，Request #9）
> 修訂：2026-03-15（TopBar 複製按鈕、工具呼叫色塊規格、AiChatInput 串流中斷，Request #10）
> 修訂：2026-03-15（對話訊息列表自動捲動行為規格，Request #11）
> 修訂：2026-03-15（系統設定按鈕重命名、移除 Directory 獨立設定入口、AiChatInput 常用語工具列，Request #13 #14）
> 修訂：2026-03-16（開新對話按鈕規格，並釐清 Session Reset 與 Server restart 差異，見 decisions/260316_001_NewConversationReset.md，Request #16）
> 修訂：2026-03-16（role.error 錯誤氣泡顯示規格，Request #15）
> 修訂：2026-03-16（AiChatInput 推理力度選擇器，見 decisions/260316_003_ReasoningEffort.md，Request #18）
> 修訂：2026-03-16（Reasoning Effort 改為動態 options，見 decisions/260316_004_ReasoningEffortDynamicOptions.md，Request #20）
> 修訂：2026-03-16（模型選擇器補 per-role 持久化行為規格）
> 修訂：2026-03-16（條件式自動捲動 + 返回底部按鈕，見 decisions/260316_005_ConditionalAutoScroll.md，Request #21）
> 修訂：2026-03-16（模型選擇器改為條件顯示、移除靜態 fallback，見 decisions/260316_006_ModelSelectorVisibility.md，Request #22）
> 修訂：2026-03-16（dispatcher 改為 mandatory built-in role；啟動流程改為內建角色 + prompt 掃描，見 decisions/260316_007_DispatcherBuiltinRole.md，Request #24）
> 修訂：2026-03-16（PermissionCard 改為依 `choices` 動態渲染；釐清 `allowed` / `answer` 語意，見 decisions/260316_008_PermissionCardChoiceHandling.md，Request #23）
> 修訂：2026-03-17（啟動流程改為載入本地角色庫（imported roles），廢棄 prompt 掃描，見 decisions/260317_001_ImportedRoleContent.md，Request #25）
> 修訂：2026-03-17（啟動流程新增 Step 0 workspace 設定；移除啟發式 project root 偵測，見 decisions/260317_003_WorkspaceConfig.md，Request #26）
> 修訂：2026-03-17（全域改名：SDK Server → OSW-MyAI-Agent，Request #27）
> 修訂：2026-03-17（啟動流程新增 Step 0b 必要工具檢查，Request #29）
> 修訂：2026-03-17（Step 0 改為讀取 default.json + workspace config.json，見 decisions/260317_006_ConfigSplit.md，Request #30）
> 修訂：2026-03-22（AiChatInput 送出按鈕互動狀態補充，spec#38）

---

## 概覽

主畫面為 MyAi 的核心操作介面，採**三欄佈局（Row）**，讓使用者同時管理多個 AI 角色、進行對話、瀏覽工作目錄。

---

## 整體結構

```
┌─────────────┬──────────────────────┬────────────────┐
│ 左側        │ 中央                 │ 右側           │
│ Sidebar     │ Monitor              │ Directory      │
│ 248dp       │ flex                 │ 240dp          │
└─────────────┴──────────────────────┴────────────────┘
```

| 欄位 | 預設寬度 | 最小寬度（拖拉） | 折疊寬度 | 最大寬度 | 說明 |
|------|----------|------------------|---------|---------|------|
| 左側 Sidebar | 248px | 52px | 52px | 480px | 角色清單（好友名單概念） |
| 中央 Monitor | flex（填滿剩餘空間） | — | — | — | 對話記錄 + 輸入框 |
| 右側 Directory | 240px | 160px | 52px | 480px | 當前角色目錄樹 + 設定入口 |

---

## 三欄 Resizable & Collapsible Panels

### 欄寬參數總覽

| 欄位 | 預設寬度 | 最小（拖拉） | 折疊寬度 | 最大寬度 |
|------|----------|-------------|---------|---------|
| 左（Sidebar） | 248px | 52px | 52px | 480px |
| 右（Directory） | 240px | 160px | 52px | 480px |
| 中（Monitor） | 全寬 − 左 − 右 | — | — | — |

### 拖拉行為

- 左右欄各有一條可拖拉的分隔線（ResizeDivider），hover 時顯示 `resizeColumn` cursor
- 拖拉時即時更新寬度，中間欄自動填滿剩餘空間
- 折疊狀態下分隔線改為細線（不可拖拉）

### Auto-collapse（左欄限定）

| 拖拉寬度 | 行為 |
|---------|------|
| 拖拉至 < 120px | 自動觸發折疊（寬度固定為 52px） |
| 拖拉至 ≥ 120px | 自動解除折疊，恢復可拖拉狀態 |

> 右欄不支援 auto-collapse，最小可拖拉至 160px（折疊需透過按鈕）。

### 面板折疊按鈕

| 面板 | 按鈕位置 | 展開時圖示 | 折疊後圖示 |
|------|----------|-----------|-----------|
| 左（Sidebar） | header 右側 | `keyboard_double_arrow_left`（`<<`） | `keyboard_double_arrow_right`（`>>`） |
| 右（Directory） | header 右側 | `keyboard_double_arrow_right`（`>>`） | `keyboard_double_arrow_left`（`<<`） |

- 點擊後面板縮為 52px，僅顯示 icon（左欄顯示角色頭像列，右欄顯示資料夾 icon）
- Tooltip：折疊狀態顯示「展開」，展開狀態顯示「最小化」

### 響應式折疊（視窗寬度不足）

- 當視窗寬度 < 左欄目前寬度 + 右欄目前寬度 時，左右欄與分隔線全部隱藏，中間欄填滿全寬
- 視窗拉寬後自動恢復三欄（含折疊狀態）

---



### 角色項目顯示欄位

| 欄位 | 說明 |
|------|------|
| 圓形 Avatar | 角色名稱首字母，固定大小 |
| 狀態燈 | Avatar 右下角小圓點，顯示五種執行狀態（含 waiting） |
| 角色名稱 | 粗體；有未讀時加粗 w700 |
| 未讀訊息 badge | 有未讀訊息時顯示數字，靠右對齊名稱行 |
| 當前 Issue | 第二行左側：有任務時顯示 `#N 標題…`；idle 無任務時顯示「待命中」；waiting 時顯示「需要確認 — 點此處理」（橘色粗體）|
| 最後活動時間 | 第二行右側：相對時間（剛剛 / N 分鐘前 / N 小時前 / N 天前）；當卡片可用寬度 < 160px 時自動隱藏 |

### 角色卡片自適應規則

當左欄可用寬度 < 160px 時，以下元素**同步隱藏**（不分開控制）：

| 隱藏元素 | 觸發條件 |
|---------|---------|
| 最後活動時間 | 卡片可用寬度 < 160px |
| 未讀訊息 badge | 卡片可用寬度 < 160px |

- 即使隱藏以上元素，角色名稱、waiting 狀態文字、狀態 dot 仍保持可見

### waiting 狀態卡片規則

當角色狀態為 `waiting` 時，該角色卡片的額外視覺規則：

| 元素 | 規則 |
|------|------|
| 卡片邊框 | 橘色（#F97316）細邊框 |
| 卡片背景 | 淡橘色背景（低透明度，Dark mode 也適用）|
| 第二行文字 | 「需要確認 — 點此處理」橘色粗體 + 手指圖示（`Icons.touch_app`）|
| 點擊行為 | 切換到該角色的 Monitor 頻道（與一般點擊行為相同）|

### 角色狀態定義

見 `spec/shared/agent_status.md`。

### Sidebar 底部 — 系統設定按鈕

Sidebar 最底部顯示「系統設定」按鈕：

| Sidebar 展開時 | icon + 「系統設定」文字 |
|---------------|----------------------|
| Sidebar 折疊時 | icon only（`monitor_heart`）|
| 右下角圓點 | 綠（server running + WS connected）/ 紅（error）/ 灰（其他）|

點擊後以 `context.push('/status')` 跳轉至系統設定頁（保留返回堆疊）。  
系統設定頁規格見 `spec/app/screens/system_status.md`。



- 選中角色時，項目背景高亮
- 選中後，中央 Monitor 與右側 Directory 切換為該角色的內容

---

## 中央：Monitor

### 結構

```
┌──────────────────────────────┐
│ TopBar                        │  固定高度
├──────────────────────────────┤
│ 對話訊息列表（可捲動）         │  flex
├──────────────────────────────┤
│ AiChatInput（固定底部）        │  固定高度
└──────────────────────────────┘
```

### TopBar

- 顯示當前選中角色的名稱（空間不足時 ellipsis 截斷）
- 顯示當前角色的狀態燈（含動畫，規則見 `spec/shared/agent_status.md`）
- **複製按鈕**（`content_copy` icon）：點擊後將當前角色的完整對話記錄複製到剪貼板（純文字格式，含工具呼叫記錄），顯示短暫 SnackBar 確認
- **開新對話按鈕**（`add_comment_outlined` icon）：位於複製按鈕右側；點擊後重置 AI Session（見下方規格）
- **連線狀態 Chip**：右側顯示彩色點 + 狀態文字 + 連線按鈕（見「連線狀態管理」章節）

#### 開新對話按鈕規格

> 決策紀錄：`spec/decisions/260316_001_NewConversationReset.md`

| 狀態 | 按鈕行為 |
|------|---------|
| 非串流中 | 可點擊，點擊後彈出確認 Dialog |
| 串流進行中（AI 正在回應）| 自動 disabled，防止誤觸 |

**確認 Dialog**

| 元素 | 規格 |
|------|------|
| 圖示 | `warning_amber_rounded`（`color-error`）|
| 標題 | 「開新對話？」|
| 內容 | 「將清除目前所有對話紀錄，並重設 AI 記憶，無法復原。」|
| 取消按鈕 | 「取消」，關閉 Dialog |
| 確認按鈕 | 「確認清除」，`FilledButton`，`color-error` 風格（紅色）|

**確認後執行順序**

```
使用者點「確認清除」
    │
    ▼
1. UI 訊息列表立即清空（本地 clear()）
    │
    ▼
2. DELETE /roles/{id}      ← 移除 server 端舊 session
    │
    ▼
3. POST /configure（傳原角色設定）← 重建乾淨 session
    │
    ▼
全新對話可用
```

> UI 先清空再等 Server 回應，使用者感受到即時回饋；Server 操作失敗時顯示錯誤 SnackBar，但 UI 已清空（不回滾）。
> 完整設計決策與取捨說明見 `decisions/260316_001_NewConversationReset.md`。
>
> **操作層級說明**：此功能僅重置**當前角色的 AI session**。  
> 不會停止或重啟整個 OSW-MyAI-Agent process，也不會等同於系統設定頁的「重啟 Server」操作。

**串流中的 TopBar 輸入區行為**

| 狀態 | 輸入框 | 送出按鈕 |
|------|--------|---------|
| 非串流 | 可輸入 | 送出（`send` icon）|
| 串流中 | 停用（disabled）| 變為停止按鈕（`stop` / □ icon），點擊後呼叫 `POST /roles/{id}/interrupt` 中斷 AI 回應 |

### 對話訊息列表

- 訊息類型分為 **user**（使用者發送）與 **AI**（角色回應）
- 捲動區域，最新訊息在最下方
- 支援 Markdown 渲染（設定可關閉）
- 支援串流回應（逐字顯示）
- AI 訊息支援錯誤狀態顯示

#### 錯誤氣泡（role.error）

收到 `role.error` 事件時，在對話列表末尾插入一個紅色錯誤氣泡（`isError: true`）。

> 決策紀錄：`spec/decisions/260316_002_RoleErrorClassification.md`

**錯誤類型分類**（App 端依 `payload.message` 關鍵字比對）

| 類型 | 分類關鍵字（case-insensitive） | 顯示說明 |
|------|-------------------------------|---------|
| `quota` | `credit`、`billing`、`quota`、`usage limit` | 額度 / 帳單問題 |
| `rate_limit` | `rate limit`、`429`、`overloaded`、`too many requests` | 頻率限制，稍後可重試 |
| `connection` | `connection`、`session`、`disconnected`、`timeout` | 連線中斷 / Session 遺失 |
| `general` | 未符合以上任何類型 | 一般錯誤 |

**各類型 UI 行為**

| 類型 | 顯示文字 | 附加行為 |
|------|---------|---------|
| `quota` | 「AI 額度不足或帳單有問題，請檢查您的帳號設定。」| 無額外按鈕（外部問題，App 無法代為處理）|
| `rate_limit` | 「請求頻率過高，請稍後再試。」| 無額外按鈕 |
| `connection` | 「連線中斷或 Session 遺失，請重新連線。」| 無額外按鈕（已有 TopBar 連線入口）|
| `general` | 原始 `payload.message` 文字 | 無額外按鈕 |

> `general` 類型顯示 SDK 原始訊息，便於除錯；其他類型顯示本地化友善文字。  
> 目前 `role.error` payload 不含 `error_type` 欄位（由 App 客戶端分類）；Server 端補欄位為未來優化項，見決策紀錄。

#### 自動捲動行為（條件式）

自動捲動為**條件式**：當使用者已往上捲動（不在底部）時，暫停自動捲動，避免強制拉回視角。

**「接近底部」閾值**：距最底部 ≤ **56dp**，即視為在底部（`isAtBottom`）。

| 觸發條件 | `isAtBottom` 狀態 | 捲動行為 |
|---------|-----------------|---------|
| 收到新訊息（user 或 AI 開始回應） | `true` | 滑順捲動（animate）至最底部，duration 150ms |
| 收到新訊息（user 或 AI 開始回應） | `false` | **不捲動**，保持目前位置 |
| AI 串流 chunk 更新 | `true` | 滑順捲動（animate）至最底部，duration 150ms |
| AI 串流 chunk 更新 | `false` | **不捲動**，保持目前位置 |
| 切換至不同角色 | — | 立即跳轉（jump）至該角色對話最底部，不做動畫；**同時重置 `isAtBottom = true`** |
| 使用者送出新訊息 | — | 強制捲動至最底部（不受 `isAtBottom` 限制），**同時重置 `isAtBottom = true`** |
| 使用者點擊「返回底部」按鈕 | — | 滑順捲動至最底部，**同時重置 `isAtBottom = true`** |
| 使用者手動捲回底部（達閾值） | — | 自動更新 `isAtBottom = true`，恢復自動捲動 |

> 自動捲動在每個 frame 結束後（`addPostFrameCallback`）執行，確保 layout 完成後取到正確的 `maxScrollExtent`。
> `isAtBottom` 透過 ScrollController 的 `position.pixels` ≥ `maxScrollExtent - 56` 判斷，在 scroll 事件監聽中即時更新。

#### 返回底部按鈕

當 `isAtBottom == false` 時，在對話訊息列表右下角顯示懸浮的「**↓ 返回底部**」按鈕（`AppAssistChip`）。

| 屬性 | 規格 |
|------|------|
| 元件類型 | `AppAssistChip`（含 leading icon `↓`） |
| 顯示文字 | 「返回底部」 |
| 顯示條件 | `isAtBottom == false` |
| 隱藏條件 | `isAtBottom == true` |
| 位置 | 訊息列表右下角，距底部 `inputAreaHeight + 12dp`，距右側 12dp |
| 點擊行為 | 滑順捲動至最底部，重置 `isAtBottom = true` |
| 出現 / 消失動畫 | `AnimatedSwitcher` / fade + slide，duration 200ms |

> **未讀狀態**：本期不加未讀計數 Badge。若後續評估需要，再由 app 角色發 Request 補規格。
> 按鈕懸浮於訊息列表上方，不影響訊息列表的 padding / scroll 空間。

### 工具呼叫色塊

AI 訊息中的工具呼叫（Tool Call）以 inline 色塊呈現，緊接在觸發點的上下文中，不折疊、不彙總。

| 工具類型 | 色塊顏色 | 說明 |
|---------|---------|------|
| `bash` | 琥珀（amber）| Shell 執行 |
| `report_intent` | 靛藍（indigo）| AI 自我描述意圖 |
| `read` / `view` | 天藍（sky）| 讀取操作 |
| `edit` / `write` / `create` | 翠綠（emerald）| 寫入操作 |
| 其他 | 紫羅蘭（violet）| 其他工具 |

色塊結構：左側彩色 accent border + 工具名稱 badge + 參數文字（等寬字型）。

### PermissionCard（確認 / 回應卡片）

當選中角色的狀態為 `waiting` 時，**對話列表底部**出現 PermissionCard。  
PermissionCard 是一張嵌入對話流中的互動卡片，不使用 Modal 或 Dialog（見 decisions/260313_007_WaitingStateDesign.md、decisions/260316_008_PermissionCardChoiceHandling.md）。

**卡片結構**：

| 元素 | 說明 |
|------|------|
| 標題列 | `Icons.warning_amber` + 「需要確認」文字（橘色）|
| 提示內容 | CLI/SDK 原始提示文字，等寬字型顯示（JetBrains Mono）|
| 回應按鈕區 | 依 `role.permission_request.choices` 動態渲染；另保留一個獨立「拒絕」按鈕 |

**回應按鈕規則**：

| 情況 | UI |
|------|----|
| `choices` 為空 | 顯示 legacy binary approval UI：`允許`（FilledButton）+ `拒絕`（OutlinedButton） |
| `choices` 僅 1 項 | 顯示該 choice 的主按鈕 + 獨立 `拒絕` 按鈕 |
| `choices` >= 2 項 | 依 API 提供順序動態渲染 choice buttons（使用 `Wrap` / 可換行排列，不保證單列容納）+ 獨立 `拒絕` 按鈕 |

**送出規則**：

| 使用者操作 | `POST /roles/{id}/permission_response` |
|-----------|--------------------------------------|
| 點擊某個 `choice` 按鈕 | `allowed=true`，`answer=<selected choice>` |
| `choices` 為空時點擊「允許」 | `allowed=true`，`answer` 可省略 |
| 點擊獨立「拒絕」按鈕 | `allowed=false`，`answer` 省略 |

> 獨立「拒絕」按鈕的語意是 **取消 / 中止此次 request**，不是把某個 choice 回給 SDK。
> 因此 App **不得**根據 choice 文字（例如 `Deny`、`Skip`）自行推斷 `allowed=false`。

**回應後狀態**：

| 操作 | 卡片外觀 | 角色狀態 |
|------|----------|----------|
| 選擇某個 choice；或 `choices` 為空時點擊「允許」 | 標題改為「已回覆」；顯示 `回應：{answer}` 摘要；按鈕消失 | `running` |
| 點擊獨立「拒絕」按鈕 | 標題改為「已拒絕」（紅色），按鈕消失 | `running` 或 `error`（由 CLI / SDK 端決定） |

> PermissionCard 在回應後保留於對話記錄中，作為操作歷史。

### AiChatInput

- 固定於 Monitor 底部
- 含多行文字輸入框與送出按鈕
- 送出方式：點擊送出按鈕 或 Enter（換行）/ Shift+Enter（送出訊息）
- **串流中**：輸入框停用，送出按鈕改為停止按鈕（□ icon）；點擊後呼叫 `POST /roles/{id}/interrupt`

#### 送出按鈕互動狀態

| 輸入框狀態 | 送出按鈕外觀 |
|-----------|-------------|
| 空白（無文字）| 禁用（灰色，無法點擊）|
| 有內容 | 啟用（`primary` 色背景 + 白色 `send` icon，對比顯示）|
| 串流中 | 停止按鈕（`error` 色背景 + □ icon）；點擊後呼叫 `POST /roles/{id}/interrupt` |

> `_hasText` listener 監聽輸入框內容變化，動態切換按鈕啟用/停用與外觀。

#### 輸入框上方工具列

輸入框上方有一排工具列：

```
[ 常用語 ▾ ]  ─── spacer ───  [ 模型名稱 ▾ ]  [ 推理力度 ▾ ]
                                ↑ 模型取得前不顯示  ↑ 僅在模型支援時顯示
```

| 元件 | 位置 | 顯示條件 | 說明 |
|------|------|---------|------|
| 常用語按鈕 | 左側 | 常駐顯示 | 點擊展開 popup 清單；選擇後將文字填入輸入框（若已有內容，換行追加）|
| 模型選擇器 | 右側 | **`GET /models` 成功取得非空清單後顯示** | 顯示目前採用的模型名稱；點擊展開下拉選單，可切換模型 |
| 推理力度選擇器 | 模型選擇器右側 | **模型選擇器可見，且選中模型支援 reasoning effort 時顯示** | 顯示目前推理力度；點擊展開下拉選單，可切換 |

#### 模型選擇器

> 決策紀錄：`spec/decisions/260316_006_ModelSelectorVisibility.md`

**顯示條件**：`GET /models` 成功回傳非空清單後才顯示，否則整個元件隱藏（不保留佔位空間）。

- 模型清單來源：`GET /models` API 動態取得，為**唯一資料來源**
- 連線狀態為 `disconnected` / `connecting` / `error` 時 → 不顯示模型選擇器
- 連線成功但 `GET /models` 回傳空清單或失敗 → 不顯示
- 連線中斷時，清除模型清單狀態，回到「不顯示」狀態；重新連線成功後再次取得模型清單，恢復顯示
- 已選模型傳入對應角色的下一則訊息（透過 `POST /roles/{id}/message` 的 `model` 欄位）
- 切換模型時，若新模型不支援 reasoning effort，推理力度選擇器自動隱藏；送出訊息時不傳 `reasoning_effort`

**選擇行為（per-role 持久化）**

| 情況 | 行為 |
|------|------|
| 角色第一次開啟選擇器（無歷史記錄）| 使用 `GET /models` 清單的第一個模型作為預設 |
| 已有每角色的選擇記錄 | 切換角色 / 視窗後，**恢復**該角色上次選擇的模型 |
| 角色選擇的模型已不在當前 `GET /models` 清單中 | 回退至 `GET /models` 清單的第一個模型 |

> **儲存範圍**：每個角色（role）各自獨立記憶最後一次選擇的模型 ID；切換角色時不互相影響。  
> App 重啟後若 `GET /models` 成功，優先恢復角色歷史選擇；若歷史 model ID 已不存在（模型下架），回退至清單第一個模型。

#### 推理力度選擇器（Reasoning Effort）

> 決策紀錄：`spec/decisions/260316_003_ReasoningEffort.md`、`spec/decisions/260316_004_ReasoningEffortDynamicOptions.md`

**顯示條件**：當前選中模型的 `reasoning_effort_options` 非 null 且非空時顯示，否則整個元件隱藏（不保留佔位空間）。

**選項來源與顯示**

- App 依 `reasoning_effort_options` **動態渲染**選單，不假設固定只有 3 個選項
- 選單順序與 API 提供的 `reasoning_effort_options` 陣列順序一致
- 送出 API 時使用原始 token，不做值轉換
- Phase 1 顯示文字採 **humanize** 規則：將 `snake_case` token 轉為 Title Case
  - `low` → `Low`
  - `medium` → `Medium`
  - `high` → `High`
  - `extra_high` → `Extra High`
- 未來若需在地化或模型提供更友善名稱，再另行擴充 `display_name` / i18n 方案

**行為規則**

| 情況 | 行為 |
|------|------|
| 模型第一次出現推理力度選擇器（無歷史記錄）| 若 options 含 `medium`，預設選 `medium`；否則選第一個 option |
| 已有每角色的選擇記錄，且目前 model 仍支援該值 | 恢復上次選擇 |
| 已有每角色的選擇記錄，但目前 model 不支援該值 | 回退為 `medium`（若存在），否則取第一個 option |
| 送出訊息時 | 將目前推理力度的**原始 token** 透過 `POST /roles/{id}/message` 的 `reasoning_effort` 欄位傳出 |
| 切換至不支援的模型 | 選擇器隱藏，不傳 `reasoning_effort` 欄位 |

**設定範圍**：每個角色（role）各自獨立儲存最後一次有效的 reasoning effort token，互不影響；同角色切換模型時，依目前 model 的 options 套用上述回退規則。

#### 常用語（Quick Phrases）

常用語清單從 `{projectRoot}/myai_phrases.json` 載入（見啟動流程）。  
常用語的新增 / 編輯 / 刪除管理在系統設定頁（Section 9），見 `spec/app/screens/system_status.md`。

---

## 右側：Directory

### 目錄樹

- 顯示當前選中角色所負責的工作目錄
- 支援資料夾展開 / 收合（箭頭圖示切換）
- 有變更的檔案標記：小圓點 + 粗體檔名
- 目錄樹採遞迴顯示，不限層數

### 設定入口

> ⚠️ **已移除**（Request #13）：原 Directory 底部的獨立「設定」按鈕與 Bottom Sheet 已廢棄，設定功能整合至「系統設定」頁面。  
> 設定入口改為 Sidebar 底部的「系統設定」按鈕，見上方 Sidebar 底部章節。

---

## 資料需求

| 資料 | 來源 |
|------|------|
| 角色清單與狀態 | App 本地角色定義（內建 + 匯入角色庫）預填；連線後由 Local OSW-MyAI-Agent（WebSocket / `GET /roles`）覆蓋 |
| 對話訊息 | Local OSW-MyAI-Agent（HTTP + WebSocket 串流）|
| 目錄樹 | Local OSW-MyAI-Agent（HTTP，選擇角色時拉取）|
| 未讀 badge 計數 | App 本地維護 |

---

## 注意事項

- 三欄支援拖拉調整寬度（左右欄），中間欄自動填滿；欄寬範圍與折疊行為見「三欄 Resizable & Collapsible Panels」節
- 角色 Sidebar 不支援直接新增 / 刪除角色；角色清單由 App 啟動配置（內建角色 + 本地匯入角色庫）建立，再由 Server 維護 session 與執行狀態
- 左側角色卡片列表只顯示**有效啟用集合**中的角色（`ENABLED_ROLES` + mandatory built-in roles；停用的一般角色不出現）

---

## App 啟動流程

> 決策紀錄：`spec/decisions/260315_001_AppStartupFlow.md`、`spec/decisions/260316_007_DispatcherBuiltinRole.md`、`spec/decisions/260317_001_ImportedRoleContent.md`、`spec/decisions/260317_003_WorkspaceConfig.md`

App 啟動時讀取 `myai.env`（位於 projectRoot），依旗標決定啟動行為：

| `myai.env` 旗標 | 預設 | 說明 |
|-----------------|------|------|
| `AUTO_START_SERVER` | `true` | 啟動時是否自動執行 OSW-MyAI-Agent |
| `AUTO_CONNECT` | `true` | 啟動時是否自動建立 WebSocket 連線 |

```
App 啟動
  ├── 0. 讀取 workspace 設定
  │       讀取 ~/.osw_myai/default.json → lastWorkspace
  │       若 ~/.osw_myai/ 不存在 → 建立目錄
  │       若 lastWorkspace 為空 → phase = needsWorkspace → 顯示 WorkspaceSetupPage（阻斷後續步驟）
  │       若 lastWorkspace 存在 → projectRoot = lastWorkspace
  │                             → 讀取 {projectRoot}/.osw_myai/config.json（不存在時為空物件）
  │
  ├── 0b. 必要工具檢查（warn-only，不阻斷啟動）
  │       以下三項工具若缺少，記錄 warn log 並在系統設定頁啟動 log 顯示 ⚠️
  │
  │       ┌─────────────────────┬──────────────────────────────────────────────┬────────────────────────────────────┐
  │       │ 工具                │ 檢查方式                                     │ 缺少時提示                         │
  │       ├─────────────────────┼──────────────────────────────────────────────┼────────────────────────────────────┤
  │       │ git                 │ git --version                                │ 請安裝 Xcode Command Line Tools    │
  │       │ osw-myai-agent      │ 檔案存在：{projectRoot}/server/code/osw-myai-agent │ 顯示預期路徑               │
  │       │ copilot             │ copilot --version                            │ 請安裝 GitHub Copilot CLI          │
  │       └─────────────────────┴──────────────────────────────────────────────┴────────────────────────────────────┘
  │
  ├── 1. 讀取 myai.env
  │       路徑：$projectRoot/myai.env
  │       重要欄位：FORGEJO_TOKEN、AI_SERVER_BINARY（可選）
  │                AUTO_START_SERVER（預設 true）
  │                AUTO_CONNECT（預設 true）
  │
  ├── 1a. 載入常用語（Quick Phrases）
  │       路徑：$projectRoot/myai_phrases.json
  │       不存在時使用內建預設（「更新 Issue」）；讀取失敗不中斷啟動
  │
  ├── 2. 若 AUTO_START_SERVER=true：啟動 OSW-MyAI-Agent binary
  │       二進位優先序：(a) 設定畫面手動路徑 → (b) myai.env AI_SERVER_BINARY → (c) 預設
  │       若 localhost:7788 已有服務回應 → 跳過啟動
  │       若啟動失敗 → 啟動診斷日誌顯示錯誤，進入降級模式
  │
  ├── 3. 注入內建角色 dispatcher
  │       id = dispatcher
  │       work_dir = project root
  │       若 ai/prompts/dispatcher.md 存在 → 作為本地 prompt override
  │       若不存在 → 仍使用內建 prompt 建立角色
  │
  ├── 4. 載入 App 本地角色庫（imported roles）
  │       從持久化儲存讀取所有 source_kind = "imported" 的角色紀錄
  │       若角色庫為空且 KNOWN_ROLES 包含非內建角色 → 執行 migration：
  │           掃描 ai/prompts/osw-*.md 與 ai/prompts/ltc-*.md
  │           讀取內容，寫入角色庫（source_kind = "imported"）
  │           migration 失敗 → 角色庫留空，不中斷啟動（降級模式顯示提示）
  │
  ├── 5. 合併 built-in + imported roles
  │       套用 KNOWN_ROLES / ENABLED_ROLES
  │       dispatcher 為 mandatory built-in role：永遠視為 enabled
  │       立即以 offline 狀態預填 rolesProvider（不等待連線）
  │
  ├── 6. 確認 server 可達性（GET /health 或 HEAD）
  │       不可達 → 進入降級模式（角色仍以 offline 顯示）
  │
  ├── 7. POST /configure（token + 角色清單）
  │       從 myai.env 讀取 token，從角色庫取得啟用角色清單
  │       匯入型角色帶 prompt_content；dispatcher 帶 builtin_id=dispatcher
  │
  ├── 8. 若 AUTO_CONNECT=true：連接 WebSocket /ws
  │       連線成功 → GET /roles 覆蓋角色狀態，進入主畫面
  │       連線失敗 → 啟動診斷日誌顯示錯誤
  │
  └── 9. 進入主畫面
```


### 降級模式（Server 不可用時）

| 條件 | 行為 |
|------|------|
| Server 無法啟動 / 連線失敗 | 主畫面仍可顯示，角色清單保留本地已知角色（內建 + 匯入角色庫）並以 `offline` 顯示 |
| 角色庫為空（migration 失敗） | 主畫面顯示「角色庫為空，請至系統設定頁匯入角色」提示 |
| 連線狀態顯示 | TopBar 顯示「未連線」狀態，提供「連線」按鈕 |
| 使用者可操作 | 可在設定畫面修改 binary 路徑後重試連線 |

> App 不提供「離線 demo 模式」（假資料）。未連線時顯示空狀態，等待使用者修正設定後重連。

### 診斷日誌

啟動序列中每個步驟的結果記錄於診斷日誌（設定畫面的「連線狀態」區塊可查看）：

| 前綴 | 意義 |
|------|------|
| `·` | 中性資訊（路徑、版本等）|
| `✓` | 步驟成功 |
| `⚠` | 警告（降級但仍繼續）|
| `✗` | 失敗（步驟中止）|

---

## 連線狀態管理

### 狀態定義

| 狀態 | 含義 | UI 顯示 |
|------|------|---------|
| `disconnected` | Server 未啟動或 WS 未連接 | 灰點 + 「未連線」|
| `connecting` | 正在啟動 Server / WS 連線中 | 動畫點 + 「連線中」|
| `connected` | WS 連線正常，可收發 | 綠點 + 「已連線」|
| `error` | 連線中斷或 Server crash | 紅點 + 「連線錯誤」|

### UI 位置

- **TopBar（Monitor 頂部）**：右側顯示小狀態指示器（彩色點 + 狀態文字 + 連線按鈕）
- **設定底部 Sheet 的「連線狀態」Section**：顯示狀態 + 診斷日誌全文

### 重連策略

- **目前**：手動重連（使用者點擊「連線」按鈕後觸發完整啟動序列）
- **自動重連**：未定義（TBD），不在目前版本範圍內
