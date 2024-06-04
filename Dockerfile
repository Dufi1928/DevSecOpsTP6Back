# Utiliser l'image officielle PHP FPM
FROM php:8.1-fpm

# Mettre à jour les informations de package et installer les dépendances
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

# Installer les extensions PHP nécessaires
RUN docker-php-ext-install intl pdo pdo_mysql mbstring zip opcache

# Préparer la configuration de Nginx
COPY docker/nginx/default.conf /etc/nginx/sites-available/default
RUN rm -f /etc/nginx/sites-enabled/default && ln -s /etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/

# Installer Composer pour la gestion des dépendances PHP
COPY --from=composer:2.2 /usr/bin/composer /usr/bin/composer

# Définir le répertoire de travail à /var/www/html
WORKDIR /var/www/html

# Copier le code source de l'application dans le répertoire de travail
COPY . /var/www/html

# Définir les bonnes permissions sur les fichiers et dossiers
RUN chown -R www-data:www-data /var/www/html

# Installer les dépendances avec Composer, sans inclure les composants de développement
RUN composer install --no-dev --optimize-autoloader

# Exposer le port 80 pour l'application
EXPOSE 80

# Utiliser 'exec' pour Nginz reste en foreground et démarrer PHP-FPM en non-daemon mode
CMD php-fpm -D ; exec nginx -g 'daemon off;'
