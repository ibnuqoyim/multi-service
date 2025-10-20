# Use PHP 8.2 FPM Alpine image
FROM php:8.2-fpm-alpine

# Set working directory
WORKDIR /var/www/html

# Install system dependencies
RUN apk add --no-cache \
    git \
    curl \
    libpng-dev \
    libxml2-dev \
    zip \
    unzip \
    oniguruma-dev \
    icu-dev \
    freetype-dev \
    libjpeg-turbo-dev \
    libzip-dev \
    nginx \
    supervisor

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
        pdo_mysql \
        mbstring \
        exif \
        pcntl \
        bcmath \
        gd \
        zip \
        intl \
        opcache

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy existing application directory contents
COPY . /var/www/html

# Copy existing application directory permissions
COPY --chown=www-data:www-data . /var/www/html

# Remove old composer.lock and update dependencies
RUN rm -f composer.lock && composer update --no-dev --optimize-autoloader --no-interaction

# Copy environment file and generate app key
RUN cp .env.example .env && php artisan key:generate --no-interaction

# Create necessary directories and set permissions
RUN mkdir -p /var/www/html/storage/logs \
    && mkdir -p /var/www/html/storage/framework/cache \
    && mkdir -p /var/www/html/storage/framework/sessions \
    && mkdir -p /var/www/html/storage/framework/views \
    && mkdir -p /var/www/html/bootstrap/cache \
    && mkdir -p /var/log/supervisor \
    && mkdir -p /var/run \
    && chown -R www-data:www-data /var/www/html/storage \
    && chown -R www-data:www-data /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage \
    && chmod -R 775 /var/www/html/bootstrap/cache

# Copy nginx configuration
COPY docker/nginx.conf /etc/nginx/nginx.conf

# Copy supervisor configuration
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy PHP configuration
COPY docker/php.ini /usr/local/etc/php/conf.d/custom.ini

# Expose port 80
EXPOSE 80

# Start with inline commands
CMD ["sh", "-c", "echo '🚀 Starting Laravel service...' && echo '⏳ Waiting for database connection...' && until php -r 'new PDO(\"mysql:host=db;dbname=users_db\", \"root\", \"example\");' > /dev/null 2>&1; do echo 'Database not ready, waiting 2 seconds...'; sleep 2; done && echo '✅ Database connection established!' && echo '🔄 Running database migrations...' && php artisan migrate --force && echo '✅ Migrations completed!' && echo '🌐 Starting web server...' && exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf"]
