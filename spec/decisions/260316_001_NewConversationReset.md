# 260316_001 — 開新對話：Session Reset 流程設計

> 日期：2026-03-16
> 發起：osw-myai-app（Request #16）
> 狀態：已採用

---

## 問題背景

AI 對話記憶儲存在 **Server 端 SDK Session 物件**中。使用者希望能在不重啟 App 的情況下，清除目前角色的對話記憶、開始全新對話。

---

## 可選方案

### 方案 A：重啟 App（現有行為）

- App 重啟 → 重新呼叫 `POST /configure` → Server 建立新 session
- **缺點**：體驗差，強迫使用者重啟才能清除

### 方案 B：新增專用 `POST /roles/{id}/reset` API

- 語意明確，一個 API 完成全部動作
- **缺點**：需要 Server 端新增端點；目前 `DELETE + POST /configure` 已能達成相同效果，額外端點為重複抽象

### 方案 C：`DELETE /roles/{id}` + `POST /configure`（已採用）

- 利用現有 API 組合完成 session reset
- `DELETE` 移除舊 session（清除 AI 記憶）
- `POST /configure` 重建乾淨 session（等同角色重啟，但不重啟 Server process）
- **優點**：不需新增 Server 端點，App 端已有完整控制權

---

## 採用決策

採用**方案 C**，以 `DELETE /roles/{id}` → `POST /configure` 序列作為正式支援的 session reset 操作。

---

## UI 設計決策

### 按鈕位置
- TopBar「複製按鈕」右側，圖示 `add_comment_outlined`
- 串流進行中自動 disabled（防止誤觸）

### 確認 Dialog
- 「開新對話」是**破壞性操作**（無法復原），需強制確認
- Dialog 採 `color-error` 風格（警告圖示 + 紅色確認按鈕），符合現有危險操作 UX 規範

### UI 先清、Server 後重置（非同步策略）

**決策**：使用者確認後，先立即清空 UI 訊息列表，再依序呼叫 Server API。

**取捨分析**：

| 面向 | UI 先清 | 等 Server 成功後再清 |
|------|---------|-------------------|
| 使用者感受 | 即時回饋，感覺流暢 | 有延遲感（需等 Server 兩次 round trip）|
| 一致性風險 | Server 失敗時 UI 已清空（不回滾）| UI 與 Server 狀態保持同步 |
| 實際影響 | Server 失敗機率極低（本地服務）| —

**結論**：本地 Server `DELETE` + `POST /configure` 失敗機率接近零（網路在 localhost），UI 即時反饋帶來的體驗優先。Server 操作失敗時顯示錯誤 SnackBar 告知使用者，不回滾 UI 清空狀態。

---

## 相關規格

- `spec/app/screens/main_ide.md` — TopBar 開新對話按鈕與 Dialog 規格
- `spec/server/api.md` — `DELETE /roles/{id}` 補充 Session Reset 說明
