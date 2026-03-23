# 260316_003 — Reasoning Effort 設計決策

> 日期：2026-03-16
> 發起：osw-myai-app（Request #18）
> 狀態：已採用
> 後續更新：`260316_004_ReasoningEffortDynamicOptions.md` 已取代本文「Phase 1 採靜態清單」之前提；本文其餘關於顯示時機、per-role 設定與預設值的討論仍可參考

---

## 問題背景

部分 AI 模型（Claude Sonnet/Opus extended thinking、OpenAI o1/o3 系列）支援 **Reasoning Effort** 參數（`low` / `medium` / `high`），讓使用者在速度與推理品質之間取捨。App 的 Model Selector 已在規格中，但尚無 Reasoning Effort 的規格定義。

---

## 決策一：API 架構

### 問題
`reasoning_effort_options` 是否應由 Server 動態從 SDK 取得，還是靜態維護？

### 結論
**Phase 1 採靜態清單**：Server 根據已知模型 ID 靜態設定 `reasoning_effort_options`，不依賴 SDK 動態中繼資料。

**理由**：
- 目前 SDK 不確定是否提供 per-model 的 reasoning effort 能力查詢 API
- 受支援模型數量少且穩定（Claude Sonnet/Opus、o1/o3 系列），靜態維護成本低
- 未來 SDK 若提供動態中繼資料，再改為動態取得，App 端 API contract 不需改變

---

## 決策二：UI 顯示時機

### 問題
Reasoning Effort 選擇器應「只在支援模型時顯示」，還是「永遠顯示但不支援時 disable」？

### 評估

| 方案 | 優點 | 缺點 |
|------|------|------|
| **只在支援時顯示（採用）** | UI 簡潔，不造成困惑；不支援的模型不出現無用選項 | 工具列佔位空間動態變化 |
| 永遠顯示但 disable | 佔位穩定 | Disabled 狀態對使用者無意義，增加認知負擔 |

**結論**：採用「只在支援時顯示」，選擇器完整隱藏（不保留佔位空間）。工具列動態寬度由 spacer 吸收，不影響其他元件位置。

---

## 決策三：設定範圍（per-role vs 全域）

### 問題
Reasoning Effort 應每個角色獨立設定，還是全域單一設定？

### 結論
**per-role 獨立設定**。

**理由**：不同角色承擔不同任務性質，例如：
- spec / docs 角色：任務以整理文件為主，`low` 或 `medium` 已足夠
- qa / data 角色：需要複雜推理，`high` 更合適

使用者可為每個角色獨立調整，而非在全域切換後忘記。

---

## 決策四：預設值

**預設 `medium`**（標準模式）。

**理由**：`medium` 在速度與品質之間取得平衡，適合初次使用；`high` 較慢且較貴，應由使用者主動選擇；`low` 品質犧牲較明顯，不適合預設。

---

## 相關規格

- `spec/server/api.md` v1.3.0 — `GET /models` ModelInfo 結構、`POST /roles/{id}/message` reasoning_effort 欄位
- `spec/app/screens/main_ide.md` v1.11.0 — AiChatInput 推理力度選擇器
