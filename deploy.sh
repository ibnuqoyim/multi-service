#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Deploying Microservices Application${NC}"
echo "=================================================="

# Step 0: Setup environment files
echo -e "\n${YELLOW}🔧 Setting up environment files...${NC}"
if [ -f "setup-env.sh" ]; then
    ./setup-env.sh
else
    echo -e "${YELLOW}⚠️  setup-env.sh not found, skipping environment setup${NC}"
fi

# Step 1: Clean up existing containers
echo -e "\n${YELLOW}🧹 Cleaning up existing containers...${NC}"
docker-compose down --volumes --remove-orphans

# Step 2: Remove old images (optional - uncomment if needed)
# echo -e "\n${YELLOW}🗑️  Removing old images...${NC}"
# docker-compose build --no-cache

# Step 3: Build and start services
echo -e "\n${YELLOW}🔨 Building and starting services...${NC}"
docker-compose up -d --build

# Step 4: Wait for services to be healthy
echo -e "\n${YELLOW}⏳ Waiting for services to be healthy...${NC}"
echo "This may take a few minutes for the first run..."

# Wait for Laravel service to be healthy
echo "Waiting for Laravel service..."
timeout=300  # 5 minutes
counter=0
while [ $counter -lt $timeout ]; do
    if docker ps --filter "name=laravel-service" --filter "health=healthy" --format "table {{.Names}}" | grep -q laravel-service; then
        echo -e "${GREEN}✅ Laravel service is healthy${NC}"
        break
    fi
    sleep 5
    counter=$((counter + 5))
    echo "Still waiting... ($counter/$timeout seconds)"
done

if [ $counter -ge $timeout ]; then
    echo -e "${RED}❌ Laravel service failed to become healthy within $timeout seconds${NC}"
    echo "Checking logs:"
    docker logs laravel-service --tail 20
    exit 1
fi

# Wait for other services
echo "Waiting for other services..."
sleep 10

# Step 5: Show service status
echo -e "\n${BLUE}📊 Service Status:${NC}"
docker-compose ps

# Load environment variables from .env file
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
fi

# Load environment variables or use defaults
LARAVEL_PORT="${LARAVEL_PORT:-8080}"
GO_PORT="${GO_SERVICE_PORT:-8081}"
PYTHON_PORT="${PYTHON_SERVICE_PORT:-8082}"
FRONTEND_PORT="${FRONTEND_PORT:-4135}"
MYSQL_PORT="${MYSQL_PORT:-3306}"
MYSQL_DATABASE="${MYSQL_DATABASE:-users_db}"

# Step 6: Show service URLs
echo -e "\n${BLUE}🌐 Service URLs:${NC}"
echo "Laravel API:    http://localhost:${LARAVEL_PORT}/api/health"
echo "Go Service:     http://localhost:${GO_PORT}/ping"
echo "Python Service: http://localhost:${PYTHON_PORT}/hello"
echo "Frontend:       http://localhost:${FRONTEND_PORT}/"
echo "Database:       localhost:${MYSQL_PORT} (${MYSQL_DATABASE})"

# Step 7: Run tests
echo -e "\n${YELLOW}🧪 Running endpoint tests...${NC}"
if [ -f "test-endpoints.sh" ]; then
    ./test-endpoints.sh
else
    echo -e "${RED}❌ test-endpoints.sh not found${NC}"
fi

echo -e "\n${GREEN}🎉 Deployment completed!${NC}"
echo -e "You can now test the endpoints manually or run: ${YELLOW}./test-endpoints.sh${NC}"
