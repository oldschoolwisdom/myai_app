# 260314_001 — ResizablePanels：三欄 Resizable & Collapsible Panels 設計

> 日期：2026-03-14
> 關聯 Issue：spec #6、spec #7
> 狀態：已確認

---

## 背景

主畫面三欄布局（左 Sidebar、中 Monitor、右 Directory）在 demo 開發過程中（`app/code demo_page.dart`）已實作可拖拉調整寬度，並進一步加入折疊按鈕與 auto-collapse。

App 角色提出 Request #6（resizable panels 基礎規格）與 Request #7（折疊 toggle、auto-collapse、卡片自適應），請求 spec 正式納入，一併處理。

---

## 候選方案

### 折疊觸發門檻（auto-collapse 閾值）

| 方案 | 閾值 | 考量 |
|------|------|------|
| A | 100px | 過窄，容易誤觸發 |
| B（選定）| 120px | 與折疊後 52px 之間有足夠緩衝，不容易誤觸 |
| C | 160px | 與卡片自適應門檻重合，在狹窄拖拉區間行為衝突 |

### 卡片自適應觸發門檻

| 方案 | 閾值 | 考量 |
|------|------|------|
| A（選定）| 160px | 和左欄最小預設寬度一致，符合設計預期可見資訊邊界 |
| B | 120px | 容易和 auto-collapse 門檻同時觸發，視覺跳躍明顯 |

### 卡片自適應元素選擇

- 候選：最後活動時間、未讀 badge、issue 預覽文字
- 決定：只同步隱藏「最後活動時間」與「未讀 badge」；issue 預覽文字保留（攜帶重要工作狀態）

### 右欄最小拖拉寬度

- 左欄可拖拉至 52px（與折疊一致），因此拖拉和折疊是連通的
- 右欄折疊需按按鈕，最小拖拉 160px，避免目錄樹內容過窄難以辨識

---

## 最後決定

### 欄寬參數

| 欄位 | 預設 | 最小（拖拉） | 折疊 | 最大 |
|------|------|-------------|------|------|
| 左（Sidebar） | 248px | 52px | 52px | 480px |
| 右（Directory） | 240px | 160px | 52px | 480px |
| 中（Monitor） | flex | — | — | — |

### 折疊行為

- 左右欄 header 各有折疊按鈕（`keyboard_double_arrow_left` / `right`）
- 折疊後寬度 52px，僅顯示 icon
- 折疊狀態下 ResizeDivider 改為細線，不可拖拉

### Auto-collapse（左欄限定）

- 拖拉至 < 120px → 自動折疊（52px）
- 拖拉至 ≥ 120px → 自動展開
- 右欄不支援 auto-collapse

### 卡片自適應

- 卡片可用寬度 < 160px → 同步隱藏「最後活動時間」+ 「未讀 badge」
- 角色名稱、waiting 文字、狀態 dot 不受影響

### 響應式折疊

- 視窗寬度 < 左欄寬 + 右欄寬 → 左右欄與分隔線全部隱藏，中央填滿全寬
- 視窗拉寬後恢復

---

## 影響範圍

- `spec/app/screens/main_ide.md`：新增「三欄 Resizable & Collapsible Panels」節，更新欄寬表、角色卡片欄位、注意事項
- app 角色：已實作，本次為正規化，不需額外修改（Request #6 #7 發起人已確認行為）
- 無 server / data / shared 異動
