package main

import (
	"bytes"
	"encoding/json"
	"io"
	"log"
	"net/http"
	"os"

	"github.com/joho/godotenv"
)

type Config struct {
	Port          string
	LaravelApiURL string
}

// loadConfig loads configuration from environment variables
func loadConfig() (*Config, error) {
	// Load .env file
	if err := godotenv.Load(); err != nil {
		log.Printf("Warning: Error loading .env file: %v", err)
	} else {
		log.Printf("Successfully loaded .env file")
	}

	config := &Config{
		Port:          getEnvWithDefault("PORT", "8081"),
		LaravelApiURL: getEnvWithDefault("LARAVEL_API_URL", "http://localhost:8080/api/users"),
	}

	// Log loaded configuration
	log.Printf("Configuration loaded:")
	log.Printf("  PORT: %s", config.Port)
	log.Printf("  LARAVEL_API_URL: %s", config.LaravelApiURL)

	return config, nil
}

// getEnvWithDefault gets environment variable with default value
func getEnvWithDefault(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

func pingHandler(w http.ResponseWriter, r *http.Request) {
	resp := map[string]string{"message": "pong from Go service"}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

// createUserHandler creates a handler function with access to config
func createUserHandler(config *Config) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")

		log.Printf("Received %s request to %s", r.Method, r.URL.Path)

		reqBody, err := io.ReadAll(r.Body)
		if err != nil {
			log.Printf("Error reading request body: %v", err)
			w.WriteHeader(http.StatusBadRequest)
			json.NewEncoder(w).Encode(map[string]string{"error": "Failed to read request body"})
			return
		}

		log.Printf("Request body: %s", string(reqBody))

		// Validate JSON
		var user map[string]interface{}
		if err := json.Unmarshal(reqBody, &user); err != nil {
			log.Printf("Error parsing JSON: %v", err)
			w.WriteHeader(http.StatusBadRequest)
			json.NewEncoder(w).Encode(map[string]string{"error": "Invalid JSON format"})
			return
		}

		// Forward request to Laravel API
		if err := forwardToLaravelAPI(config.LaravelApiURL, reqBody, w); err != nil {
			log.Printf("Error forwarding to Laravel API: %v", err)
		}
	}
}

// forwardToLaravelAPI forwards the request to Laravel API
func forwardToLaravelAPI(laravelApiURL string, reqBody []byte, w http.ResponseWriter) error {
	log.Printf("Forwarding request to: %s", laravelApiURL)

	// Create request to Laravel API
	req, err := http.NewRequest("POST", laravelApiURL, bytes.NewBuffer(reqBody))
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(map[string]string{"error": "Failed to create request"})
		return err
	}

	req.Header.Set("Content-Type", "application/json")

	// Make request to Laravel API
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(map[string]string{"error": "Failed to connect to Laravel API"})
		return err
	}
	defer resp.Body.Close()

	// Read and forward response
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(map[string]string{"error": "Failed to read response"})
		return err
	}

	log.Printf("Laravel API response status: %d", resp.StatusCode)
	log.Printf("Laravel API response body: %s", string(body))

	w.WriteHeader(resp.StatusCode)
	w.Write(body)

	return nil
}

func main() {
	log.Printf("Starting Go service...")

	// Load configuration
	config, err := loadConfig()
	if err != nil {
		log.Fatalf("Failed to load configuration: %v", err)
	}

	// Setup routes
	http.HandleFunc("/ping", pingHandler)
	http.HandleFunc("/users", createUserHandler(config))

	// Ensure port has colon prefix
	port := config.Port
	if len(port) > 0 && port[0] != ':' {
		port = ":" + port
	}

	if err := http.ListenAndServe(port, nil); err != nil {
		log.Fatalf("Server failed to start: %v", err)
	}
}
