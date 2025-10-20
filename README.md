# Microservices Assignment

A complete microservices stack with Laravel API, Go service, Python service, and React frontend.

# 🚀 Deployment Guide

## Overview
This guide explains how to deploy the complete microservices stack with automatic file copying, database migration, and endpoint testing.

## ✅ What's Automated

### 1. Laravel Service
- ✅ Automatic environment setup (.env)
- ✅ Database connection waiting
- ✅ Automatic migration execution
- ✅ Web server startup (Nginx + PHP-FPM)
- ✅ CORS configuration for frontend access

### 2. Go Service
- ✅ Automatic environment setup (.env.example → .env)
- ✅ Dependency management (go mod tidy)
- ✅ Service ready for proxying to Laravel API

### 3. Python Service
- ✅ Automatic environment setup (.env.example → .env)
- ✅ Dependency installation (pip install -r requirements.txt)
- ✅ Service orchestration ready

### 4. Frontend Service
- ✅ Automatic environment setup (.env.example → .env)
- ✅ Build process (npm run build)
- ✅ Production server (vite preview)

## 🎯 Deployment Options

### Option 1: Full Automated Deployment (Recommended)
```bash
./deploy.sh
```
This script will:
- Clean up existing containers
- Build and start all services
- Wait for services to be healthy
- Run comprehensive endpoint tests
- Show service status and URLs

### Option 2: Manual Deployment
```bash
# Build and start services
docker-compose up -d --build

# Wait for services to be ready
sleep 30

# Run tests
./test-endpoints.sh
```

### Option 3: Quick Health Check
```bash
# Check if all services are running
./quick-test.sh
```

## 🌐 Service URLs

After successful deployment, access these URLs:

| Service | URL | Description |
|---------|-----|-------------|
| **Frontend** | http://localhost:4135 | React user registration form |
| **Laravel API** | http://localhost:8080/api/users | Main API endpoints |
| **Go Service** | http://localhost:8081/users | Proxy to Laravel API |
| **Python Service** | http://localhost:8082/hello | Health check endpoint |
| **Health Check** | http://localhost:8080/api/health | System health status |

## 🧪 Testing

### Automated Testing
The `test-endpoints.sh` script runs 12 comprehensive tests:

1. ✅ Laravel Health Check
2. ✅ Laravel Get All Users
3. ✅ Laravel Create User
4. ✅ Laravel Create Second User
5. ✅ Laravel Get User by ID
6. ✅ Laravel Validation Error (duplicate email)
7. ✅ Laravel Invalid Data Validation
8. ✅ Go Service Health Check
9. ✅ Go Service Create User (proxy)
10. ✅ Python Service Health Check
11. ✅ Frontend Service
12. ✅ Laravel Get All Users (final check)

### Manual Testing Examples
```bash
# Create user via Laravel API
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{"name": "John Doe", "email": "john@example.com"}'

# Create user via Go service (proxy)
curl -X POST http://localhost:8081/users \
  -H "Content-Type: application/json" \
  -d '{"name": "Jane Smith", "email": "jane@example.com"}'

# Get all users
curl http://localhost:8080/api/users

# Get specific user
curl http://localhost:8080/api/users/1
```

## 🐳 Docker Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Go Service    │    │ Python Service  │
│   Port: 4135    │    │   Port: 8081    │    │   Port: 8082    │
└─────────┬───────┘    └─────────┬───────┘    └─────────┬───────┘
          │                      │                      │
          │                      │                      │
          └──────────────────────┼──────────────────────┘
                                 │
                    ┌─────────────▼───────────────┐
                    │     Laravel Service         │
                    │     Port: 8080 (Main API)  │
                    │     Auto Migration          │
                    └─────────────┬───────────────┘
                                  │
                    ┌─────────────▼───────────────┐
                    │     MySQL Database          │
                    │     Port: 3306              │
                    │     Auto Health Check       │
                    └─────────────────────────────┘
```

## 🔧 Troubleshooting

### Common Issues

1. **Services not starting**
   ```bash
   # Check container status
   docker-compose ps
   
   # Check logs
   docker logs laravel-service
   docker logs go-service-app
   ```

2. **Database connection issues**
   ```bash
   # Check database health
   docker exec laravel-service php -r "new PDO('mysql:host=db;dbname=users_db', 'root', 'example');"
   ```

3. **Port conflicts**
   ```bash
   # Check if ports are in use
   lsof -i :8080
   lsof -i :8081
   lsof -i :8082
   lsof -i :4135
   ```

### Reset Everything
```bash
# Complete cleanup
docker-compose down --volumes --remove-orphans
docker system prune -f

# Fresh deployment
./deploy.sh
```

## 📊 Expected Results

After successful deployment, you should see:

- ✅ All 12 endpoint tests passing
- ✅ All services showing "healthy" status
- ✅ Database with `simple_users` table created
- ✅ Frontend accessible with user registration form
- ✅ API endpoints responding with proper JSON

## 🎉 Success Indicators

1. **Laravel Service:** Shows migration completion and supervisor startup
2. **Go Service:** Shows successful connection to Laravel API
3. **Python Service:** Shows successful startup on port 8082
4. **Frontend:** Shows Vite preview server running
5. **Database:** Shows healthy status with proper connections

The system is ready when all tests pass and services show healthy status!
