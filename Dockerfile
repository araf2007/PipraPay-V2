FROM php:8.1-apache

# 1. Install system dependencies required for GD, Imagick, and ZipArchive
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libzip-dev \
    zip \
    unzip \
    libmagickwand-dev \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# 2. Configure and install standard PHP extensions (including GD & ZipArchive)
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) gd zip mysqli pdo pdo_mysql bcmath opcache

# 3. Install and enable Imagick extension via PECL
RUN pecl install imagick \
    && docker-php-ext-enable imagick

# 4. Enable Apache modules (mod_rewrite and mod_headers)
RUN a2enmod rewrite headers

# 5. Set working directory and copy application source code
WORKDIR /var/www/html
COPY . /var/www/html/

# 6. Ensure correct file permissions so Apache can access files
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# 7. Expose default HTTP Port
EXPOSE 80
