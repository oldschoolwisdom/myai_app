# 260316_002 — role.error 錯誤分類：客戶端 vs 伺服器端

> 日期：2026-03-16
> 發起：osw-myai-app（Request #15）
> 狀態：已採用（Phase 1 客戶端分類）

---

## 問題背景

SDK 送出的 `role.error` 事件只有 `payload.message` 字串，但不同類型的錯誤需要給使用者不同的引導：

- **quota / billing**：帳單問題，需要使用者去外部處理
- **rate_limit**：頻率限制，稍後可重試
- **connection**：連線問題，可嘗試重連
- **general**：其他未知錯誤

---

## 分類方式選項

### 選項 A：Server 端補 `error_type` 欄位

Server 解析 SDK 原始 error 物件，填入結構化 `error_type` 欄位後送出。

**優點**：App 端邏輯簡單、分類準確（直接拿 SDK error code）  
**缺點**：需要 Server 端修改；不同 SDK 版本的 error 結構可能不同；目前實作成本較高

### 選項 B：App 端關鍵字比對（Phase 1，已採用）

App 依 `payload.message` 字串做關鍵字比對，分類為 4 種類型。

**優點**：不需修改 Server；立即可用  
**缺點**：關鍵字 heuristic 有誤判風險；SDK 訊息格式改變時需同步更新關鍵字清單

---

## 採用決策

**Phase 1 採用選項 B（App 客戶端關鍵字分類）**，主要理由：

1. Server 端目前無 error 結構化資訊，補欄位需要調查 SDK error type 體系
2. 常見錯誤訊息（quota、rate limit）在 LLM API 業界有明確的關鍵字模式，誤判率低
3. 可立即上線，使用者得到比「原始 SDK 訊息」更友善的引導

**未來優化（Phase 2，TBD）**：評估 Server 端加入 `error_type` 欄位，讓 App 直接消費結構化分類，移除關鍵字 heuristic。

---

## 分類規則

| 類型 | 關鍵字（case-insensitive） |
|------|--------------------------|
| `quota` | `credit`、`billing`、`quota`、`usage limit` |
| `rate_limit` | `rate limit`、`429`、`overloaded`、`too many requests` |
| `connection` | `connection`、`session`、`disconnected`、`timeout` |
| `general` | 以上皆不符 |

---

## UI 設計決策

| 類型 | 顯示文字 | 附加操作 |
|------|---------|---------|
| `quota` | 「AI 額度不足或帳單有問題，請檢查您的帳號設定。」| 無（外部問題）|
| `rate_limit` | 「請求頻率過高，請稍後再試。」| 無（等待後手動重試）|
| `connection` | 「連線中斷或 Session 遺失，請重新連線。」| 無（TopBar 已有連線入口）|
| `general` | SDK 原始 `message` 文字 | 無 |

**不加「重試」按鈕**的理由：LLM 請求的重試時機需使用者判斷（rate_limit 需等多久、quota 需補充後才能用），自動重試容易造成反覆失敗；使用者主動輸入新訊息即構成重試。

---

## 相關規格

- `spec/app/screens/main_ide.md` — 錯誤氣泡顯示規格
- `spec/server/api.md` — `role.error` 事件，未來 `error_type` 欄位說明
