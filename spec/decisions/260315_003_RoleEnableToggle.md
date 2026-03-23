# 260315_003 — 角色啟用開關設計（Role Enable Toggle）

> 日期：2026-03-15
> 狀態：已決定
> 關聯：spec/code/app/screens/system_status.md v1.1.0
> 觸發：app 角色實作中發現需求

---

## 背景

SDK Server 獨立執行時，並非所有角色都需要在每次 WebSocket 連線時啟動。
使用者需要能夠按角色獨立控制是否啟用（即是否在 SDK Server 上建立 session）。

---

## 問題

原本 `POST /configure` 會送出所有掃描到的角色，無法選擇性啟用。
且每次重新連線，停用的角色會被重新啟用（因為不在 enabled set 中就被視為「新角色」）。

---

## 候選方案

### A. 全量 configure，無法個別控制
- 簡單，但不符需求

### B. Whitelist（ENABLED_ROLES）+ 無 KNOWN_ROLES
- configure 只送 enabled 角色
- 但重連時無法區分「新角色」與「被停用的角色」
- 結果：每次連線都把停用角色重新啟用

### C. Whitelist + Blacklist（DISABLED_ROLES）
- 兩個 list 要維護，語意重複

### D. Whitelist（ENABLED_ROLES）+ Known Set（KNOWN_ROLES）
- `ENABLED_ROLES`：目前啟用的角色 ID
- `KNOWN_ROLES`：曾見過的所有角色 ID（只增不減，除非 removeRoleEntry）
- `initFromScanned()` 只自動啟用 NOT in KNOWN_ROLES 的角色（真正的新角色）
- 停用角色在 KNOWN_ROLES 有記錄 → 不會被重新啟用

---

## 決定

採用 **方案 D**。

---

## 取捨說明

| 面向 | 說明 |
|------|------|
| 新角色行為 | 第一次掃描到自動啟用，符合「預設全啟用」的 UX |
| 停用保留 | 使用者停用角色後重連，仍維持停用 |
| 孤立角色 | prompt 檔案消失但 myai.env 有記錄 → 顯示灰色 + 刪除鍵，不自動清除 |
| Token 位置 | `github_token` 改為選填，SDK Server 優先從 process 環境讀取，App 不需持有 token |

---

## 影響範圍

- `app/providers/enabled_roles_provider.dart`：KNOWN_ROLES + ENABLED_ROLES 雙鍵邏輯
- `app/providers/app_startup_provider.dart`：`enableRole` / `disableRole` / `removeRoleEntry` 方法
- `app/providers/scanned_roles_provider.dart`：新增，供 UI 知道哪些角色有 prompt 檔
- `app/system_status_page.dart`：角色列表加 toggle + orphan badge + 刪除鍵
- `app/demo_page.dart`：主畫面角色卡只顯示 enabled 角色
- `myai.env`：新增 `ENABLED_ROLES`、`KNOWN_ROLES` 兩個 key
