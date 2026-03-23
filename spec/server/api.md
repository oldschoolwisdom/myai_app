# MyAi — Local OSW-MyAI-Agent API 規格

> 版本：v1.7.0
> 日期：2026-03-16
> 來源：overview.md API 節拆出並補齊，Request #8
> 修訂：2026-03-16（DELETE /roles/{id} 補 Session Reset 說明與作用範圍；role.error 補錯誤分類未來規劃，Request #15 #16）
> 修訂：2026-03-16（POST /roles/{id}/message 加 model + reasoning_effort 欄位；GET /models 補 ModelInfo 結構與 reasoning_effort_options，Request #18）
> 修訂：2026-03-16（GET /models ModelInfo 補 billing_multiplier 欄位，Request #19）
> 修訂：2026-03-16（Reasoning Effort 改為動態 options / 動態驗證，支援 `extra_high` 等級，Request #20）
> 修訂：2026-03-16（`POST /configure` 新增 built-in role contract；dispatcher 可在缺少本地 prompt 檔時以內建 prompt 建立，Request #24）
> 修訂：2026-03-16（`permission_response` / `permission_request` 補 choices 動態回應規則與 `allowed` 語意釐清，Request #23）
> 修訂：2026-03-17（`POST /configure` 新增 `prompt_content` 支援匯入型角色；`prompt_path` 標記為向後相容，Request #25）
> 相關文件：[overview.md](overview.md)、[spec/shared/agent_status.md](../shared/agent_status.md)、[spec/shared/roles.md](../shared/roles.md)

---

## 概覽

Local OSW-MyAI-Agent 在 `localhost:7788` 提供 HTTP REST + WebSocket 介面給 Flutter App 使用。

| 分類 | 協定 | Base |
|------|------|------|
| 設定與控制 | HTTP REST | `http://localhost:7788` |
| 即時推播 | WebSocket | `ws://localhost:7788/ws` |

所有 JSON 請求需帶 `Content-Type: application/json`。

---

## HTTP Endpoints

---

### `POST /configure`

設定認證資訊與角色清單。Server 依此建立或更新角色 session 與 SDK Client。App 啟動時必須先呼叫；設定變更後需重新呼叫。

**Request body**

標準模式（GitHub Copilot 帳號）：

```json
{
  "auth": {
    "mode": "copilot",
    "github_token": "ghp_xxxx"  // 選填；留空時 SDK 自動從 server process 環境變數 `GITHUB_TOKEN` 或 `~/.config/github-copilot/` 讀取
  },
  "roles": [
    {
      "id": "dispatcher",
      "builtin_id": "dispatcher",
      "work_dir": "/path/to/project-root"
    },
    {
      "id": "spec",
      "prompt_content": "# spec 角色\n你是規格管理者...",
      "work_dir": "/path/to/spec",
      "model": "claude-sonnet-4.6"
    }
  ]
}
```

BYOK 模式（自訂 API Provider）：

```json
{
  "auth": {
    "mode": "byok",
    "provider": {
      "type": "openai",
      "base_url": "https://api.openai.com/v1",
      "api_key": "sk-xxxx"
    },
    "model": "gpt-4o"
  },
  "roles": [...]
}
```

**角色設定欄位**

| 欄位 | 型別 | 必填 | 說明 |
|------|------|------|------|
| `id` | string | ✓ | 角色唯一識別碼 |
| `builtin_id` | string | 否 | 內建角色識別碼；Phase 1 只定義 `dispatcher`。提供時表示此角色可使用 Server 內建 prompt 建立 |
| `prompt_content` | string | 非 built-in role 擇一必填 | System prompt 完整文字內容（匯入型角色首選）|
| `prompt_path` | string | 非 built-in role 擇一必填 | System prompt 檔案的本地絕對路徑（向後相容，建議改用 `prompt_content`）|
| `work_dir` | string | ✓ | 角色工作目錄（SDK `Cwd`）|
| `model` | string | BYOK 必填 | 使用的 AI 模型名稱 |

> `prompt_content` 與 `prompt_path` 互斥（擇一提供）；若兩者均提供，`prompt_content` 優先。  
> 非 built-in role 必須提供其中之一，否則回傳 `422`。

**built-in role 規則**

- Phase 1 只定義 `builtin_id = "dispatcher"`
- `builtin_id=dispatcher` 時，App 應使用 `id=dispatcher`
- `dispatcher` 的 `work_dir` 使用 project root
- `prompt_path` / `prompt_content` 對 built-in role 均為**可選的本地 override**
  - 未提供 → Server 使用內建 `dispatcher` prompt
  - `prompt_path` 有值但檔案不存在 / 不可讀 → Server 記錄 warning，並回退至內建 `dispatcher` prompt
- 非 built-in role 不得省略 `prompt_content` 與 `prompt_path`（至少一個必填）

**安全規則**

- Server 不得將完整 `prompt_content` 輸出至 log（僅記錄長度或 hash 供診斷）
- `prompt_content` 不得出現於任何 error response body

**Response**

| Status | 說明 |
|--------|------|
| `200 OK` | 設定成功，角色 session 已建立或更新 |
| `400 Bad Request` | JSON 格式錯誤或必填欄位缺漏 |
| `422 Unprocessable Entity` | 認證無效（token 錯誤）或角色設定不合法（例如一般角色 `prompt_content` 與 `prompt_path` 均未提供、`builtin_id` 未知、`work_dir` 非法）|

---

### `GET /roles`

查詢所有角色的當前狀態。

**Response `200 OK`**

```json
{
  "roles": [
    { "id": "spec", "status": "idle" },
    { "id": "app",  "status": "running" }
  ]
}
```

角色狀態值見 `spec/shared/agent_status.md`（`idle` / `running` / `waiting` / `done` / `error`）。

---

### `POST /roles/{id}/message`

向指定角色發送使用者訊息，觸發 Agent Loop（非同步）。回應透過 WebSocket 事件串流。

**Path parameter**

| 參數 | 說明 |
|------|------|
| `id` | 角色 ID |

**Request body**

```json
{
  "text": "使用者輸入的訊息",
  "model": "claude-sonnet-4.6",
  "reasoning_effort": "medium"
}
```

| 欄位 | 型別 | 必填 | 說明 |
|------|------|------|------|
| `text` | string | ✓ | 使用者訊息文字 |
| `model` | string | 否 | 指定此次請求使用的模型 ID（省略時使用角色預設模型）|
| `reasoning_effort` | string | 否 | 推理力度 raw token；值必須是此次請求實際使用模型（`model` 指定值或角色預設模型）的 `reasoning_effort_options` 其中之一；省略時由 SDK / 模型自行決定；若模型不支援 reasoning effort，則不得傳送此欄位 |

**Response**

| Status | 說明 |
|--------|------|
| `202 Accepted` | 已接收，Agent Loop 開始執行 |
| `400 Bad Request` | `text` 欄位缺漏或為空；或 `reasoning_effort` 不在該模型的 `reasoning_effort_options` 內；或模型不支援 reasoning effort 但仍傳送此欄位 |
| `404 Not Found` | 指定角色不存在 |
| `409 Conflict` | 角色目前為 `running` 或 `waiting`，無法接收新訊息 |

---

### `POST /roles/{id}/notify`

角色間通知 API。角色 A 呼叫此端點將訊息注入角色 B 的 session，觸發角色 B 的 Agent Loop。

**Request body**

```json
{
  "from_role": "spec",
  "message": "新 Issue #3 已指派給你，請處理"
}
```

| 欄位 | 型別 | 必填 | 說明 |
|------|------|------|------|
| `from_role` | string | ✓ | 發送通知的角色 ID |
| `message` | string | ✓ | 通知內容 |

**Response**

| Status | 說明 |
|--------|------|
| `202 Accepted` | 通知已注入，角色 Agent Loop 開始或排隊 |
| `400 Bad Request` | 必填欄位缺漏 |
| `404 Not Found` | 目標角色（`{id}`）不存在 |

---

### `POST /roles/{id}/permission_response`

App 回應角色的 permission request（角色處於 `waiting` 狀態時使用）。

**Request body**

```json
{
  "request_id": "550e8400-e29b-41d4-a716-446655440000",
  "allowed": true,
  "answer": "Allow"
}
```

| 欄位 | 型別 | 必填 | 說明 |
|------|------|------|------|
| `request_id` | string (UUID) | ✓ | 來自 `role.permission_request` 事件的 `request_id` |
| `allowed` | boolean | ✓ | `true` = 提交一個回答給 SDK；`false` = 使用者主動拒絕 / 取消此次 request，不提交回答 |
| `answer` | string | 否 | 使用者提交的回答文字；當使用者點擊某個 `choice` 按鈕時，應等於 `role.permission_request.choices` 其中之一；`choices` 為空時可省略 |

**語意規則**

- App 若讓使用者選中某個 `choice`，應送 `allowed=true` + `answer=<selected choice>`
- App 若讓使用者按下獨立的「拒絕 / 取消」按鈕，應送 `allowed=false`，且 `answer` 省略
- App / Server **不得**根據 `answer` 文字推測 `allowed`
  - 例如 `answer="Deny"` 且 `allowed=true`，代表把 `Deny` 當作合法回答送回 SDK
  - 這與 `allowed=false` 的「中止此次 request」不同

**Response**

| Status | 說明 |
|--------|------|
| `202 Accepted` | 回應已送達，SDK 繼續或中止執行 |
| `400 Bad Request` | 必填欄位缺漏或型別錯誤 |
| `404 Not Found` | `request_id` 無效，或該角色目前不在 `waiting` 狀態 |

---

### `DELETE /roles/{id}`

停止並移除指定角色的 session。角色移除後不再接收訊息，直到下次 `POST /configure` 重新建立。

**Session 重置（開新對話）**

App 實作「開新對話」功能時，應依序呼叫：

1. `DELETE /roles/{id}` — 移除舊 session，清除 AI 對話記憶
2. `POST /configure`（傳入相同角色設定）— 重建乾淨的 session

此序列是正式支援的 session reset 操作，等同於角色重啟（但不重啟整個 Server process）。  
決策背景見 `spec/decisions/260316_001_NewConversationReset.md`。

**作用範圍**

- 僅影響指定 `roleId` 的 session 與對話記憶
- 不終止或重啟整個 Server process
- 不等同於 App 的「重啟 Server」操作；後者屬 process 級重啟

**Response**

| Status | 說明 |
|--------|------|
| `200 OK` | 角色已停止並移除 |
| `404 Not Found` | 指定角色不存在 |

---

### `POST /roles/{id}/interrupt`

中斷指定角色**當前正在執行的 AI 回應**，不終止 session。中斷後角色回到 `idle` 狀態，可繼續接收新訊息。

**Response**

| Status | 說明 |
|--------|------|
| `200 OK` | 中斷指令已送出 |
| `404 Not Found` | 指定角色不存在 |

> App 在串流中點擊「停止」按鈕時呼叫此端點（對應 SDK `session.Abort()`）。

---

### `GET /roles/{id}/files`

取得指定角色的工作目錄樹（`work_dir` 內的遞迴檔案結構）。App 選擇角色時呼叫。

**Path Parameters**

| 參數 | 說明 |
|------|------|
| `id` | 角色 ID |

**Query Parameters**

| 參數 | 必填 | 說明 |
|------|------|------|
| `depth` | 否 | 最大目錄深度，預設為 `3`；`0` 表示不限深度 |

**Response `200 OK`**

```json
{
  "root": "/path/to/spec",
  "tree": [
    {
      "name": "decisions",
      "path": "decisions",
      "type": "dir",
      "children": [
        {
          "name": "README.md",
          "path": "decisions/README.md",
          "type": "file",
          "modified": "2026-03-15T02:00:00Z"
        }
      ]
    }
  ]
}
```

| 欄位 | 型別 | 說明 |
|------|------|------|
| `root` | string | 角色 `work_dir` 的絕對路徑 |
| `tree` | array | 遞迴目錄節點陣列（僅包含 `work_dir` 相對路徑）|

**Response**

| Status | 說明 |
|--------|------|
| `200 OK` | 目錄樹回傳成功 |
| `404 Not Found` | 指定角色不存在 |
| `500 Internal Server Error` | `work_dir` 無法存取 |

---

### `GET /auth/status`

查詢 Copilot API 認證狀態。

**Response `200 OK`**

```json
{
  "authenticated": true,
  "mode": "copilot"
}
```

| 欄位 | 型別 | 說明 |
|------|------|------|
| `authenticated` | boolean | 是否已通過認證 |
| `mode` | string | `"copilot"` 或 `"byok"` |

> 若尚未呼叫 `POST /configure`，`authenticated` 為 `false`，`mode` 為空字串。

---

### `GET /models`

回傳 Copilot SDK 支援的模型清單。需先呼叫 `POST /configure` 且至少有一個角色 session 建立完成。

**Response 200**

```json
[
  {
    "id": "gpt-5.4",
    "name": "GPT-5.4",
    "reasoning_effort_options": ["low", "medium", "high", "extra_high"],
    "billing_multiplier": 1.0
  },
  {
    "id": "gpt-4o",
    "name": "GPT-4o",
    "reasoning_effort_options": null,
    "billing_multiplier": 1.0
  }
]
```

**ModelInfo 欄位**

| 欄位 | 型別 | 說明 |
|------|------|------|
| `id` | string | 模型唯一識別碼 |
| `name` | string | 模型顯示名稱 |
| `reasoning_effort_options` | `string[]` \| `null` | 模型支援的推理力度選項；順序即顯示順序；`null` 或空陣列表示該模型不支援 reasoning effort |
| `billing_multiplier` | `number` \| `null` | 費率倍率（來自 Copilot SDK `Billing.Multiplier`）；`0` 代表不消耗配額；`null` 表示 SDK 無此資料 |

> `reasoning_effort_options` 由 Server 直接傳遞 SDK `SupportedReasoningEfforts` 的原始 token 與順序；  
> App 與 Server 驗證皆不得硬編碼固定 allow-list（例如只允許 `low` / `medium` / `high`）。

**Response 503**：尚無 active session（尚未 configure）。

---

## WebSocket：`GET /ws`

升級為 WebSocket 連線。連線成功後，Server 持續推播所有角色的事件。

**升級**

| Status | 說明 |
|--------|------|
| `101 Switching Protocols` | 升級成功 |
| `400 Bad Request` | 非 WebSocket upgrade 請求 |

---

### 事件格式

```json
{
  "type": "<event_type>",
  "role_id": "<角色 ID>",
  "payload": { ... }
}
```

---

### 事件類型

#### `role.status`

角色狀態變更。

```json
{
  "type": "role.status",
  "role_id": "spec",
  "payload": {
    "status": "running"
  }
}
```

`status` 值：`idle` / `running` / `waiting` / `done` / `error`（見 `spec/shared/agent_status.md`）

---

#### `role.output`

AI 串流輸出（逐 chunk）。

```json
{
  "type": "role.output",
  "role_id": "spec",
  "payload": {
    "chunk": "規格已更新"
  }
}
```

---

#### `role.output_end`

本次 Agent Loop 輸出結束。

```json
{
  "type": "role.output_end",
  "role_id": "spec",
  "payload": {}
}
```

---

#### `role.tool_call`

角色正在執行工具。

```json
{
  "type": "role.tool_call",
  "role_id": "spec",
  "payload": {
    "tool": "bash",
    "command": "git -C code/ pull"
  }
}
```

---

#### `role.error`

角色執行發生錯誤。

```json
{
  "type": "role.error",
  "role_id": "spec",
  "payload": {
    "message": "SDK session lost connection"
  }
}
```

| 欄位 | 型別 | 說明 |
|------|------|------|
| `message` | string | SDK 原始錯誤訊息 |

> **目前版本**：payload 僅含 `message`，App 依關鍵字做客戶端分類（詳見 `spec/app/screens/main_ide.md` — 錯誤氣泡章節、`spec/decisions/260316_002_RoleErrorClassification.md`）。
>
> **未來優化（TBD）**：Server 可新增 `error_type` 欄位（`quota` / `rate_limit` / `connection` / `general`），讓 App 直接使用結構化分類，減少關鍵字 heuristic 依賴。

---

#### `role.permission_request`

SDK 需要使用者確認 / 選擇 / 回應（觸發角色進入 `waiting` 狀態）。App 收到後應顯示 PermissionCard，並在使用者操作後呼叫 `POST /roles/{id}/permission_response`。

```json
{
  "type": "role.permission_request",
  "role_id": "spec",
  "payload": {
    "request_id": "550e8400-e29b-41d4-a716-446655440000",
    "question": "Allow running shell command?",
    "choices": ["Allow", "Deny"]
  }
}
```

| 欄位 | 說明 |
|------|------|
| `request_id` | 唯一識別碼，回應時帶回 |
| `question` | SDK 原始提示文字 |
| `choices` | SDK 提供的選項清單；順序即 App 顯示順序；空陣列表示 App Phase 1 採 legacy binary approval fallback（`允許` / `拒絕`） |
