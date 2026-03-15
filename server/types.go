package main

// AgentStatus is the execution state of an AI role.
// See spec/shared/agent_status.md
type AgentStatus string

const (
	StatusIdle    AgentStatus = "idle"
	StatusRunning AgentStatus = "running"
	StatusWaiting AgentStatus = "waiting"
	StatusDone    AgentStatus = "done"
	StatusError   AgentStatus = "error"
)

// ProviderConfig carries BYOK provider settings.
type ProviderConfig struct {
	Type    string `json:"type"`     // "openai" | "azure" | "anthropic"
	BaseURL string `json:"base_url"`
	APIKey  string `json:"api_key"`
}

// AuthConfig is the authentication configuration from POST /configure.
type AuthConfig struct {
	Mode        string          `json:"mode"`                  // "copilot" | "byok"
	GitHubToken string          `json:"github_token,omitempty"`
	Provider    *ProviderConfig `json:"provider,omitempty"`
	Model       string          `json:"model,omitempty"` // default model for BYOK
}

// RoleConfig describes a single AI role.
type RoleConfig struct {
	ID         string `json:"id"`
	PromptPath string `json:"prompt_path"`
	WorkDir    string `json:"work_dir"`
	Model      string `json:"model"`
}

// ConfigureRequest is the body for POST /configure.
type ConfigureRequest struct {
	Auth  AuthConfig   `json:"auth"`
	Roles []RoleConfig `json:"roles"`
}

// RoleInfo is a role's current status snapshot returned by GET /roles.
type RoleInfo struct {
	ID     string      `json:"id"`
	Status AgentStatus `json:"status"`
}

// MessageRequest is the body for POST /roles/{id}/message.
type MessageRequest struct {
	Text string `json:"text"`
}

// NotifyRequest is the body for POST /roles/{id}/notify.
type NotifyRequest struct {
	FromRole string `json:"from_role"`
	Message  string `json:"message"`
}

// PermissionResponseRequest is the body for POST /roles/{id}/permission_response.
type PermissionResponseRequest struct {
	RequestID string `json:"request_id"`
	Allowed   bool   `json:"allowed"`
	Answer    string `json:"answer,omitempty"` // freeform text if allowed and choices is empty
}

// WSEvent is a WebSocket event pushed to the Flutter App.
// See spec/server/overview.md — WebSocket event types.
type WSEvent struct {
	Type    string      `json:"type"`
	RoleID  string      `json:"role_id"`
	Payload interface{} `json:"payload"`
}
