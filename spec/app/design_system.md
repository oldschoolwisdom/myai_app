# MyAi — App 設計系統規格

> 版本：v1.1.0
> 日期：2026-03-22
> 來源：app 角色 Request #2，首版 demo 實作逆向正規化
> 修訂：2026-03-22（補充對話氣泡視覺規格，Request spec#39）

---

## 概覽

本文件描述 MyAi Flutter App 的設計系統，包含字型、色彩系統與可重用元件索引。
設計 Token（品牌色、語意色、字型）的跨端共用規格見 `spec/shared/design_tokens.md`。
UX 詳細規範見 `ux/code/guidelines/`。

---

## 字型

| 用途 | 字型 | 授權 |
|------|------|------|
| 內文（Latin/英數）| **Inter**（Variable font）| OFL 1.1 |
| 程式碼 / Mono | **JetBrains Mono**（Variable font）| OFL 1.1 |

> 中文補字：**Noto Sans TC**（見 `spec/shared/design_tokens.md`）

### 字型載入方式

- 字型以 **asset bundle** 方式內嵌於 App（`assets/fonts/` 目錄）
- **不依賴網路**下載，確保離線環境可用

### 字級限制

- **全 App 最小字級：18sp**（所有 Material 3 TextTheme slot 均不得小於 18sp）
- 決策依據見 `spec/decisions/260312_004_MinFontSize18sp.md`

---

## 色彩系統

- 使用 `AppColors` ThemeExtension 管理 Light / Dark 雙模式色彩
- 透過 `context.colors` 存取當前主題色彩
- 品牌色與語意 Token 定義見 `spec/shared/design_tokens.md`
- Dark mode primary = Cyan，決策見 `spec/decisions/260312_003_DarkModeSupport.md`

---

## 可重用元件索引

以下元件已實作，可直接使用於 App 畫面：

### 按鈕

| 元件 | 說明 |
|------|------|
| `AppFilledButton` | Filled 按鈕（主要動作）|
| `AppTonalButton` | Tonal 按鈕（次要動作）|
| `AppOutlinedButton` | Outlined 按鈕（輔助動作）|
| `AppTextButton` | Text 按鈕（低強調動作）|
| `AppIconButton` | Icon 按鈕 |

### 輸入

| 元件 | 說明 |
|------|------|
| `AppTextField` | 標準文字輸入框 |
| `AiChatInput` | AI 對話專用輸入框（含送出按鈕）|

### 卡片

| 元件 | 說明 |
|------|------|
| `AppCard` (elevated) | 浮起卡片 |
| `AppCard` (filled) | 填充卡片 |
| `AppCard` (outlined) | 邊框卡片 |

### Chip

| 元件 | 說明 |
|------|------|
| `AppFilterChip` | 篩選 Chip |
| `AppAssistChip` | 建議動作 Chip |
| `AppInputChip` | 輸入標籤 Chip |

### 導覽

| 元件 | 說明 |
|------|------|
| `AppNavigationRail` | 可收合側邊導覽欄（72dp 收合 / 200dp 展開）|

### 狀態顯示

| 元件 | 說明 |
|------|------|
| `StatusIndicator` | 角色執行狀態燈，支援 4 種狀態（見 `spec/shared/agent_status.md`）+ 動畫 |

### 對話訊息

| 元件 | 說明 |
|------|------|
| `UserMessage` | 使用者訊息氣泡 |
| `AiMessage` | AI 回應訊息，支援 Markdown 渲染、串流逐字顯示、錯誤狀態 |
| `CodeBlock` | 程式碼區塊，使用 JetBrains Mono，含複製按鈕 |

---

## 對話氣泡（Chat Bubble）視覺規格

### 氣泡樣式

| 屬性 | 使用者訊息（UserMessage） | AI 訊息（AiMessage） |
|------|--------------------------|----------------------|
| 對齊 | 右 | 左 |
| 背景色 | `primary` | `surface` |
| 文字色 | `white` | `onSurface` |
| 圓角 | 16px 全部 | 16px 全部 |
| Tail 箭頭 | 右側三角形（同 bgColor）| 左側三角形（同 bgColor）|

- Tail 使用 `CustomPaint` 繪製（`_BubbleTailPainter`），顏色與氣泡背景色一致

### 錯誤訊息

| 屬性 | 值 |
|------|-----|
| 背景色 | `error` 色 10% 透明度 |
| 文字色 | `error` |
| Tail 箭頭 | 左側三角形（同背景色）|

### 骨架與載入

| 元件 | 說明 |
|------|------|
| `SkeletonBlock` | 骨架載入佔位元件 |
| `FullPageLoader` | 全頁載入中 |
| `EmptyState` | 空狀態顯示 |

---

## 與設計 Token 的關係

```
spec/shared/design_tokens.md   ← 品牌色、語意色、字型名稱（跨端共用）
spec/app/design_system.md      ← App 元件索引、字型載入方式、AppColors 使用方式（本文件）
ux/code/guidelines/            ← 完整 UX 規範（色碼、字級 scale、間距）
```

App 內部的 ThemeExtension、TextTheme、色碼對應由 app 角色自主設計，僅需符合上述規格的外部契約。
