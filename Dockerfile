# Utiliser l'image officielle PHP FPM
FROM php:8.1-fpm

# Installer les dépendances système
RUN apt-get update && apt-get install -y \
    nginx \
    git \
    unzip \
    libicu-dev \
    libpq-dev \
    libonig-dev \
    libzip-dev \
    zip \
&& rm -rf /var/lib/apt/lists/*

# Installer les extensions PHP
RUN docker-php-ext-install intl pdo pdo_mysql mbstring zip opcache

# Configuration de Nginx
COPY docker/nginx/default.conf /etc/nginx/sites-available/default
RUN ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/

# Installer Composer
COPY --from=composer:2.2 /usr/bin/composer /usr/bin/composer

# Définir le répertoire de travail
WORKDIR /var/www/html

# Copier le contenu du répertoire de l'application
COPY . /var/www/html

# Définir les permissions des fichiers
RUN chown -R www-data:www-data /var/www/html

# Installer les dépendances Symfony
RUN composer install --no-dev --optimize-autoloader

# Exposer les ports
EXPOSE 80 443

# Démarrer Nginx et PHP-FPM
CMD ["sh", "-c", "service php8.1-fpm start && nginx -g 'daemon off;'"]
