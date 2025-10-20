# Go Service

Simple Go service that proxies requests to PHP API.

## Arsitektur

- **Config Struct**: All configuration is stored in the `Config` struct
- **Dependency Injection**: Handler functions receive config as a parameter
- **Separation of Concerns**: Logic forwarding to PHP API is separated into its own function
- **godotenv**: Uses the godotenv library to read the .env file

## Setup

1. **Install dependencies:**
   ```bash
   go mod tidy
   ```

2. **Edit file .env sesuai kebutuhan:**
   ```bash
   PORT=8081
   PHP_API_URL=http://localhost:8080
   ```

## Menjalankan Aplikasi

### Cara 1: Dengan Docker

```bash
docker-compose up --build
```

## Environment Variables

The application will automatically read the `.env` file at startup. The variables used are:

- `PORT` - Port for Go service (default: 8081)
- `PHP_API_URL` - URL to PHP API (example: http://localhost:8080)

## API Endpoints

- **GET /ping** - Health check endpoint
  ```json
  {"message": "pong from Go service"}
  ```

- **POST /users** - Proxy to PHP API to create user
  ```json
  {
    "name": "John Doe",
    "email": "john@example.com"
  }
  ```

## Troubleshooting

1. **Config not read**: Run `go mod tidy` first
2. **Cannot connect to PHP API**: Make sure PHP API is running at the correct URL
3. **Port already in use**: Change PORT in the `.env` file
4. **Import error**: Make sure `go.mod` and `go.sum` exist and are valid
