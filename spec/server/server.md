# MyAi — Local OSW-MyAI-Agent 執行時規格

> 版本：v1.0.0
> 日期：2026-03-16
> 來源：Request #17（server 角色逆向正規化：HTTP logging、panic recovery、log file flag）
> 相關文件：[overview.md](overview.md)、[api.md](api.md)

---

## 概覽

本文件描述 OSW-MyAI-Agent **binary 的執行時行為**，包含啟動旗標、Logging 規格、可觀測性機制。  
架構與 API 規格分別見 [overview.md](overview.md) 與 [api.md](api.md)。

---

## 啟動旗標（Startup Flags）

| 旗標 | 型別 | 預設值 | 說明 |
|------|------|--------|------|
| `-log <path>` | string | `""` | Log 輸出的檔案路徑；空字串表示僅輸出至 stdout，不寫入檔案 |

**範例：**

```bash
# 僅輸出至 stdout（預設行為）
./osw-myai-agent

# 同時寫入 stdout 與 server.log
./osw-myai-agent -log server.log

# 使用 Makefile shortcut
make run-log
```

> 指定 `-log` 時，Server 以 `O_APPEND` 模式開啟檔案，**重啟不覆蓋**，持續追加。  
> 使用 `io.MultiWriter` 同時寫 stdout 與檔案，兩側輸出內容相同。

---

## Logging

### Log 格式

所有 log 使用 Go 標準 `log` 套件輸出，格式為：

```
2026/03/16 07:44:08 <source_file>:<line> <message>
```

範例：
```
2026/03/16 07:44:08 middleware.go:26 http: POST /roles/spec/message → 202 (1ms)
2026/03/16 07:44:08 server.go:45 osw-myai-agent started on :7788
```

> `log.SetFlags` 設定為包含日期、時間、檔案名稱與行號（`log.Ldate | log.Ltime | log.Lshortfile`）。

---

### HTTP Access Log

每個 HTTP request 完成後，middleware 自動輸出一行 access log：

**格式：**
```
http: {METHOD} {PATH} → {STATUS} ({LATENCY})
```

**範例：**
```
2026/03/16 07:44:08 middleware.go:26 http: POST /roles/spec/message → 202 (1ms)
2026/03/16 07:44:09 middleware.go:26 http: GET /roles → 200 (0ms)
2026/03/16 07:44:10 middleware.go:26 http: DELETE /roles/spec → 200 (3ms)
```

| 欄位 | 說明 |
|------|------|
| `METHOD` | HTTP 動詞（GET / POST / DELETE 等）|
| `PATH` | 請求路徑（含路徑參數，例如 `/roles/spec/message`）|
| `STATUS` | HTTP 回應狀態碼 |
| `LATENCY` | 處理時間，單位 ms（從 request 進入到 response 寫出）|

> WebSocket upgrade 請求（`GET /ws`）同樣會記錄一筆（狀態碼 `101`）。

---

## Panic Recovery

Server 內建 panic recovery middleware，確保任何 handler 發生 panic 時 **Server process 不會 crash**。

**行為：**

1. 攔截 handler panic
2. 印出 panic 訊息 + 完整 goroutine stack trace
3. 回傳 `500 Internal Server Error` 給呼叫方
4. Server 繼續運作，接受後續請求

**Log 輸出格式：**

```
2026/03/16 07:50:00 middleware.go:40 http: PANIC GET /roles/xxx: runtime error: index out of range [0] with length 0
goroutine 42 [running]:
runtime/debug.Stack()
    /usr/local/go/src/runtime/debug/stack.go:24 +0x5b
...
```

> Panic recovery middleware 的存在**不代表允許忽略錯誤**，只是防止單次 handler 異常導致整個 server 崩潰。  
> Server 角色應追蹤 `PANIC` 關鍵字 log，作為需要修復的 bug 訊號。

---

## 可觀測性小結

| 機制 | 觸發時機 | 輸出目標 |
|------|---------|---------|
| HTTP Access Log | 每個 HTTP request 完成後 | stdout / log file |
| Startup Log | server 啟動時 | stdout / log file |
| Panic Recovery | handler panic 時 | stdout / log file（含 stack trace）|
| WebSocket 事件推播 | 角色狀態/輸出變更時 | WebSocket client（不進 log file）|

> App 端可透過 `spec/app/screens/system_status.md` 的「診斷日誌」section 查看 Server log 輸出（實作方式 TBD）。
