FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    unzip \
    libzip-dev \
    libpq-dev \
    iproute2 \
    procps \
    default-mysql-client \
    # Replacing libmysqlclient-dev with libmariadb-dev-compat
    libmariadb-dev-compat && \
    docker-php-ext-install \
    pdo \
    pdo_pgsql \
    pdo_mysql \
    zip

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy the Symfony application files into the container
COPY . /var/www

# Set the working directory
WORKDIR /var/www

ENV COMPOSER_ALLOW_SUPERUSER=1

# Install application dependencies without scripts
RUN composer install --no-interaction --no-scripts

# Expose port 9000
EXPOSE 9000

CMD ["php-fpm"]
