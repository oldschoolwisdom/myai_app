# 260316_008 — PermissionCard 多選項回應與 `allowed` 語意釐清

> 日期：2026-03-16
> 發起：osw-myai-spec（Request #23）
> 狀態：已採用

---

## 問題背景

既有規格把 PermissionCard 視為單純的「允許 / 拒絕」二元確認卡片。  
但 Server API 其實已定義：

- `role.permission_request.payload.choices` 為 `string[]`
- `POST /roles/{id}/permission_response` 可帶 `answer`

也就是說，底層 contract 早已能表達「多個可選答案」，只是 App UI 仍硬編碼成兩顆按鈕，導致 SDK / Server 傳來 3 個以上選項時，使用者無法正確回應。

此外，`allowed` boolean 在多選項情境下若仍解讀為「正向 / 反向選項」，會出現語意問題：

- 若 choice 本身文字是 `Deny`、`Skip`、`No`，它可能只是**合法答案**
- 但 `allowed=false` 在 Server 目前代表的是「中止此次 user input request」，而不是「把某個負向 choice 傳回 SDK」

因此需要同時更新 UI 規格與 API 語意說明。

---

## 決策一：PermissionCard 改為依 `choices` 動態渲染

### 問題

PermissionCard 是否仍固定只有「允許 / 拒絕」兩顆按鈕？

### 候選方案

| 方案 | 優點 | 缺點 |
|------|------|------|
| 維持固定二元按鈕 | UI 最簡單 | 無法支援多選項 request |
| **依 `choices` 動態渲染（採用）** | 與 API contract 一致；可支援任意數量選項 | UI 規格需補充更多狀態 |

### 結論

PermissionCard 的主要操作區改為：

- `choices.length >= 1`：依 `choices` 陣列順序動態渲染 choice buttons
- `choices.length == 0`：沿用 legacy binary approval UI（`允許` / `拒絕`）

### 理由

- `choices` 已是 API 的 canonical source，UI 應直接反映
- 可避免 Server / SDK 明明給出多個選項，但 App 卻只能回傳二元結果

---

## 決策二：`allowed` 不用來判斷 choice 文字的正負，而是表示「是否提交回答」

### 問題

多選項情境下，`allowed` 應如何定義？

### 候選方案

| 方案 | 優點 | 缺點 |
|------|------|------|
| 由 App 依 choice 文字猜測（如 `Deny` → `false`） | 不改 API schema | 極度脆弱；choice 文字可能是任意字串 |
| 以 choice 位置猜測（最後一項 = deny） | 實作簡單 | 沒有任何 API 保證；順序語意不可靠 |
| **`allowed` = 是否提交回答（採用）** | 與目前 Server 實作一致；不需猜測 choice 文字語意 | 需在 spec 明確說明「拒絕」與「選擇負向 answer」不同 |

### 結論

`allowed` 改解讀為：

- `true`：使用者**提交了一個有效回答**給 SDK
- `false`：使用者**拒絕 / 取消此次 request**，不將任何 answer 傳回 SDK

因此：

- 使用者點擊某個 `choice` 按鈕 → `allowed=true` + `answer=<selected choice>`
- 使用者點擊 App 的獨立「拒絕」按鈕 → `allowed=false`，`answer` 省略

> 重要：App / Server **不得**從 `answer` 文字推斷 `allowed`。  
> 例如 `answer="Deny"` 且 `allowed=true` 代表「把 `Deny` 當作合法答案回給 SDK」，  
> 與 `allowed=false` 的「中止此次 request」是兩件不同的事。

### 理由

- choice 文字是 agent / SDK 決定的任意字串，不應由 App 做語意猜測
- 這與目前 Server 行為一致：`allowed=false` 代表 request 被拒絕；`allowed=true` 則把 `answer` 傳回 SDK

---

## 決策三：App 保留獨立「拒絕」操作，不把它混入 choices

### 問題

App 是否只顯示 choices，不再提供獨立拒絕操作？

### 結論

App 仍保留一個**獨立的「拒絕」按鈕**，其語意是「取消 / 中止此次 request」，不屬於 `choices` 陣列的一部分。

### 理由

- 使用者需要一個明確的「不要回答這個 request」出口
- 若把 App-level rejection 與 choice selection 混為一談，會讓 `allowed=false` 無法表達
- 即使某個 choice 文字看起來像負向回答（例如 `Deny`），那仍是 agent 收到的**業務答案**，不是 App-level cancellation

---

## 決策四：`choices` 為空時，Phase 1 維持 legacy binary approval fallback

### 問題

若 `choices` 為空，PermissionCard 應如何顯示？

### 評估

目前 SDK 還有 `AllowFreeform` / freeform user input 能力，但現行 MyAi WebSocket payload 與 App UI 尚未納入該模式。  
若在本次直接擴充為自由輸入框，會超出本 issue 範圍，也需要額外 API / UI 設計。

### 結論

Phase 1 對 `choices=[]` 採 **legacy binary approval fallback**：

- 顯示 `允許` + `拒絕`
- 點 `允許` → `allowed=true`，`answer` 可省略
- 點 `拒絕` → `allowed=false`

### 理由

- 與目前產品已上線的二元 permission UX 相容
- 可先解決「多選項無法操作」的核心問題
- generic freeform input 留待後續獨立規劃

---

## 決策五：回應後卡片文案改為「已回覆 / 已拒絕」

### 問題

原本回應後只有「已允許 / 已拒絕」，在多選項情境下不再合適；選到 `Blue`、`Allow once`、`Deny` 都不等於「已允許」。

### 結論

- 選擇某個 choice（或 legacy 空 choices 下點 `允許`）→ 卡片進入 **已回覆** 狀態
  - 顯示 `回應：{answer}` 摘要
- 點擊獨立「拒絕」按鈕 → 卡片進入 **已拒絕** 狀態

### 理由

- 「已回覆」比「已允許」更中性，適合任意 choice
- 可清楚區分「提交某個答案」與「拒絕整個 request」

---

## 影響範圍

- `spec/app/screens/main_ide.md` — PermissionCard 改為動態 choice buttons
- `spec/server/api.md` — `allowed` / `answer` 語意補充
- `spec/shared/agent_status.md` — waiting 回應後的描述文案更泛化

---

## 後續但不在本次範圍

- `AllowFreeform` / generic freeform user input UI
- `POST /permission_response` 對 `answer ∈ choices` 的 server-side 嚴格驗證
- choice button 的 richer metadata（例如 destructive / default / recommended 標記）

