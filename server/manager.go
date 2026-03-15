package main

import (
	"context"
	"fmt"
	"log"
	"sync"

	copilot "github.com/github/copilot-sdk/go"
)

// Manager manages all active role sessions.
type Manager struct {
	sessions map[string]*roleSession
	mu       sync.RWMutex
	// auth and rootCtx are set on Configure; sessions created afterwards inherit them.
	auth    AuthConfig
	rootCtx context.Context
	hub     *Hub
}

func newManager(ctx context.Context, hub *Hub) *Manager {
	return &Manager{
		sessions: make(map[string]*roleSession),
		rootCtx:  ctx,
		hub:      hub,
	}
}

// Configure stores auth info and starts sessions for new roles.
// Existing sessions are left untouched.
func (m *Manager) Configure(auth AuthConfig, roles []RoleConfig) {
	m.mu.Lock()
	m.auth = auth
	m.mu.Unlock()

	for _, cfg := range roles {
		m.mu.Lock()
		_, exists := m.sessions[cfg.ID]
		m.mu.Unlock()
		if exists {
			continue
		}

		sess, err := newSession(m.rootCtx, cfg, auth, m.hub)
		if err != nil {
			log.Printf("manager: create session %s: %v", cfg.ID, err)
			continue
		}
		m.mu.Lock()
		m.sessions[cfg.ID] = sess
		m.mu.Unlock()
		log.Printf("manager: session %s started", cfg.ID)
	}
}

// GetRoles returns a status snapshot of all sessions.
func (m *Manager) GetRoles() []RoleInfo {
	m.mu.RLock()
	defer m.mu.RUnlock()
	out := make([]RoleInfo, 0, len(m.sessions))
	for _, s := range m.sessions {
		out = append(out, s.Info())
	}
	return out
}

// SendMessage enqueues a user message for the given role.
func (m *Manager) SendMessage(id, text string) error {
	m.mu.RLock()
	s, ok := m.sessions[id]
	m.mu.RUnlock()
	if !ok {
		return fmt.Errorf("role %q not found", id)
	}
	s.Enqueue(text)
	return nil
}

// SendNotify routes an inter-role notification to the target role.
func (m *Manager) SendNotify(id, fromRole, message string) error {
	m.mu.RLock()
	s, ok := m.sessions[id]
	m.mu.RUnlock()
	if !ok {
		return fmt.Errorf("role %q not found", id)
	}
	s.Enqueue(fmt.Sprintf("[NOTIFY from %s] %s", fromRole, message))
	return nil
}

// StopRole stops the given role session and removes it.
func (m *Manager) StopRole(id string) error {
	m.mu.Lock()
	s, ok := m.sessions[id]
	if ok {
		delete(m.sessions, id)
	}
	m.mu.Unlock()
	if !ok {
		return fmt.Errorf("role %q not found", id)
	}
	s.Stop()
	return nil
}

// RespondToPermission delivers the App's answer for a pending user-input request.
func (m *Manager) RespondToPermission(id string, resp PermissionResponseRequest) error {
	m.mu.RLock()
	s, ok := m.sessions[id]
	m.mu.RUnlock()
	if !ok {
		return fmt.Errorf("role %q not found", id)
	}
	if !s.RespondToPermission(resp) {
		return fmt.Errorf("role %q has no pending request %q", id, resp.RequestID)
	}
	return nil
}

// InterruptRole aborts the currently running AI turn for the given role.
func (m *Manager) InterruptRole(id string) error {
	m.mu.RLock()
	s, ok := m.sessions[id]
	m.mu.RUnlock()
	if !ok {
		return fmt.Errorf("role %q not found", id)
	}
	return s.Interrupt()
}

// AuthMode returns the current authentication mode.
func (m *Manager) AuthMode() string {
	m.mu.RLock()
	defer m.mu.RUnlock()
	return m.auth.Mode
}

// ListModels returns available models from the Copilot SDK.
// Uses the first connected session's client; returns an error if none available.
func (m *Manager) ListModels(ctx context.Context) ([]copilot.ModelInfo, error) {
	m.mu.RLock()
	var client *copilot.Client
	for _, s := range m.sessions {
		if s.client != nil {
			client = s.client
			break
		}
	}
	m.mu.RUnlock()

	if client == nil {
		return nil, fmt.Errorf("no active session — call /configure first")
	}
	return client.ListModels(ctx)
}
