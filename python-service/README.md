# Python Service

A Flask-based service with clean architecture using Config dataclass and proper .env file loading.

## Features

- **Config Object**: All configuration stored in dataclass
- **Environment Loading**: Uses python-dotenv to load .env files
- **Service Orchestration**: Calls Laravel API and Go service
- **Error Handling**: Comprehensive error handling with logging
- **Health Check**: Multiple endpoints for monitoring
- **Clean Architecture**: Separation of concerns with factory pattern

## Environment Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `PORT` | Port number for the service | `8082` | No |
| `LARAVEL_API_URL` | URL to Laravel API service | `http://laravel-service:80/api/users` | No |
| `GO_SERVICE_URL` | URL to Go service | `http://go-service:8081/ping` | No |

## Quick Start

### Using Docker Compose (Recommended)

```bash
# Copy environment file
cp .env.example .env

# Start the service
docker-compose up --build

# Service will be available at http://localhost:8082
```

### Local Development

```bash
# Install dependencies
pip install -r requirements.txt

# Copy environment file
cp .env.example .env

# Run the service
python app.py
```

## API Endpoints

### GET /hello
Health check endpoint.

**Response (200):**
```json
{
  "message": "Hello from Python service",
  "status": "healthy"
}
```

### GET /call
Calls other services and returns their responses with error handling.

**Response (200):**
```json
{
  "laravel_api": {
    "status_code": 200,
    "response": "response from Laravel API"
  },
  "go_service": {
    "status_code": 200,
    "response": {"message": "pong from Go service"}
  },
  "timestamp": "user-agent-string"
}
```

### GET /config
Get current configuration (for debugging).

**Response (200):**
```json
{
  "port": 8082,
  "laravel_api_url": "http://localhost:8080/users",
  "go_service_url": "http://localhost:8081/ping"
}
```

## Architecture

```python
@dataclass
class Config:
    """Configuration class to hold all application settings"""
    port: int
    laravel_api_url: str
    go_service_url: str

def load_config() -> Config:
    """Load configuration from environment variables and .env file"""

def create_app(config: Config) -> Flask:
    """Create Flask application with configuration"""
```

## Benefits of This Architecture

1. **Testable**: Config can be mocked for testing
2. **Maintainable**: Clear separation of concerns
3. **Readable**: Code is self-documenting with type hints
4. **Scalable**: Easy to add new configuration options
5. **Robust**: Comprehensive error handling and logging

## Dependencies

- Flask==2.3.3
- requests==2.31.0
- python-dotenv==1.0.0

## Logging

The application provides comprehensive logging for:
- Configuration loading status
- Environment variable values
- HTTP requests to external services
- Error handling details
- Application startup information
