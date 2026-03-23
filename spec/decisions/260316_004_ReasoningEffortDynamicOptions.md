# 260316_004 — Reasoning Effort 動態 options 設計更新

> 日期：2026-03-16
> 發起：osw-myai-app（Request #20）
> 狀態：已採用

---

## 問題背景

`260316_003_ReasoningEffort.md` 的 Phase 1 規劃原先假設 Reasoning Effort 只有固定三層：`low` / `medium` / `high`。  
但實際 SDK 已能提供模型的 `SupportedReasoningEfforts`，且新模型可能出現額外等級（例如 `extra_high`）。

若規格、App UI 與 Server 驗證仍寫死三層，會產生兩個問題：

1. App 無法正確顯示新 option
2. Server 會把合法的新 token 擋成 400

因此需要把 Reasoning Effort 從「固定 enum」調整為「動態 options」。

---

## 決策一：API contract 改為動態 options

### 問題

`GET /models` 的 `reasoning_effort_options` 是否仍維持固定三層語意，還是直接沿用 SDK 的動態資料？

### 結論

採用 **動態 `string[] | null`**：

- Server 直接傳遞 SDK `SupportedReasoningEfforts`
- 保留 SDK 的**原始 token**
- 保留 SDK 回傳的**原始順序**
- `null` 或空陣列表示該模型不支援 reasoning effort

`POST /roles/{id}/message` 的 `reasoning_effort` 亦改為：

- 型別仍為 `string`
- 值必須是此次請求實際使用模型的 `reasoning_effort_options` 其中之一
- 若模型不支援 reasoning effort，則不得傳送此欄位

### 理由

- SDK 已是此能力的 canonical source，直接沿用可避免 spec 與實作再度漂移
- 新模型若增加 token（如 `extra_high`），無需再次修改 API contract
- App 顯示邏輯與 Server 驗證規則可共用同一份資料來源

> 此決策**取代** `260316_003` 中「Phase 1 採靜態清單」的前提。  
> 但「只在支援模型時顯示」與「per-role 獨立設定」仍維持不變。

---

## 決策二：App Phase 1 顯示文字採 humanize，不新增 display_name 欄位

### 問題

API 是否要另外提供 `display_name`，或由 App 直接顯示原始 token？

### 評估

| 方案 | 優點 | 缺點 |
|------|------|------|
| API 額外提供 `display_name` | UI 可直接顯示在地化文字 | 增加 API 複雜度；需要決定語系責任歸屬 |
| 直接顯示 raw token | 最簡單，零轉換 | `extra_high` 等 snake_case 對使用者不友善 |
| **App humanize raw token（採用）** | 不改 API schema；`extra_high` 可顯示為 `Extra High`；易於擴充 | Phase 1 仍非完整在地化 |

### 結論

Phase 1 採 **App humanize**：

- API 只傳 raw token（例如 `extra_high`）
- App 將 `snake_case` 轉為 Title Case 顯示（例如 `Extra High`）
- 未來若需要完整 i18n / 在地化，再另行設計 `display_name` 或本地翻譯表

### 理由

- 能以最低成本支援未知新 token
- 不必為單一 UI 需求擴充 API schema
- 保留後續導入 i18n 的空間

---

## 決策三：預設值採 medium 優先，否則取第一項

### 問題

當某模型支援的 options 不再固定為三項時，第一次顯示選擇器應如何決定預設值？

### 結論

- 若 options 包含 `medium`，預設使用 `medium`
- 若不包含 `medium`，則使用第一個 option

若角色已有歷史選擇，但該值不在新 model 的 options 中，也套用同一回退規則。

### 理由

- `medium` 仍是最中性的預設值，符合既有使用者心智模型
- 若模型根本沒有 `medium`，直接退回第一個 SDK 建議順序，避免 spec 再次硬編碼特例

---

## 相關規格

- `spec/server/api.md` v1.3.2 — `GET /models` / `POST /roles/{id}/message`
- `spec/app/screens/main_ide.md` v1.11.2 — AiChatInput 推理力度選擇器
