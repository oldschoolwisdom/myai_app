# 260312_004 — 全 App 字級下限 18sp

> 日期：2026-03-12
> 影響範圍：spec/shared/design_tokens.md

---

## 背景

UX 角色在字型系統規範中定義「全 App 字級下限：18sp」，並標注為產品決策，請 spec 確認是否寫入 spec/decisions/。

## 問題

最小字級應設多少？Material Design 3 預設 Body Small 為 12sp，對桌面 AI IDE 使用情境是否合適？

## 候選方案

| 方案 | 最小字級 | 說明 |
|------|----------|------|
| A：MD3 預設 | 12sp | 依 Material Design 3 標準 |
| B：18sp（本決策） | 18sp | 桌面 IDE 長時間閱讀，保障可讀性 |

## 決定

**全 App 字級下限 18sp**，不得使用小於 18sp 的字級。

## 取捨理由

- AI IDE 的核心使用情境是長時間閱讀 AI 回應（Markdown、程式碼說明）
- 桌面環境通常距離螢幕較近，18sp 保障長時間閱讀不疲勞
- 小字 (12–14sp) 在密集內容場景容易造成視覺負擔

## 影響範圍

- `spec/shared/design_tokens.md`：記錄 18sp 下限規則
- App 實作：所有 TextStyle 不得低於 18sp
