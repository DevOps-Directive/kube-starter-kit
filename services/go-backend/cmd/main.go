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

	// OpenTelemetry imports
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/propagation"
	"go.opentelemetry.io/otel/sdk/resource"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
	"go.opentelemetry.io/otel/semconv/v1.26.0"
	"go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc"

	// pgx v5 instrumentation
	"github.com/exaring/otelpgx"
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

	// --- OpenTelemetry (traces via OTLP/gRPC)
	shutdownOTel, err := initOTel(rootCtx, "go-backend")
	if err != nil {
		log.Fatalf("init OTel: %v", err)
	}
	defer func() { _ = shutdownOTel(context.Background()) }()

	// --- DB pool (pgx + OTel)
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	cfg, err := pgxpool.ParseConfig(dsn)
	if err != nil {
		log.Fatalf("parse pgx config: %v", err)
	}
	// Attach OTel tracer so queries become child spans of r.Context()
	cfg.ConnConfig.Tracer = otelpgx.NewTracer()

	dbpool, err := pgxpool.NewWithConfig(ctx, cfg)
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
		sleep := time.Duration(rand.Intn(1)) * time.Second
		log.Printf("Simulating %v work...", sleep)
		select {
		case <-time.After(sleep):
		case <-r.Context().Done():
			log.Println("Request cancelled before sleep finished")
			http.Error(w, "Request cancelled.", http.StatusRequestTimeout)
			return
		}

		var random float64
		// IMPORTANT: using r.Context() so DB spans nest under the HTTP span.
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

	// Wrap mux with otelhttp to create/continue request spans and extract W3C context
	// You can customize span names via otelhttp.WithSpanNameFormatter if desired.
	otelHandler := otelhttp.NewHandler(mux, "http.server")

	server := &http.Server{
		Addr: ":" + port,
		// Requests inherit this context instead of being tied to rootCtx,
		// so they aren't cancelled immediately on SIGTERM.
		BaseContext:       func(_ net.Listener) context.Context { return ongoingCtx },
		Handler:           otelHandler,
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

// initOTel configures tracing to export to an OTLP/gRPC collector.
// Set OTEL_EXPORTER_OTLP_ENDPOINT=host:4317 (no scheme). Uses plaintext by default.
func initOTel(ctx context.Context, serviceName string) (func(context.Context) error, error) {
	endpoint := getenv("OTEL_EXPORTER_OTLP_ENDPOINT", "localhost:4317")

	exp, err := otlptracegrpc.New(
		ctx,
		otlptracegrpc.WithEndpoint(endpoint),
		otlptracegrpc.WithInsecure(), // plaintext inside cluster; remove if you terminate TLS on collector
	)
	if err != nil {
		return nil, fmt.Errorf("create OTLP exporter: %w", err)
	}

	res, err := resource.New(
		ctx,
		resource.WithSchemaURL(semconv.SchemaURL),
		resource.WithAttributes(
			semconv.ServiceName(serviceName),
		),
	)
	if err != nil {
		return nil, fmt.Errorf("create resource: %w", err)
	}

	tp := sdktrace.NewTracerProvider(
		sdktrace.WithBatcher(exp),
		sdktrace.WithResource(res),
		// Respect OTEL_TRACES_SAMPLER env if set; default ParentBased(AlwaysOn)
	)

	otel.SetTracerProvider(tp)
	otel.SetTextMapPropagator(
		propagation.NewCompositeTextMapPropagator(
			propagation.TraceContext{},
			propagation.Baggage{},
		),
	)

	return tp.Shutdown, nil
}