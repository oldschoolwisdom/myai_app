# 260313_002 — Flutter 狀態管理策略：StatefulWidget vs Riverpod

> 日期：2026-03-13
> 影響範圍：spec/app/tech_stack.md、所有 App widget 實作

---

## 背景

app 角色在實作設計系統元件時，將 `AppTextField` 從 `StatelessWidget` 改為 `StatefulWidget`，用於管理密碼輸入的顯示/隱藏切換（本地 UI 狀態，不需跨 widget 共享）。

產品負責人詢問是否應全面改用 Riverpod 管理所有狀態。雙方討論後確立明確策略，需落地為決策紀錄，避免日後開發者對狀態層級選擇產生疑慮。

---

## 問題

在已引入 Riverpod 的專案中，何時應用 `StatefulWidget`，何時應用 Riverpod provider？

---

## 候選方案

| 方案 | 說明 |
|------|------|
| A：全面 Riverpod | 所有狀態一律用 Riverpod provider，連本地 UI toggle 也用 StateProvider |
| B：依狀態性質分層（本決策）| 依「是否需要跨 widget 共享或持久化」決定使用層級 |

### 方案 A 的問題
- 將純 UI 本地狀態（如密碼 toggle、TextEditingController）提升到 provider，增加不必要的複雜度
- Riverpod 官方文件明確指出：不需要 `ref` 的本地 UI state 仍建議使用 `StatefulWidget`

---

## 決定

**依狀態性質分三層管理：**

| 情境 | 使用方式 |
|------|----------|
| 本地 UI 狀態（toggle、動畫 controller、text controller 等，不需跨 widget 共享）| `StatefulWidget` + `setState` |
| 需要讀寫 Riverpod provider 的 widget | `ConsumerStatefulWidget` + `ConsumerState` |
| 跨 widget 共享或需要持久化的狀態 | `@riverpod` code-gen + `ConsumerWidget` |

---

## 取捨理由

- 符合 Riverpod 官方建議的最佳實踐
- 本地 UI state 用 `StatefulWidget` 可降低認知負擔、減少不必要的 provider rebuild
- 清楚的分層規則讓開發者在每個情境都有明確依據，不需要每次重新判斷

---

## 技術背景

- 專案已引入 `flutter_riverpod ^3.3.1` + `riverpod_annotation` + `riverpod_generator`
- **未引入** `flutter_hooks`，不採用 `HookConsumerWidget` 路線
- 此策略不影響現有依賴，無需更動 `pubspec.yaml`

---

## 影響範圍

- **現有設計系統元件**（`AppTextField`、`AiChatInput`、`StatusIndicator` 等）採 `StatefulWidget`，符合此策略，無需修改
- **未來功能實作**（設定持久化、角色狀態管理等）應依此策略選擇正確層級
- `spec/app/tech_stack.md`：可在狀態管理章節補充此分層說明（供參考）
