package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"sync"

	"github.com/google/uuid"
	copilot "github.com/github/copilot-sdk/go"
)

// roleSession holds state for a single AI role backed by the Copilot SDK.
type roleSession struct {
	config  RoleConfig
	client  *copilot.Client
	session *copilot.Session
	status  AgentStatus

	// pendingRequests maps request_id → response channel for blocking OnUserInputRequest calls.
	pendingRequests   map[string]chan PermissionResponseRequest
	pendingRequestsMu sync.Mutex

	// inbound queues messages/notifications for sequential processing.
	inbound chan string
	cancel  context.CancelFunc

	hub *Hub
}

// newSession creates a Copilot SDK client + session for the given role and starts
// its background processing loop.
func newSession(ctx context.Context, cfg RoleConfig, auth AuthConfig, hub *Hub) (*roleSession, error) {
	prompt, err := os.ReadFile(cfg.PromptPath)
	if err != nil {
		return nil, fmt.Errorf("read prompt %s: %w", cfg.PromptPath, err)
	}

	clientOpts := &copilot.ClientOptions{
		Cwd:      cfg.WorkDir,
		LogLevel: "error",
	}
	if auth.Mode == "copilot" && auth.GitHubToken != "" {
		clientOpts.GitHubToken = auth.GitHubToken
	}

	client := copilot.NewClient(clientOpts)
	if err := client.Start(ctx); err != nil {
		return nil, fmt.Errorf("start client for role %s: %w", cfg.ID, err)
	}

	// Build provider config for BYOK mode.
	var provider *copilot.ProviderConfig
	if auth.Mode == "byok" && auth.Provider != nil {
		provider = &copilot.ProviderConfig{
			Type:    auth.Provider.Type,
			BaseURL: auth.Provider.BaseURL,
			APIKey:  auth.Provider.APIKey,
		}
	}

	// Create session — OnUserInputRequest wires permission blocking via the Hub.
	// We need a reference to rs before CreateSession, so we build the handler lazily.
	var rs *roleSession

	sess, err := client.CreateSession(ctx, &copilot.SessionConfig{
		Model:            cfg.Model,
		WorkingDirectory: cfg.WorkDir,
		Streaming:        true,
		Provider:         provider,
		SystemMessage: &copilot.SystemMessageConfig{
			Mode:    "replace",
			Content: string(prompt),
		},
		// Allow all tool-use operations — sandbox enforced by SDK WorkingDirectory.
		OnPermissionRequest: copilot.PermissionHandler.ApproveAll,
		// Block on user-input requests until the App responds via permission_response.
		OnUserInputRequest: func(req copilot.UserInputRequest, inv copilot.UserInputInvocation) (copilot.UserInputResponse, error) {
			return rs.handleUserInput(req, inv)
		},
	})
	if err != nil {
		client.Stop()
		return nil, fmt.Errorf("create session for role %s: %w", cfg.ID, err)
	}

	loopCtx, cancel := context.WithCancel(ctx)
	rs = &roleSession{
		config:          cfg,
		client:          client,
		session:         sess,
		status:          StatusIdle,
		pendingRequests: make(map[string]chan PermissionResponseRequest),
		inbound:         make(chan string, 32),
		cancel:          cancel,
		hub:             hub,
	}

	// Broadcast initial idle status.
	hub.Broadcast(WSEvent{
		Type:    "role.status",
		RoleID:  cfg.ID,
		Payload: map[string]string{"status": string(StatusIdle)},
	})

	go rs.loop(loopCtx, hub)
	return rs, nil
}

// loop waits for inbound messages and processes them one at a time.
func (rs *roleSession) loop(ctx context.Context, hub *Hub) {
	for {
		select {
		case <-ctx.Done():
			return
		case text := <-rs.inbound:
			rs.setStatus(StatusRunning, hub)

			done := make(chan struct{})

			// Subscribe to SDK events for this send.
			unsub := rs.session.On(func(event copilot.SessionEvent) {
				switch event.Type {
				case copilot.AssistantMessageDelta:
					if event.Data.DeltaContent != nil {
						hub.Broadcast(WSEvent{
							Type:    "role.output",
							RoleID:  rs.config.ID,
							Payload: map[string]string{"chunk": *event.Data.DeltaContent},
						})
					}

				case copilot.ToolExecutionStart:
					payload := map[string]any{"tool": ""}
					if event.Data.ToolName != nil {
						payload["tool"] = *event.Data.ToolName
					}
					if event.Data.Arguments != nil {
						payload["arguments"] = event.Data.Arguments
					}
					hub.Broadcast(WSEvent{
						Type:    "role.tool_call",
						RoleID:  rs.config.ID,
						Payload: payload,
					})

				case copilot.SessionIdle:
					select {
					case <-done:
					default:
						close(done)
					}
				}
			})

			_, err := rs.session.Send(ctx, copilot.MessageOptions{
				Prompt: text,
			})

			// Wait for session.idle before processing the next message.
			select {
			case <-done:
			case <-ctx.Done():
				unsub()
				return
			}
			unsub()

			if err != nil {
				log.Printf("session %s: send error: %v", rs.config.ID, err)
				hub.Broadcast(WSEvent{
					Type:    "role.error",
					RoleID:  rs.config.ID,
					Payload: map[string]string{"message": err.Error()},
				})
				rs.setStatus(StatusError, hub)
			} else {
				rs.setStatus(StatusDone, hub)
			}

			hub.Broadcast(WSEvent{Type: "role.output_end", RoleID: rs.config.ID, Payload: map[string]any{}})
		}
	}
}

// Enqueue adds a message or notification to the session's inbound queue.
func (rs *roleSession) Enqueue(text string) {
	select {
	case rs.inbound <- text:
	default:
		log.Printf("session %s: inbound queue full, dropping message", rs.config.ID)
	}
}

// Interrupt aborts the currently running AI turn without stopping the session.
// The session remains active and can accept new messages.
func (rs *roleSession) Interrupt() error {
	return rs.session.Abort(context.Background())
}

// Stop shuts down the session and the underlying SDK client.
func (rs *roleSession) Stop() {
	rs.cancel()
	rs.session.Disconnect()
	rs.client.Stop()
}

// Info returns the current status snapshot.
func (rs *roleSession) Info() RoleInfo {
	return RoleInfo{ID: rs.config.ID, Status: rs.status}
}

func (rs *roleSession) setStatus(st AgentStatus, hub *Hub) {
	rs.status = st
	hub.Broadcast(WSEvent{
		Type:    "role.status",
		RoleID:  rs.config.ID,
		Payload: map[string]string{"status": string(st)},
	})
}

// handleUserInput is called by the SDK when the agent uses the ask_user tool.
// It blocks until the App replies via POST /roles/{id}/permission_response.
func (rs *roleSession) handleUserInput(req copilot.UserInputRequest, _ copilot.UserInputInvocation) (copilot.UserInputResponse, error) {
	requestID := uuid.NewString()

	ch := make(chan PermissionResponseRequest, 1)
	rs.pendingRequestsMu.Lock()
	rs.pendingRequests[requestID] = ch
	rs.pendingRequestsMu.Unlock()

	// Switch to waiting and broadcast the permission request to the App.
	rs.setStatus(StatusWaiting, rs.hub)
	rs.hub.Broadcast(WSEvent{
		Type:   "role.permission_request",
		RoleID: rs.config.ID,
		Payload: map[string]any{
			"request_id": requestID,
			"question":   req.Question,
			"choices":    req.Choices,
		},
	})

	// Block until App responds (or context is done).
	resp := <-ch

	rs.pendingRequestsMu.Lock()
	delete(rs.pendingRequests, requestID)
	rs.pendingRequestsMu.Unlock()

	// Resume running state.
	rs.setStatus(StatusRunning, rs.hub)

	if !resp.Allowed {
		return copilot.UserInputResponse{}, fmt.Errorf("user denied permission request %s", requestID)
	}
	return copilot.UserInputResponse{Answer: resp.Answer}, nil
}

// RespondToPermission delivers the App's response to a pending user-input request.
// Returns false if request_id is not found.
func (rs *roleSession) RespondToPermission(resp PermissionResponseRequest) bool {
	rs.pendingRequestsMu.Lock()
	ch, ok := rs.pendingRequests[resp.RequestID]
	rs.pendingRequestsMu.Unlock()
	if !ok {
		return false
	}
	ch <- resp
	return true
}
