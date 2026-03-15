package main

import (
	"context"
	"log"
	"net/http"
)

const listenAddr = "localhost:7788"

func main() {
	ctx := context.Background()

	hub := newHub()
	go hub.run()

	mgr := newManager(ctx, hub)
	mux := newServeMux(mgr, hub)

	log.Printf("server: listening on %s", listenAddr)
	if err := http.ListenAndServe(listenAddr, mux); err != nil {
		log.Fatalf("server: %v", err)
	}
}
