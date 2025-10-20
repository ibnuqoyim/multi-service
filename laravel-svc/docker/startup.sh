#!/bin/bash

# Laravel Docker Startup Script
echo "🚀 Starting Laravel service..."

# Wait for database to be ready
echo "⏳ Waiting for database connection..."
until php artisan migrate:status > /dev/null 2>&1; do
    echo "Database not ready, waiting 2 seconds..."
    sleep 2
done

echo "✅ Database connection established!"

# Run migrations
echo "🔄 Running database migrations..."
php artisan migrate --force

echo "✅ Migrations completed!"

# Start supervisor (PHP-FPM + Nginx)
echo "🌐 Starting web server..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
