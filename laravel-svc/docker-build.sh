#!/bin/bash

# Laravel Docker Build Script
echo "🚀 Building Laravel Docker Container..."

# Copy environment file
if [ ! -f .env ]; then
    echo "📋 Copying .env.example to .env..."
    cp .env.example .env
fi

# Generate application key if not exists
if ! grep -q "APP_KEY=base64:" .env; then
    echo "🔑 Generating application key..."
    php artisan key:generate --no-interaction
fi

# Build Docker image
echo "🏗️ Building Docker image..."
docker build -t laravel-app:latest .

echo "✅ Build completed!"
echo "🌐 You can now run: docker-compose up -d laravel-svc"
echo "📱 Laravel will be available at: http://localhost:8083"
