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

	// OpenTelemetry imports
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/propagation"
	"go.opentelemetry.io/otel/sdk/resource"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
	"go.opentelemetry.io/otel/semconv/v1.26.0"
	"go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc"

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