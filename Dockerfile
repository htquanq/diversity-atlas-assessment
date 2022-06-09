# Multi stage build
FROM composer:2.3.7 as builder
COPY . /app/
RUN composer install --prefer-dist --no-dev --optimize-autoloader --no-interaction

FROM php:8.0.9-apache-buster as app

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_mysql
COPY --from=builder /app /var/www/html
COPY docker/000-default.conf /etc/apache2/sites-enabled/default.conf
COPY .env /var/www/html/.env

# Cache config, routes
RUN php artisan config:cache && \
    php artisan route:cache && \
    chmod 777 -R /var/www/html/storage/ && \
    chown -R www-data:www-data /var/www/ && \
    a2enmod rewrite