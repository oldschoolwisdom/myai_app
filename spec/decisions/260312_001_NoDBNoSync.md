# 260312_001 — App 不採用本地資料庫與後端同步

> 日期：2026-03-12
> 影響範圍：spec/app/tech_stack.md

---

## 背景

技術選型草稿（v1.0.0，2026-02-25）包含以下元件：
- **Drift**：本地 SQLite / IndexedDB / WASM SQLite 資料庫
- **自製 Sync API**：`/sync/pull` + `/sync/push`，last-write-wins 衝突解決
- **connectivity_plus**：監聽網路狀態，恢復時自動觸發 sync

## 問題

本專案的使用情境不需要離線儲存或多裝置資料同步。

## 候選方案

| 方案 | 說明 |
|------|------|
| A：保留全套（原草稿） | 維持 Drift + Sync + connectivity_plus |
| B：移除 DB 與 Sync（本決策） | 不引入本地資料庫與同步機制，降低複雜度 |

## 決定

採用**方案 B**。

## 取捨理由

- 本地資料庫與同步層是顯著的複雜度來源（schema migration、衝突解決、sync 狀態管理）
- 本專案不需要離線操作或多裝置同步，引入這套機制會增加維護成本卻無對應收益
- 移除後 code generation 也減少一個 target（`drift_dev`），build 速度更快

## 影響範圍

- `spec/app/tech_stack.md`：移除 Drift、Sync API、connectivity_plus 相關欄位
- App 實作：不建立 Drift database class，不實作 sync service
- 若未來需求改變需要離線/同步，應重新發 [Request] 評估引入
