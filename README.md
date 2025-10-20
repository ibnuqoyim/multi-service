# Assignment - Microservices Stack

A complete microservices stack with PHP API, Go service, Python service, and React frontend.

## Services Overview

| Service | Port | Description |
|---------|------|-------------|
| **Frontend** | 4135 | React application with user registration form |
| **PHP API** | 8080 | Main API for user management with MySQL database |
| **Go Service** | 8081 | Proxy service to PHP API |
| **Python Service** | 8082 | Orchestration service that calls PHP API and Go service |
| **Database** | 3306 | MySQL 8 database |

## Quick Start

### Option 1: Run All Services Together (Recommended)

```bash
# From the assignment root directory
docker-compose up --build

# Or run in background
docker-compose up --build -d

# Stop all services
docker-compose down
```

Access Points:

- Frontend: http://localhost:4135
- PHP API: http://localhost:8080
- Go Service: http://localhost:8081
- Python Service: http://localhost:8082

Option 2: Run Individual Services
You can also run each service separately using their individual docker-compose files:


# PHP API (start this first)
```bash
cd php-api
docker-compose up --build -d
```

# Go Service
```bash
cd ../go-service
docker-compose up --build -d
```

# Python Service
```bash
cd ../python-service
docker-compose up --build -d
```

# Frontend
```bash
cd ../frontend
docker-compose up --build
```