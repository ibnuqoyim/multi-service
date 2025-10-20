# Laravel User API Service

A dockerized Laravel 11 application with PHP 8.2 that provides user management API endpoints. This service is part of a microservices architecture and integrates with MySQL database.

## 🚀 Features

- **Laravel 11** with **PHP 8.2**
- **Dockerized** with Nginx + PHP-FPM + Supervisor
- **User Management API** with full CRUD operations
- **MySQL 8** database integration
- **Comprehensive validation** and error handling
- **Health check** endpoint for monitoring
- **RESTful API** design with JSON responses

## 🏗️ Architecture

- **Framework:** Laravel 11
- **PHP Version:** 8.2
- **Database:** MySQL 8
- **Web Server:** Nginx
- **Process Manager:** Supervisor
- **Container:** Docker with Alpine Linux

## 📋 Prerequisites

- Docker and Docker Compose
- MySQL 8 database (provided via docker-compose)

## 🔧 Installation & Setup

### 1. Build and Run with Docker

```bash
# Build the Docker image
docker-compose build laravel-svc

# Start the service
docker-compose up -d laravel-svc

# Generate application key (if needed)
docker exec laravel-service php artisan key:generate

# Run migrations
docker exec laravel-service php artisan migrate --force
```

### 2. Service URLs

- **API Base URL:** http://localhost:8080
- **Health Check:** http://localhost:8080/api/health
- **Database:** localhost:3306 (MySQL 8)

## 📚 API Documentation

### Base URL
```
http://localhost:8080/api
```

### Endpoints

#### 1. Health Check
```http
GET /api/health
```

**Response:**
```json
{
  "status": "ok",
  "timestamp": "2025-10-20T13:28:24.000000Z",
  "service": "laravel-api"
}
```

#### 2. Create User
```http
POST /api/users
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "created_at": "2025-10-20T13:28:24.000000Z",
    "updated_at": "2025-10-20T13:28:24.000000Z"
  },
  "message": "User created successfully"
}
```

#### 3. Get All Users
```http
GET /api/users
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "created_at": "2025-10-20T13:28:24.000000Z",
      "updated_at": "2025-10-20T13:28:24.000000Z"
    }
  ],
  "message": "Users retrieved successfully"
}
```

#### 4. Get User by ID
```http
GET /api/users/{id}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "created_at": "2025-10-20T13:28:24.000000Z",
    "updated_at": "2025-10-20T13:28:24.000000Z"
  },
  "message": "User retrieved successfully"
}
```

## 🔒 Validation Rules

### Create User (POST /api/users)
- **name**: Required, string, 2-100 characters
- **email**: Required, valid email format, unique in database, max 255 characters

## 📊 Error Responses

### Validation Error (400 Bad Request)
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "email": ["The email has already been taken."],
    "name": ["The name must be at least 2 characters."]
  }
}
```

### User Not Found (404 Not Found)
```json
{
  "success": false,
  "message": "User not found"
}
```

### Email Already Exists (409 Conflict)
```json
{
  "success": false,
  "message": "Email already exists",
  "error": "The email address is already taken"
}
```

### Server Error (500 Internal Server Error)
```json
{
  "success": false,
  "message": "Failed to create user",
  "error": "Error details"
}
```

## 🗄️ Database Schema

### simple_users Table
```sql
CREATE TABLE simple_users (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  created_at TIMESTAMP NULL,
  updated_at TIMESTAMP NULL
);
```

## 🧪 Testing Examples

### Using cURL

```bash
# Create a user
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{"name": "John Doe", "email": "john@example.com"}'

# Get all users
curl http://localhost:8080/api/users

# Get specific user
curl http://localhost:8080/api/users/1

# Health check
curl http://localhost:8080/api/health
```

## 🐳 Docker Configuration

### Dockerfile Features
- **Base Image:** php:8.2-fpm-alpine
- **Web Server:** Nginx with optimized configuration
- **Process Manager:** Supervisor for managing PHP-FPM and Nginx
- **Extensions:** PDO MySQL, GD, ZIP, BCMath, Intl, OPcache
- **Composer:** Latest version for dependency management

### Docker Compose Integration
- **Service Name:** laravel-svc
- **Container Name:** laravel-service
- **Port:** 8080:80
- **Dependencies:** MySQL database with health checks
- **Networks:** assignment-network (shared with other services)

## 🔧 Development

### Project Structure
```
laravel-svc/
├── app/
│   ├── Http/Controllers/UserController.php
│   └── Models/SimpleUser.php
├── database/migrations/
│   └── 2025_10_20_125237_create_simple_users_table.php
├── routes/api.php
├── docker/
│   ├── nginx.conf
│   ├── supervisord.conf
│   └── php.ini
├── Dockerfile
└── README.md
```

### Key Components
- **SimpleUser Model:** Eloquent model for user data
- **UserController:** API controller with CRUD operations
- **Migration:** Database schema for simple_users table
- **API Routes:** RESTful endpoints configuration

## 📝 License

This project is open-sourced software licensed under the [MIT license](https://opensource.org/licenses/MIT).
