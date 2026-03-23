# 260315_002 — myai.env：啟動設定持久化策略

> 日期：2026-03-15
> 狀態：已決定
> 相關 Issue：Request #11

---

## 背景

App 需要儲存「啟動時是否自動執行 SDK Server」與「啟動時是否自動連線」兩個偏好旗標。  
這些旗標在 App 啟動序列的最早期就需要讀取，因此需要一個輕量、可靠的儲存位置。

同時，原本的 `.env`（project root）需要一個更明確的名稱，以區別 `ai/.env`（bash scripts 用的 env）。

---

## 候選方案

### A. 使用平台 Key-Value Store（SharedPreferences / Hive）

- ✅ 對 Flutter 友好
- ❌ 與 `myai.env` 中的其他旗標（如 FORGEJO_TOKEN、AI_SERVER_BINARY）分散在兩處
- ❌ 不易用文字編輯器手動修改
- ❌ 打包後路徑不固定，難以在 terminal 直接查看或修改

### B. 整合到 myai.env（選定）

- ✅ 所有 App 層設定集中一處
- ✅ 可用文字編輯器直接修改，便於開發階段手動調整
- ✅ 已有 EnvService 負責讀取，擴充 set() + persist() 成本低
- ✅ 注釋、排版可保留（不破壞人工維護的 env 檔）
- ❌ 寫回時需小心保留原始排版（已實作）
- ❌ 若 App 打包成獨立 .app，路徑解析需用 Platform.executable walk-up 策略（已有備援）

### C. 新增獨立 app.prefs.json

- ✅ 結構清晰
- ❌ 又一個檔案；開發者在 project root 需認識兩種設定格式

---

## 決定：方案 B

將 `AUTO_START_SERVER` 與 `AUTO_CONNECT` 寫入 `myai.env`。  
EnvService 擴充 `set(key, value)` 與 `_persist()` 方法：

- 讀取既有檔案內容
- 找到對應 key 的行 → in-place 替換
- 找不到 → 在檔案末尾 append
- 保留所有空行與 `#` 開頭的注釋行

---

## .env → myai.env 更名

原 project root 的 `.env` 更名為 `myai.env`：

- 區別 `ai/.env`（bash scripts 使用的環境變數，未更名）
- 名稱更具辨識度，不會被誤解為通用 `.env`
- `ai/scripts/ltc-*.sh` 不受影響（它們 source `$AI_DIR/.env`，不是 project root 的 env）

---

## 影響範圍

- `EnvService._defaultEnvPath()` → 回傳 `myai.env`
- `EnvService.set()` + `_persist()` 新增
- `StartupPrefsProvider.setAutoStartServer()` / `setAutoConnect()` → 呼叫 `envProvider.set()` 寫回
- `app_startup_provider.dart` 步驟 1 讀取 myai.env
- 系統狀態頁 toggle 操作即時寫回（使用者視覺即時，持久化非同步）
