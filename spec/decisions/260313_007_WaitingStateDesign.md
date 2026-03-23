# 260313_007 — waiting 狀態設計與 PermissionCard 互動模式

## 背景

app 角色在實作過程中發現，SDK（`github/copilot-sdk/go`）的 `OnUserInputRequest`  
機制會在 AI 執行中途發出需要使用者同意的請求（如目錄存取授權、工具執行確認等）。  
目前規格未定義此狀態，需要補充：

1. `agent_status` 的第五種狀態 `waiting`
2. 角色卡片在 `waiting` 狀態下的視覺提示
3. 使用者回應介面的設計模式（同意卡片）

---

## 候選方案

### PermissionCard 互動模式

| 方案 | 說明 | 取捨 |
|------|------|------|
| A. **inline PermissionCard**（嵌入對話流）| 卡片出現在對話列表底部，與 AI 訊息並列 | 不打斷操作流；回應記錄保存於對話歷史；符合對話 UI 的一致性 |
| B. Modal Dialog | 全螢幕遮罩彈窗 | 強制優先處理，但打斷使用者當前操作；歷史不留存 |
| C. 系統通知 | 桌面 OS 通知彈出 | 對 macOS 桌面有一致性；但需要額外權限，且無法嵌入對話紀錄 |

### waiting 狀態顏色

| 方案 | 顏色 | 取捨 |
|------|------|------|
| 橘色（#F97316） | 中等緊迫感 | 比 running 藍色更顯眼、比 error 紅色不嚴重；orange 是 UI 中「需注意」的通用語義 |
| 黃色 | 低緊迫感 | 與部分 UI 的 warning 語義重疊，辨識度較低 |
| 紅色閃爍 | 高緊迫感 | 與 error 狀態混淆 |

---

## 決定

1. **PermissionCard 採 inline 模式（方案 A）**
2. **waiting 狀態燈顏色：橘色（#F97316），快速 Pulse（400ms，含光暈）**
3. **waiting 不計為 error** — 使用者拒絕後由 CLI/SDK 端決定是否轉為 `error`

---

## 取捨理由

- inline 卡片不打斷使用者當前操作（可繼續閱讀其他角色的訊息）
- 回應記錄嵌入對話，可回顧授權歷史，也方便 QA 驗收（`assertVisible` 已回應狀態）
- 快速 Pulse（400ms）比 running（800ms）更快，傳達「需要你注意」的緊迫感，但橘色比紅色溫和

---

## 影響範圍

- `spec/shared/agent_status.md` v1.1.0 — 新增 waiting 狀態、視覺規則、觸發規則
- `spec/app/screens/main_ide.md` v1.1.0 — 角色卡片 waiting 樣式、PermissionCard 規格
- server 角色 — 需在 `role.status` WebSocket 事件支援 `waiting` 值
- app 角色 — 實作 waiting 卡片樣式、PermissionCard 元件
- `spec/app/testing.md` — 未來需補充 waiting/PermissionCard 的 Maestro 測試場景
