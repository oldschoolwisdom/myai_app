# 260316_007 — dispatcher 改為 mandatory built-in role

> 日期：2026-03-16
> 發起：osw-myai-spec（Request #24）
> 狀態：已採用

---

## 問題背景

現行規格將角色來源簡化為「掃描 `ai/prompts/ltc-*.md`」。  
但實際協作體系中，`dispatcher` 已是特殊角色：

1. prompt 檔名為 `dispatcher.md`，不符合 `ltc-*` 掃描規則
2. 沒有專用 repo；dispatcher 相關 issue 落在 ai repo
3. 使用 `ADMIN_TOKEN` / `ADMIN_ACCOUNT`
4. 未來 App 可能需要透過 dispatcher 來創建角色，因此 dispatcher 必須穩定存在

若產品規格仍把角色來源限定為 prompt 掃描，則在缺少 `dispatcher.md` 的環境中，App 將無法建立 dispatcher，與實際運作不一致。

---

## 決策一：新增 built-in role 概念，dispatcher 為 Phase 1 唯一 built-in role

### 問題

角色是否仍全部來自本地 prompt 掃描？

### 候選方案

| 方案 | 優點 | 缺點 |
|------|------|------|
| 全部依賴本地掃描 | 實作單純 | 無法涵蓋 dispatcher 的特殊性 |
| 將 dispatcher 改名為 `ltc-dispatcher.md` | 可沿用掃描規則 | 與現有 ai repo、腳本與帳號模型不一致 |
| **引入 built-in role（採用）** | 能正規化 dispatcher 的特殊地位；未來可擴充其他 built-in role | App / Server contract 需補充 |

### 結論

角色來源分為兩類：

- `builtin`：產品內建角色
- `scanned`：由 `ai/prompts/ltc-*.md` 掃描取得的角色

Phase 1 只有一個 built-in role：`dispatcher`。

### 理由

- 與實際 ai repo / run-role 腳本行為一致
- 能支援未來「App 透過 dispatcher 創建角色」的延伸
- 避免為了單一特殊角色，去扭曲所有一般角色的掃描規則

---

## 決策二：dispatcher 為 mandatory built-in role，永遠存在且永遠啟用

### 問題

dispatcher 是否應像一般角色一樣，受 `ENABLED_ROLES` 控制或因 prompt 缺失而消失？

### 結論

`dispatcher` 定義為 **mandatory built-in role**：

- App 啟動時一定注入角色目錄
- 一定加入 effective enabled set
- 不可在 App UI 停用或刪除
- 不得被標記為「prompt 遺失」孤立角色

### 理由

- 其存在不應取決於本地 prompt 檔是否存在
- 未來若 App 需要用 dispatcher 做角色建立 / 協調，停用它會使流程失效
- 使用者可調整的是一般角色，而非整個協調機制

---

## 決策三：`POST /configure` 新增 built-in role contract，dispatcher 採內建 prompt fallback

### 問題

Server 如何在沒有 `dispatcher.md` 的情況下建立 dispatcher？

### 評估

| 方案 | 優點 | 缺點 |
|------|------|------|
| App 必須先找到 `dispatcher.md` 才能 configure | contract 不變 | 仍違反需求 |
| App 內嵌 prompt 文本後直接傳給 Server | 不需改 API | prompt canonical source 落到 App，不理想 |
| **Server 支援 built-in prompt fallback（採用）** | 角色是否存在與本地檔脫鉤；仍可保留本地 override | 需補 API schema |

### 結論

`POST /configure` 的 role config 新增 `builtin_id`：

- `builtin_id=dispatcher` 時，Server 可使用內建 `dispatcher` prompt 建立角色
- `prompt_path` 對 built-in role 改為 optional
- 若同時提供 `prompt_path`，視為本地 override
- 若 `prompt_path` 缺漏、檔案不存在或不可讀，Server 記錄 warning 後回退至內建 prompt

### 理由

- 讓 dispatcher 的「存在性」與本地檔案解耦
- 仍保留本地 `dispatcher.md` 作為可替換的 prompt override
- 將 prompt fallback 責任放在 Server，避免 App 必須理解 prompt 內容

---

## 決策四：dispatcher 的 `work_dir` 採 project root

### 問題

dispatcher 沒有專用 repo，工作目錄應如何定義？

### 結論

dispatcher 的 `work_dir` 使用 **project root**。

### 理由

- dispatcher 的職責本來就跨 repo
- project root 仍是明確的 sandbox 邊界
- 比「無 work_dir」更符合既有 Server 的 `ClientOptions.Cwd` 模型

---

## 決策五：一般角色掃描規則維持不變

### 問題

是否要把所有角色掃描規則改成更寬鬆，例如掃描所有 `.md`？

### 結論

不修改一般角色掃描規則，仍為 `ai/prompts/ltc-*.md`。  
只對 dispatcher 引入 built-in 特例。

### 理由

- 避免把暫時且單一的特殊需求擴散到整個角色命名規範
- `ltc-*` 已是一般角色穩定慣例
- 內建角色用 API schema 顯式表達，比依檔名猜測更清楚

---

## 影響範圍

- `spec/shared/roles.md` — 新增角色來源與 dispatcher 定義
- `spec/shared/agent_status.md` — 啟動前置狀態改為 built-in + scanned roles
- `spec/app/screens/main_ide.md` — 啟動流程、降級模式、Sidebar 注意事項
- `spec/app/screens/system_status.md` — built-in role 行為、env 規則
- `spec/server/overview.md` — built-in role 概念、dispatcher `work_dir`
- `spec/server/api.md` — `POST /configure` role config 新增 `builtin_id`

---

## 後續但不在本次範圍

- App 透過 dispatcher 創建新角色
- built-in role catalog 擴充為超過一個角色
- dispatcher 的專屬 UI 入口 / badge / triage 視圖

