# Utiliser l'image officielle PHP avec Apache
FROM php:8.1-apache

# Installer les dépendances système
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libicu-dev \
    libpq-dev \
    libonig-dev \
    libzip-dev \
    zip

# Installer les extensions PHP
RUN docker-php-ext-install intl pdo pdo_mysql mbstring zip opcache

# Activer le module mod_rewrite d'Apache
RUN a2enmod rewrite

# Copier le fichier de configuration Apache personnalisé
COPY docker/apache/000-default.conf /etc/apache2/sites-available/000-default.conf

# Installer Composer
COPY --from=composer:2.2 /usr/bin/composer /usr/bin/composer

# Définir le répertoire de travail
WORKDIR /var/www/html

# Copier le contenu du répertoire de l'application
COPY . /var/www/html

# Définir les permissions des fichiers
RUN chown -R www-data:www-data /var/www/html

# Installer les dépendances Symfony
RUN composer install

# Exposer le port 80
EXPOSE 80

# Démarrer le serveur Apache
CMD ["apache2-foreground"]