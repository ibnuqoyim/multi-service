# PHP API with Docker

Simple PHP API with Docker Compose that uses environment variables from the `.env` file.

## Setup

1. **Edit file .env sesuai kebutuhan:**
   ```bash
   DB_HOST=db          # Nama service database di docker-compose
   DB_NAME=users_db    # Nama database
   DB_USER=root        # Username database
   DB_PASS=example     # Password database
   ```

3. **Jalankan dengan Docker Compose:**
   ```bash
   docker-compose up --build
   ```

## Environment Variables

Docker Compose will automatically read variables from the `.env` file using the `${VARIABLE_NAME}` syntax.

### Variables used:
- `DB_HOST` - Database host (use `db` for Docker, `localhost` for local)
- `DB_NAME` - Database name
- `DB_USER` - Database username  
- `DB_PASS` - Password database

## API Endpoints

### POST /users
Create a new user.

**Request Body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com"
}
```

**Success Response (201):**
```json
{
  "id": 1,
  "name": "John Doe",
  "email": "john@example.com"
}
```

**Validation Rules:**
- `name`: Required, string, minimum 2 characters, maximum 100 characters
- `email`: Required, valid email format, unique in database

**Error Responses:**
- `400` - Validation errors (missing fields, invalid email, name too short/long)
- `409` - Email already exists
- `500` - Database or server errors

### GET /users
Get all users from the database.

**Success Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com"
    },
    {
      "id": 2,
      "name": "Jane Smith",
      "email": "jane@example.com"
    }
  ],
  "count": 2,
  "message": "Users retrieved successfully"
}
```

**Error Responses:**
- `500` - Database or server errors

## Testing the API

### Using cURL

```bash
# Create a new user
curl -X POST http://localhost:8080/users \
  -H "Content-Type: application/json" \
  -d '{"name": "John Doe", "email": "john@example.com"}'

# Get all users
curl http://localhost:8080/users

# Test validation error
curl -X POST http://localhost:8080/users \
  -H "Content-Type: application/json" \
  -d '{"name": "J", "email": "invalid-email"}'

# Test duplicate email
curl -X POST http://localhost:8080/users \
  -H "Content-Type: application/json" \
  -d '{"name": "Jane Doe", "email": "john@example.com"}'
```

## Database Schema

The users table structure:

```sql
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100),
  email VARCHAR(100)
);
```

## Services

- **php-api**: PHP application (port 8080)
- **db**: MySQL 8 database (port 3306)

## Volumes

- `php_api_db_data`: Persistent MySQL data storage
- `./db.sql`: Database initialization script

## Features

- ✅ **User Creation**: POST endpoint with comprehensive validation
- ✅ **User Listing**: GET endpoint to retrieve all users
- ✅ **Input Validation**: Name (2-100 chars) and email format validation
- ✅ **Duplicate Prevention**: Email uniqueness checking
- ✅ **Error Handling**: Proper HTTP status codes and error messages
- ✅ **CORS Support**: Cross-origin requests enabled
- ✅ **Docker Support**: Complete containerization with MySQL

## Troubleshooting

1. **Database Connection Issues**: 
   - Ensure MySQL container is running: `docker-compose ps`
   - Check environment variables in `.env` file

2. **404 Errors**: 
   - Verify `.htaccess` file exists for proper routing
   - Rebuild containers: `docker-compose up --build`

3. **Port Conflicts**: 
   - Change `PORT` in `.env` if 8080 is already in use
   - Update docker-compose.yml ports mapping accordingly
