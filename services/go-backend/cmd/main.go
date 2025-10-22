package main

import (
	"context"
	"fmt"
	"log"
	"math/rand"
	"net"
	"net/http"
	"os"
	"os/signal"
	"sync/atomic"
	"syscall"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

const (
	_shutdownPeriod      = 15 * time.Second // must be <= pod terminationGracePeriodSeconds
	_shutdownHardPeriod  = 3 * time.Second  // final grace after Shutdown timeout
	_readinessDrainDelay = 5 * time.Second  // let readiness change propagate
)

var isShuttingDown atomic.Bool

func main() {
	// --- Config
	port := getenv("PORT", "8080")
	dsn := os.Getenv("DATABASE_URL")
	if dsn == "" {
		log.Fatal("DATABASE_URL must be set")
	}
	log.SetFlags(log.LstdFlags | log.Lshortfile)

	// --- Signal root context
	rootCtx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	// --- DB pool
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	dbpool, err := pgxpool.New(ctx, dsn)
	if err != nil {
		log.Fatalf("Unable to create connection pool: %v", err)
	}
	if err := dbpool.Ping(ctx); err != nil {
		log.Fatalf("Unable to ping database: %v", err)
	}
	log.Println("Connected to database")

	// --- Handlers
	mux := http.NewServeMux()

	// Liveness (process up). Keep it lightweight and always 200 unless you add self-checks.
	mux.HandleFunc("/livez", func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte("OK\n"))
	})

	// Readiness (traffic gate)
	mux.HandleFunc("/healthz", func(w http.ResponseWriter, _ *http.Request) {
		if isShuttingDown.Load() {
			http.Error(w, "Shutting down", http.StatusServiceUnavailable)
			return
		}
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte("OK\n"))
	})

	// Main route
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		log.Println("Request received!")

		// Simulate slow processing (e.g. DB latency, complex work)
		sleep := time.Duration(rand.Intn(2)) * time.Second
		log.Printf("Simulating %v work...", sleep)
		select {
		case <-time.After(sleep):
			// Proceed normally after sleep
		case <-r.Context().Done():
			log.Println("Request cancelled before sleep finished")
			http.Error(w, "Request cancelled.", http.StatusRequestTimeout)
			return
		}

		var random float64
		if err := dbpool.QueryRow(r.Context(), "SELECT random() AS random").Scan(&random); err != nil {
			http.Error(w, "database query failed", http.StatusInternalServerError)
			log.Printf("ERROR: query failed: %v\n", err)
			return
		}

		_, _ = fmt.Fprintf(w, "Sleep Duration: %v, Random number: %.6f\n", sleep, random)
		log.Printf("Served / in %v\n", time.Since(start))
	})

	// --- Keep in-flight requests alive across SIGTERM using BaseContext
	ongoingCtx, stopOngoingGracefully := context.WithCancel(context.Background())
	server := &http.Server{
		Addr: ":" + port,
		// Requests inherit this context instead of being tied to rootCtx,
		// so they aren't cancelled immediately on SIGTERM.
		BaseContext: func(_ net.Listener) context.Context { return ongoingCtx },
		Handler:           mux,
		ReadHeaderTimeout: 10 * time.Second,
		IdleTimeout:       120 * time.Second,
	}

	// Close DB pool after server.Shutdown completes
	server.RegisterOnShutdown(func() {
		log.Println("Closing database pool...")
		dbpool.Close()
	})

	// Start server
	errCh := make(chan error, 1)
	go func() {
		log.Printf("Server starting on :%s.", port)
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			errCh <- err
		}
	}()

	// --- Wait for either signal or server fatal error
	select {
	case <-rootCtx.Done():
		// Begin graceful shutdown
		stop()
		isShuttingDown.Store(true)
		log.Println("Received shutdown signal, marking unready.")

		// Give time for readiness change to propagate to LB/endpoints
		time.Sleep(_readinessDrainDelay)
		log.Println("Readiness drained; beginning graceful HTTP shutdown.")

		shutdownCtx, cancel := context.WithTimeout(context.Background(), _shutdownPeriod)
		defer cancel()
		if err := server.Shutdown(shutdownCtx); err != nil {
			log.Printf("Graceful shutdown timed out: %v", err)
			// Allow a short hard period before exiting
			time.Sleep(_shutdownHardPeriod)
		}
		// Now cancel the base context so any lingering handlers exit
		stopOngoingGracefully()
		log.Println("Server shut down gracefully.")
	case err := <-errCh:
		log.Fatalf("Server error: %v", err)
	}
}

func getenv(k, def string) string {
	if v := os.Getenv(k); v != "" {
		return v
	}
	return def
}
