# MyAi — 規格總覽

> 本目錄為 MyAi 專案的唯一規格主體，由 spec 角色維護。

## 目錄結構

| 目錄 | 說明 |
|------|------|
| `shared/` | 跨端共用規則（名詞、流程、權限、狀態、產品行為） |
| `data/` | 共用資料契約（canonical domain model、DDL、constraints、indexes、RLS） |
| `server/` | Server 規格（API、服務架構、部署需求） |
| `app/` | App 規格（頁面、流程、互動、資料需求） |
| `decisions/` | 決策紀錄 |

## 平台

- **App**：Flutter（iOS / Android / Web）
- **Server**：待定
- **Web**：目前無 web AI 角色，暫不主動發 web [Task]

## 重要決策

見 [decisions/README.md](decisions/README.md)
