package main

import (
	"encoding/json"
	"net/http"
)

func newServeMux(mgr *Manager, hub *Hub) *http.ServeMux {
	mux := http.NewServeMux()
	mux.HandleFunc("POST /configure", handleConfigure(mgr))
	mux.HandleFunc("GET /roles", handleGetRoles(mgr))
	mux.HandleFunc("POST /roles/{id}/message", handleMessage(mgr))
	mux.HandleFunc("POST /roles/{id}/notify", handleNotify(mgr))
	mux.HandleFunc("POST /roles/{id}/permission_response", handlePermissionResponse(mgr))
	mux.HandleFunc("POST /roles/{id}/interrupt", handleInterrupt(mgr))
	mux.HandleFunc("DELETE /roles/{id}", handleDeleteRole(mgr))
	mux.HandleFunc("GET /auth/status", handleAuthStatus(mgr))
	mux.HandleFunc("GET /models", handleListModels(mgr))
	mux.HandleFunc("GET /ws", hub.ServeWS)
	return mux
}

func handleConfigure(mgr *Manager) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var req ConfigureRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}
		mgr.Configure(req.Auth, req.Roles)
		w.WriteHeader(http.StatusOK)
	}
}

func handleGetRoles(mgr *Manager) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]any{"roles": mgr.GetRoles()})
	}
}

func handleMessage(mgr *Manager) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		id := r.PathValue("id")
		var req MessageRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}
		if err := mgr.SendMessage(id, req.Text); err != nil {
			http.Error(w, err.Error(), http.StatusNotFound)
			return
		}
		w.WriteHeader(http.StatusAccepted)
	}
}

func handleNotify(mgr *Manager) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		id := r.PathValue("id")
		var req NotifyRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}
		if err := mgr.SendNotify(id, req.FromRole, req.Message); err != nil {
			http.Error(w, err.Error(), http.StatusNotFound)
			return
		}
		w.WriteHeader(http.StatusAccepted)
	}
}

func handleDeleteRole(mgr *Manager) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		id := r.PathValue("id")
		if err := mgr.StopRole(id); err != nil {
			http.Error(w, err.Error(), http.StatusNotFound)
			return
		}
		w.WriteHeader(http.StatusOK)
	}
}

// handlePermissionResponse delivers the App's answer to a pending OnUserInputRequest.
func handlePermissionResponse(mgr *Manager) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		id := r.PathValue("id")
		var req PermissionResponseRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}
		if err := mgr.RespondToPermission(id, req); err != nil {
			http.Error(w, err.Error(), http.StatusNotFound)
			return
		}
		w.WriteHeader(http.StatusOK)
	}
}

func handleInterrupt(mgr *Manager) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		id := r.PathValue("id")
		if err := mgr.InterruptRole(id); err != nil {
			http.Error(w, err.Error(), http.StatusNotFound)
			return
		}
		w.WriteHeader(http.StatusOK)
	}
}

// handleAuthStatus reports whether the server has been configured with credentials.
func handleAuthStatus(mgr *Manager) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		mode := mgr.AuthMode()
		authenticated := mode != ""
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]any{
			"authenticated": authenticated,
			"mode":          mode,
		})
	}
}

// handleListModels returns available models from the Copilot SDK.
func handleListModels(mgr *Manager) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		models, err := mgr.ListModels(r.Context())
		if err != nil {
			http.Error(w, err.Error(), http.StatusServiceUnavailable)
			return
		}
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(models)
	}
}
