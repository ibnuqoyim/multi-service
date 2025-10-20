#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Load environment variables from .env file
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
fi

# Test configuration - Load from environment or use defaults
BASE_URL="http://localhost"
LARAVEL_PORT="${LARAVEL_PORT:-8080}"
GO_PORT="${GO_SERVICE_PORT:-8081}"
PYTHON_PORT="${PYTHON_SERVICE_PORT:-8082}"
FRONTEND_PORT="${FRONTEND_PORT:-4135}"

# Test counter
TOTAL_TESTS=0
PASSED_TESTS=0

# Function to generate timestamp for unique emails
generate_timestamp() {
    date +"%d%m%y%H%M%S"
}

echo -e "${BLUE}🧪 Starting Endpoint Testing Suite${NC}"
echo "=================================================="

# Function to test endpoint
test_endpoint() {
    local method=$1
    local url=$2
    local expected_status=$3
    local description=$4
    local data=$5
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -e "\n${YELLOW}Test $TOTAL_TESTS: $description${NC}"
    echo "URL: $method $url"
    
    if [ "$method" = "POST" ] && [ -n "$data" ]; then
        response=$(curl -s -w "\n%{http_code}" -X POST "$url" \
            -H "Content-Type: application/json" \
            -d "$data")
    else
        response=$(curl -s -w "\n%{http_code}" "$url")
    fi
    
    # Extract status code (last line)
    status_code=$(echo "$response" | tail -n1)
    # Extract body (all lines except last)
    body=$(echo "$response" | sed '$d')
    
    if [ "$status_code" = "$expected_status" ]; then
        echo -e "${GREEN}✅ PASS${NC} - Status: $status_code"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        
        # Pretty print JSON if response is JSON
        if echo "$body" | jq . >/dev/null 2>&1; then
            echo "Response:"
            echo "$body" | jq .
        else
            echo "Response: $body"
        fi
    else
        echo -e "${RED}❌ FAIL${NC} - Expected: $expected_status, Got: $status_code"
        echo "Response: $body"
    fi
}

# Wait for services to be ready
echo -e "\n${BLUE}⏳ Waiting for services to be ready...${NC}"
sleep 10

# Test 1: Laravel Health Check
test_endpoint "GET" "$BASE_URL:$LARAVEL_PORT/api/health" "200" "Laravel Health Check"

# Test 2: Laravel Get All Users (should be empty initially)
test_endpoint "GET" "$BASE_URL:$LARAVEL_PORT/api/users" "200" "Laravel Get All Users"

# Generate timestamp for unique emails
TIMESTAMP=$(generate_timestamp)

# Test 3: Laravel Create User
test_endpoint "POST" "$BASE_URL:$LARAVEL_PORT/api/users" "201" "Laravel Create User" \
    "{\"name\": \"John Doe\", \"email\": \"john@example.com\"}"

# Test 4: Laravel Create Another User
test_endpoint "POST" "$BASE_URL:$LARAVEL_PORT/api/users" "201" "Laravel Create Second User" \
    "{\"name\": \"Jane Smith\", \"email\": \"jane${TIMESTAMP}@example.com\"}"

# Test 5: Laravel Get Specific User
test_endpoint "GET" "$BASE_URL:$LARAVEL_PORT/api/users/1" "200" "Laravel Get User by ID"

# Test 6: Laravel Validation Error (duplicate email)
test_endpoint "POST" "$BASE_URL:$LARAVEL_PORT/api/users" "400" "Laravel Validation Error" \
    '{"name": "John Duplicate", "email": "john@example.com"}'

# Test 7: Laravel Validation Error (invalid data)
test_endpoint "POST" "$BASE_URL:$LARAVEL_PORT/api/users" "400" "Laravel Invalid Data" \
    '{"name": "A", "email": "invalid-email"}'

# Test 8: Go Service Health Check
test_endpoint "GET" "$BASE_URL:$GO_PORT/ping" "200" "Go Service Health Check"

# Test 9: Go Service Create User (proxy to Laravel)
test_endpoint "POST" "$BASE_URL:$GO_PORT/users" "201" "Go Service Create User" \
    "{\"name\": \"Go User\", \"email\": \"go${TIMESTAMP}@example.com\"}"

# Test 10: Python Service Health Check
test_endpoint "GET" "$BASE_URL:$PYTHON_PORT/hello" "200" "Python Service Health Check"

# Test 11: Frontend Service
test_endpoint "GET" "$BASE_URL:$FRONTEND_PORT/" "200" "Frontend Service"

# Test 12: Laravel Get All Users (should have users now)
test_endpoint "GET" "$BASE_URL:$LARAVEL_PORT/api/users" "200" "Laravel Get All Users (Final)"

# Test Summary
echo -e "\n${BLUE}=================================================="
echo "🏁 Test Summary"
echo "==================================================${NC}"
echo -e "Total Tests: ${YELLOW}$TOTAL_TESTS${NC}"
echo -e "Passed: ${GREEN}$PASSED_TESTS${NC}"
echo -e "Failed: ${RED}$((TOTAL_TESTS - PASSED_TESTS))${NC}"

if [ $PASSED_TESTS -eq $TOTAL_TESTS ]; then
    echo -e "\n${GREEN}🎉 All tests passed! System is working correctly.${NC}"
    exit 0
else
    echo -e "\n${RED}❌ Some tests failed. Please check the services.${NC}"
    exit 1
fi
