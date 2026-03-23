# 260312_003 — 支援深色模式，Dark mode primary 使用 Cyan

> 日期：2026-03-12
> 影響範圍：spec/app/tech_stack.md、spec/shared/design_tokens.md

---

## 背景

技術選型草稿原標註「不支援深色模式」。UX 角色在設計色彩系統時，已規劃完整的 Light / Dark 雙模式，並提出 [Request] Issue #1 確認是否同步至 spec。

## 問題

1. 是否支援深色模式？
2. Dark mode 的 primary color 應使用哪個品牌色？

## 候選方案

| 方案 | 說明 |
|------|------|
| A：不支援深色模式 | 維持原技術選型，僅 Light mode |
| B：支援 Light / Dark 雙模式（本決策） | 採用 UX 規範，Material 3 內建雙模式支援 |

**Dark mode primary 候選：**

| 色碼 | 問題 |
|------|------|
| Deep Navy `#0B2D72` | 深色背景對比度不足，未達 WCAG 標準 |
| Cyan `#0AC4E0`（本決策） | 對比度符合 WCAG，視覺清晰 |

## 決定

- **支援 Light / Dark 雙模式**
- **Dark mode primary = Cyan `#0AC4E0`**

## 取捨理由

- Material 3 原生支援深色模式，Flutter 實作成本低
- Deep Navy 在深色背景對比不足，Cyan 對比度符合 WCAG 標準
- 一致的雙模式體驗符合現代桌面 App 預期

## 影響範圍

- `spec/app/tech_stack.md`：更新 Material 3 說明為「支援 Light / Dark 雙模式」
- `spec/shared/design_tokens.md`：記錄 Dark mode primary = Cyan 規則
