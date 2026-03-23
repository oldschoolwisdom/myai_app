# MyAi — 共用設計 Token

> 版本：v0.1.0
> 日期：2026-03-12
> 詳細規範見 `ux/code/guidelines/colors.md` 與 `ux/code/guidelines/typography.md`

---

## 品牌色彩

| Token | 色碼 | 名稱 |
|-------|------|------|
| `brand-deep-navy` | `#0B2D72` | Deep Navy |
| `brand-ocean-blue` | `#0992C2` | Ocean Blue |
| `brand-cyan` | `#0AC4E0` | Cyan |
| `brand-warm-sand` | `#F6E7BC` | Warm Sand |

---

## 語意 Token（Light / Dark）

| Token | Light | Dark |
|-------|-------|------|
| `color-primary` | Deep Navy `#0B2D72` | Cyan `#0AC4E0` |
| `color-secondary` | Ocean Blue `#0992C2` | Ocean Blue `#0992C2` |

> **規則**：Dark mode 的 `color-primary` 使用 Cyan，因 Deep Navy 在深色背景對比度不足 WCAG 標準。
> 完整 token 對應見 `ux/code/guidelines/colors.md`。

---

## 字型系統

| 用途 | 字型 |
|------|------|
| Latin / 英數 | Inter |
| 中文 | Noto Sans TC |
| 程式碼 / Mono | JetBrains Mono |

### 字級規則

- **全 App 字級下限：18sp**（不得使用小於 18sp 的字級）
- 字級 scale 依 Material Design 3 體系：Display / Headline / Title / Body / Label
- 完整 scale 見 `ux/code/guidelines/typography.md`

---

## 狀態色

| 用途 | 說明 |
|------|------|
| error | 錯誤 |
| warning | 警告 |
| success | 成功 |
| info | 資訊 |

> 詳細色碼見 `ux/code/guidelines/colors.md`。cd
