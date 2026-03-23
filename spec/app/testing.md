# MyAi — App 測試規格（Maestro）

> 版本：v1.0.0
> 日期：2026-03-13

---

## 測試策略

| 層次 | 工具 | 說明 |
|------|------|------|
| E2E（完整流程）| Maestro YAML Flow | 模擬使用者操作整個畫面流程 |
| Component 整合 | `maestro_test` Dart 套件 | 驗收單一元件的互動行為 |
| 單元測試 | `flutter_test` | 商業邏輯、資料模型、工具函式（不在本文件範圍）|

---

## Maestro 目標平台

**macOS Desktop**（優先）。  
Maestro 透過 macOS Accessibility API 操作桌面 Flutter App，  
所有 Widget 必須有正確的 accessibility label / key。

---

## Widget Testability 要求

### 1. 互動元件必須加 `Key`

所有**可點擊或可輸入**的元件，必須加上 `Key`，讓 Maestro 能穩定定位：

```dart
// 按鈕
ElevatedButton(
  key: const Key('settings_save_button'),
  ...
)

// 文字輸入
TextField(
  key: const Key('byok_api_key_input'),
  ...
)

// 開關
Switch(
  key: const Key('settings_streaming_markdown_switch'),
  ...
)
```

### 2. Key 命名規則

格式：`{screen}_{element}_{type}`

| 區段 | 說明 | 範例 |
|------|------|------|
| `screen` | 所在畫面 | `main`, `settings` |
| `element` | 邏輯語意 | `send_message`, `role_list`, `byok_api_key` |
| `type` | 元件類型 | `button`, `input`, `switch`, `item`, `list` |

**完整範例**：

| 元件 | Key |
|------|-----|
| 角色清單捲動容器 | `main_role_list` |
| 單一角色項目（含 role ID）| `main_role_item_{roleId}` |
| 中央訊息輸入框 | `main_message_input` |
| 發送按鈕 | `main_send_button` |
| 設定按鈕（Directory 欄底部）| `main_open_settings_button` |
| 主題模式選擇 | `settings_theme_mode_selector` |
| Markdown 串流開關 | `settings_streaming_markdown_switch` |
| GitHub Token 輸入框 | `settings_github_token_input` |
| BYOK API Key 輸入框 | `settings_byok_api_key_input` |
| BYOK Base URL 輸入框 | `settings_byok_base_url_input` |
| BYOK Model 輸入框 | `settings_byok_model_input` |
| 儲存設定按鈕 | `settings_save_button` |
| 測試連線按鈕 | `settings_test_connection_button` |

### 3. 圖示按鈕必須加 `Tooltip`

Maestro 在 macOS 透過 `tooltip` 定位 `IconButton`：

```dart
IconButton(
  key: const Key('main_send_button'),
  tooltip: '傳送訊息',
  icon: const Icon(Icons.send),
  onPressed: ...,
)
```

### 4. 狀態顯示元件加 `Semantics`

狀態燈（Agent status indicator）等純視覺元件，  
需要 `Semantics` 讓 Maestro 能驗證狀態：

```dart
Semantics(
  label: 'role-${role.id}-status-${role.status.name}',
  child: StatusDot(status: role.status),
)
```

---

## Maestro YAML E2E Flow

### 目錄結構

```
app/
└── .maestro/
    ├── config.yaml       — 全域設定（appId、timeout）
    ├── main_ide/
    │   ├── open_settings.yaml
    │   ├── send_message.yaml
    │   └── switch_role.yaml
    └── settings/
        ├── change_theme.yaml
        └── save_byok.yaml
```

### `config.yaml`

```yaml
appId: tw.osw.myai
---
```

### Flow 範例：`send_message.yaml`

```yaml
appId: tw.osw.myai
---
- assertVisible:
    id: "main_message_input"
- tapOn:
    id: "main_message_input"
- inputText: "Hello, Copilot!"
- tapOn:
    id: "main_send_button"
- assertVisible: "Hello, Copilot!"
```

### Flow 範例：`change_theme.yaml`

```yaml
appId: tw.osw.myai
---
- tapOn:
    id: "main_open_settings_button"
- assertVisible:
    id: "settings_theme_mode_selector"
- tapOn: "深色"
- tapOn:
    id: "settings_save_button"
```

### ID 對應說明

Maestro YAML 中的 `id:` 對應 Flutter Widget 的 `Key` 值。

---

## Maestro Dart 整合測試（maestro_test）

### 目錄結構

```
app/
└── integration_test/
    └── maestro/
        ├── main_ide_test.dart
        └── settings_test.dart
```

### 基本結構

```dart
import 'package:maestro_test/maestro_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  maestroTest('設定畫面：儲存 BYOK', ($) async {
    await $.pumpWidgetAndSettle(const MyApp());

    await $(const Key('main_open_settings_button')).tap();
    await $(const Key('settings_byok_api_key_input')).enterText('sk-test');
    await $(const Key('settings_save_button')).tap();

    expect($(const Key('settings_byok_api_key_input')), findsOneWidget);
  });
}
```

### 執行指令

```bash
# 執行 Maestro YAML flows
maestro test .maestro/

# 執行特定 flow
maestro test .maestro/main_ide/send_message.yaml

# 執行 Dart 整合測試（需要連接 macOS 裝置）
flutter test integration_test/maestro/ -d macos
```

---

## 必要 Maestro 測試場景

每個畫面完成後，qa 角色依以下場景建立 YAML flow：

### 主畫面（main_ide）

| 場景 | Flow 檔案 |
|------|-----------|
| 切換角色，Monitor 內容更新 | `switch_role.yaml` |
| 輸入訊息並發送 | `send_message.yaml` |
| 點擊設定按鈕，設定 Sheet 出現 | `open_settings.yaml` |

### 設定畫面（settings）

| 場景 | Flow 檔案 |
|------|-----------|
| 切換主題模式並儲存 | `change_theme.yaml` |
| 輸入 GitHub Token 並儲存 | `save_github_token.yaml` |
| 開啟 BYOK、填入 API Key 並儲存 | `save_byok.yaml` |
| 點擊「測試連線」，顯示結果 | `test_connection.yaml` |

---

## 不納入 Maestro 的場景

| 場景 | 原因 |
|------|------|
| AI 串流輸出內容驗證 | 內容不確定，改以 `role.status` 狀態驗證 |
| Mermaid WebView 內容 | WebView 內容 Maestro 無法直接驗證 |
| 全文搜尋結果排序 | 屬單元測試範圍 |
