# 260317_002 — 角色物理隔離原則

> 日期：2026-03-17  
> 狀態：已採納  
> 影響範圍：`shared/roles.md`、`app/screens/system_status.md`

---

## 背景

在設計匯入型角色（imported roles）的 `work_dir` 來源時，討論到「App 是否應自管工作目錄」的問題。

現行系統已有一個隱性慣例：每個角色有自己的根目錄（`{projectRoot}/{role_id}/`），其中 `code/` 是 primary repo，其他子目錄是參考用的 clone。但此慣例未被明確記錄，導致規格中出現過複雜的「衍生規則」（嘗試多個路徑、詢問使用者）。

---

## 候選方案

### 方案 A：App 自管目錄（appDataDir）
App 在 `{appDataDir}/workspaces/{role_id}/` 建立目錄，由 App 完全負責生命週期。

**問題**：Agent 工作在空的沙盒目錄，無法操作實際 codebase；不符合 AI coding agent 的使用情境。

### 方案 B：彈性推導 + 使用者確認
App 嘗試 `{projectRoot}/{role_id}/code` → `{projectRoot}/{role_id}` → 空白詢問使用者。

**問題**：邏輯複雜，使用者負擔不一致；且「詢問使用者」暗示 App 不知道正確答案，是設計缺陷的信號。

### 方案 C：物理隔離固定慣例（本次採納）
固定每個角色的目錄結構：
```
{projectRoot}/
└── {role_id}/
    ├── code/       ← primary repo（讀寫）
    └── {ref}/      ← reference clone（唯讀）
```
`work_dir` 永遠是 `{projectRoot}/{role_id}/code`，由 role_id 唯一決定。

---

## 決定

採用方案 C：**物理隔離固定慣例**。

- `work_dir = {projectRoot}/{role_id}/code`，不需要推導，不需要使用者指定
- 各角色各自 clone 所需的 reference repo（不共用），確保環境完全隔離
- 角色模型新增 `repo_url` 欄位，記錄 primary repo 的 git remote URL，供 clone / 重建使用
- 匯入對話框改為要求使用者填寫 `repo_url`；`work_dir` 由 App 直接計算，不再顯示於 UI

---

## 取捨理由

| 考量 | 說明 |
|------|------|
| 確定性 | `work_dir` 由 role_id 唯一決定，App/Server 不需要協商 |
| 權限隔離清晰 | 每個角色的讀寫範圍只在自己的 `code/`，reference 永遠唯讀 |
| 可重建 | `repo_url` 存在角色庫，環境損毀時可重新 clone |
| 儲存成本 | 同一 repo 多份 clone 佔用空間；但換來明確的隔離邊界，可接受 |

---

## 影響範圍

- `shared/roles.md`：新增物理隔離原則 section；`work_dir` 改為固定慣例說明；角色模型加 `repo_url`；移除 work_dir 衍生規則；更新匯入流程
- `app/screens/system_status.md`：匯入對話框改為 `repo_url` 欄位；移除 work_dir 確認步驟
