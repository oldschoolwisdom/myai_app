# 260322_001 — macOS App Sandbox Entitlements 規格化

> 日期：2026-03-22  
> 決策者：spec 角色  
> 相關 Issue：spec#33、spec#32  
> 影響文件：`spec/app/platform/macos.md`（新增）、`spec/app/tech_stack.md`

---

## 背景

app 角色在實作以下功能時，發現 macOS App Sandbox 預設封鎖相關能力，需在 entitlements 明確宣告：

1. **file_picker 資料夾選擇（spec#32）**：`file_picker.getDirectoryPath()` 在 sandbox 下靜默失敗（不報錯、不開 dialog），需宣告 `com.apple.security.files.user-selected.read-write`
2. **完整 macOS 平台權限（spec#33）**：實作多個功能後，整理出一份完整的 entitlements 清單，包含：
   - 網路連線（`network.client` + `network.server`）
   - 設定檔讀寫（`files.downloads.read-write`）
   - 子進程啟動（`cs.disable-library-validation`）
   - OSW-MyAI-Agent binary 的 ad-hoc code sign 需求

---

## 問題

macOS 平台權限設定（entitlements）是實作必要條件，但此前未納入任何規格文件，導致：
- app 角色需自行發現並補上，缺乏共識文件
- 未來重新實作時可能再度遺漏相同設定

---

## 候選方案

| 方案 | 說明 | 優缺點 |
|---|---|---|
| A. 加入 `tech_stack.md` | 在技術選型中補充 macOS 設定章節 | 位置不夠聚焦，tech_stack.md 以套件清單為主 |
| B. 新增 `spec/app/platform/macos.md` | 獨立文件，專注 macOS 平台設定 | 清楚分層，未來 Windows/Linux 可仿照新增 |
| C. 加入 `decisions/` 只做為決策 | 不建立長駐規格，僅記錄決策 | 缺乏可查閱的規格基準，不利後續維護 |

---

## 決定

採用**方案 B**：新增 `spec/app/platform/macos.md`，作為 macOS 平台設定的長駐規格。

同時在 `tech_stack.md` 補入 `file_picker` 套件（此前遺漏）。

---

## 取捨理由

- macOS 平台設定（entitlements、sandbox、code sign）與套件清單性質不同，分層更清晰
- 未來若需支援 Windows / Linux，可仿照新增 `platform/windows.md` / `platform/linux.md`
- 獨立文件方便 app 角色查閱，也方便 ops / CI 流程參考

---

## 影響範圍

- 新增 `spec/app/platform/macos.md`（macOS 平台設定規格）
- `spec/app/tech_stack.md` 補入 `file_picker` 套件
- server 角色 CI/CD 需在 build binary 後執行 ad-hoc code sign
