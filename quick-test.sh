#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}⚡ Quick Service Health Check${NC}"
echo "=================================="

# Function to check service
check_service() {
    local name=$1
    local url=$2
    local expected_pattern=$3
    
    echo -e "\n${YELLOW}Checking $name...${NC}"
    response=$(curl -s "$url" 2>/dev/null)
    status=$?
    
    if [ $status -eq 0 ] && echo "$response" | grep -q "$expected_pattern"; then
        echo -e "${GREEN}✅ $name is running${NC}"
        return 0
    else
        echo -e "${RED}❌ $name is not responding${NC}"
        return 1
    fi
}

# Load environment variables from .env file
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
fi

# Load environment variables or use defaults
LARAVEL_PORT="${LARAVEL_PORT:-8080}"
GO_PORT="${GO_SERVICE_PORT:-8081}"
PYTHON_PORT="${PYTHON_SERVICE_PORT:-8082}"
FRONTEND_PORT="${FRONTEND_PORT:-4135}"

# Check all services
check_service "Laravel API" "http://localhost:${LARAVEL_PORT}/api/health" "ok"
check_service "Go Service" "http://localhost:${GO_PORT}/ping" "pong"
check_service "Python Service" "http://localhost:${PYTHON_PORT}/hello" "Hello"
check_service "Frontend" "http://localhost:${FRONTEND_PORT}/" "doctype"

echo -e "\n${BLUE}🐳 Docker Container Status:${NC}"
docker-compose ps

echo -e "\n${BLUE}📊 Quick API Test:${NC}"
echo "Creating a test user..."
TIMESTAMP=$(date +"%d%m%y%H%M%S")
result=$(curl -s -X POST http://localhost:${LARAVEL_PORT}/api/users \
    -H "Content-Type: application/json" \
    -d "{\"name\": \"Quick Test\", \"email\": \"quick${TIMESTAMP}@test.com\"}" 2>/dev/null)

if echo "$result" | grep -q "success.*true"; then
    echo -e "${GREEN}✅ User creation successful${NC}"
    echo "$result" | jq . 2>/dev/null || echo "$result"
else
    echo -e "${RED}❌ User creation failed${NC}"
    echo "$result"
fi

echo -e "\n${BLUE}💡 Full test command: ${YELLOW}./test-endpoints.sh${NC}"
