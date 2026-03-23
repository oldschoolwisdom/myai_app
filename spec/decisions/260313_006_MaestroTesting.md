# 260313_006 — Maestro 自動化測試策略

## 背景

使用者要求 Flutter App 在製作時符合 Maestro 自動化測試規範。  
本決策確立測試工具組合、目標平台、Widget testability 要求及測試場景範圍。

---

## 候選方案

| 方案 | 說明 | 取捨 |
|------|------|------|
| A. Maestro YAML + maestro_test Dart | YAML 做 E2E、Dart 做 component 整合測試 | 覆蓋最完整；需要 Widget Key 命名規範 |
| B. 僅 Maestro YAML | 外部 YAML flow，不寫 Dart 測試 | 門檻低；較難驗收細節行為 |
| C. 僅 flutter_test 整合測試 | 不引入 Maestro | 不符合需求 |

---

## 決定

**採用方案 A**：Maestro YAML（E2E）+ `maestro_test` Dart（component 整合）。

---

## 取捨理由

1. YAML Flow 適合描述使用者操作流程（End-to-End），是 QA 驗收的主要工具
2. `maestro_test` Dart 套件適合 component-level 整合驗證，可在 flutter test runner 中執行
3. macOS Desktop 是 Maestro 桌面平台中支援最穩定的目標

---

## 目標平台

**macOS Desktop**（優先）。  
Maestro 透過 macOS Accessibility API 識別並操作桌面 Flutter widgets。

---

## 核心約束

### Widget Key 命名規則（強制）

格式：`{screen}_{element}_{type}`

- 所有可點擊、可輸入、可開關的元件**必須**設定 `Key`
- `IconButton` 必須設定 `tooltip`
- 狀態顯示元件用 `Semantics(label: ...)` 表達語意狀態

### ID 與 Maestro YAML 對應

Maestro YAML 中 `id: "xxx"` 直接對應 Flutter `Key('xxx')`。

---

## 影響範圍

- `spec/app/testing.md`（新建）— 完整 testability 規範、Key 命名表、YAML/Dart 結構
- `spec/app/tech_stack.md` — 加入 `maestro_test` dev dependency
- app 角色 — 實作 Widget Key 規範
- qa 角色 — 撰寫 YAML flows 與 Dart 整合測試
