#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 Setting up environment files...${NC}"

# Copy main .env file if it doesn't exist
if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        cp .env.example .env
        echo -e "${GREEN}✅ Created main .env file from .env.example${NC}"
    else
        echo -e "${RED}❌ .env.example not found in root directory${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}⚠️  Main .env file already exists${NC}"
fi

# Setup service-specific .env files
services=("laravel-svc" "go-service" "python-service" "frontend")

for service in "${services[@]}"; do
    if [ -d "$service" ]; then
        cd "$service"
        if [ ! -f .env ]; then
            if [ -f .env.example ]; then
                cp .env.example .env
                echo -e "${GREEN}✅ Created .env file for $service${NC}"
            else
                echo -e "${YELLOW}⚠️  No .env.example found for $service${NC}"
            fi
        else
            echo -e "${YELLOW}⚠️  .env file already exists for $service${NC}"
        fi
        cd ..
    else
        echo -e "${RED}❌ Service directory $service not found${NC}"
    fi
done

echo -e "\n${BLUE}📋 Environment Setup Summary:${NC}"
echo "Main .env file: $([ -f .env ] && echo "✅ Ready" || echo "❌ Missing")"
echo "Laravel .env:   $([ -f laravel-svc/.env ] && echo "✅ Ready" || echo "❌ Missing")"
echo "Go .env:        $([ -f go-service/.env ] && echo "✅ Ready" || echo "❌ Missing")"
echo "Python .env:    $([ -f python-service/.env ] && echo "✅ Ready" || echo "❌ Missing")"
echo "Frontend .env:  $([ -f frontend/.env ] && echo "✅ Ready" || echo "❌ Missing")"

echo -e "\n${GREEN}🎉 Environment setup completed!${NC}"
echo -e "${BLUE}💡 You can now customize the .env files as needed before running:${NC}"
echo -e "   ${YELLOW}./deploy.sh${NC}"
