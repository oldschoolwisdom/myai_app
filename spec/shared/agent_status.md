# MyAi — 角色執行狀態

> 版本：v1.4.0
> 日期：2026-03-16
> 修訂：2026-03-13（新增 waiting 狀態，見 decisions/260313_007_WaitingStateDesign.md）
> 修訂：2026-03-15（新增 offline 狀態，Request #11）
> 修訂：2026-03-16（角色來源改為內建角色 + 本地掃描角色，dispatcher 為 mandatory built-in role，Request #24）
> 修訂：2026-03-16（waiting 狀態下的 PermissionCard 回應語意泛化為「提交回答 / 拒絕 request」，Request #23）

---

## 概覽

MyAi 中每個 AI 角色（Agent）在任何時刻都處於一個確定的**執行狀態（Agent Status）**。狀態由 Local OSW-MyAI-Agent 維護並即時推播至 App。

App 啟動時，角色由 **內建角色** 與 **本地掃描角色（`ai/prompts/ltc-*.md`）** 組成後，以 `offline` 狀態預填；連線後由 WS 事件或 `GET /roles` 覆蓋成實際狀態。

---

## 狀態定義

| 狀態值 | 名稱 | 含義 |
|--------|------|------|
| `offline` | 未連線 | 角色已知（內建或本地掃描），但尚未與 OSW-MyAI-Agent 建立連線 |
| `idle` | 閒置 | 角色待機中，無正在執行的任務 |
| `running` | 執行中 | 角色正在處理任務（執行指令、等待 AI 回應等）|
| `waiting` | 等待確認 | 角色執行中途需要使用者輸入（如 SDK 確認請求、選項回覆、目錄存取授權等），無法繼續直到使用者回應 |
| `done` | 完成 | 角色最近一次任務已完成 |
| `error` | 錯誤 | 角色最近一次任務失敗，或連線中斷 |

---

## 狀態燈視覺規則

App 使用 `StatusIndicator` 元件顯示狀態燈，顯示規則如下：

| 狀態 | 顏色 | 動畫 |
|------|------|------|
| `offline` | 灰色 | 無 |
| `idle` | 綠色 | 無 |
| `running` | 藍色 | Pulse 動畫（持續閃爍，800ms）|
| `waiting` | 橘色（#F97316）| 快速 Pulse（400ms，含光暈）|
| `done` | 綠色 | 無 |
| `error` | 紅色 | 無 |

> `StatusIndicator.disconnected`（灰）= offline/standby；`StatusIndicator.error`（紅）= error

---

## 狀態觸發規則

| 觸發事件 | 目標狀態 |
|----------|----------|
| App 啟動，載入內建角色 + 掃描本地角色 | `offline` |
| WS 連線建立，server 回傳角色資訊 | `idle`（或 server 實際狀態）|
| 開始執行任務（收到指令）| `running` |
| SDK/CLI 發出需要使用者回應的提示 | `waiting` |
| 使用者提交回答後（選擇某個 choice，或 legacy binary request 點「允許」） | `running` |
| 使用者拒絕 / 取消此次 request 後（App-level rejection） | `running` 或 `error` |
| 任務執行完成 | `done` |
| 任務執行失敗 / 例外 / 連線中斷 | `error` |
| 角色重新連線成功 | `idle` |

---

## 使用位置

- **左側 Sidebar**：每個角色項目的 Avatar 右下角
- **中央 Monitor TopBar**：當前選中角色的即時狀態
- **系統狀態頁**：角色狀態清單（`spec/code/app/screens/system_status.md`）

---

## 相關規格

- `spec/app/screens/main_ide.md` — 主畫面使用方式
- `spec/app/screens/system_status.md` — 系統狀態頁
- `spec/app/design_system.md` — `StatusIndicator` 元件說明
- `spec/shared/roles.md` — 角色來源與內建角色定義
