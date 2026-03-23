# 260313_001 — 新增 App 畫面規格與設計系統文件（逆向正規化）

> 日期：2026-03-13
> 影響範圍：spec/app/screens/main_ide.md、spec/app/screens/settings.md、spec/app/design_system.md、spec/shared/agent_status.md

---

## 背景

app 角色已完成 MyAi 首版 demo 實作，包含主畫面三欄佈局（`code/lib/demo_page.dart`）、設計系統（`code/lib/theme/`、`code/lib/widgets/`），但 `spec/app/` 中缺乏對應的正式規格文件。

app 角色透過 Request #2 請求 spec 角色將實作行為正規化為規格文件。

---

## 問題

1. 主畫面三欄佈局的規格應記錄到什麼層次？是否規定 App 內部 class/state 結構？
2. 角色執行狀態（idle/running/done/error）是 app-only 概念，還是跨端共用概念？
3. 設計系統規格的邊界：spec 層應管到哪裡，UX 層管哪裡，app 層自主哪裡？

---

## 候選方案

### 問題 1：規格層次

| 方案 | 說明 |
|------|------|
| A：僅記錄畫面結構與互動行為（本決策）| spec 描述外部行為，不規定 Flutter class/state 設計 |
| B：詳細規定 widget tree 與 state 結構 | 過度侵入 app 實作，違反「實作層擁有內部模型設計」原則 |

### 問題 2：角色執行狀態歸屬

| 方案 | 說明 |
|------|------|
| A：放在 spec/app/（僅 App 自用）| 低估狀態的語意範圍，Server 也需要定義狀態推播格式 |
| B：放在 spec/shared/（本決策）| 跨 App / Server 共用，是產品級概念 |

### 問題 3：設計系統邊界

| 層 | 管理內容 |
|----|----------|
| spec/shared/design_tokens.md | 品牌色、語意色、字型名稱（跨端）|
| spec/app/design_system.md（本決策）| App 元件索引、字型載入方式、AppColors 使用方式 |
| ux/code/guidelines/ | 完整 UX 規範（色碼、字級 scale、間距）|
| App 內部 | ThemeExtension、TextTheme 實作細節 |

---

## 決定

1. **主畫面規格只描述畫面結構、欄位定義、互動行為、資料來源**，不規定 Flutter 內部 class / widget tree / state model
2. **角色執行狀態定義放入 `spec/shared/agent_status.md`**，作為跨端共用概念
3. **設計系統規格分三層管理**（如上表），spec/app/design_system.md 提供元件索引與使用規則，不重複 UX 的色碼細節

---

## 取捨理由

- 維持「實作層擁有內部模型設計」原則，避免 spec 過度干涉 app 實作
- 角色狀態是 Server 推播、App 顯示的跨端契約，放 shared 更符合分層原則
- 設計系統分層明確，避免 spec / UX / app 三層重複維護相同資訊

---

## 影響範圍

- 新增 `spec/app/screens/main_ide.md`
- 新增 `spec/app/screens/settings.md`
- 新增 `spec/app/design_system.md`
- 新增 `spec/shared/agent_status.md`
- 更新 `spec/decisions/README.md`
