FROM php:8.4-apache
# konfigurasi PHP produksi: error tidak tampil ke pengguna, dicatat ke log 
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
# ekstensi PostgreSQL untuk PDO
RUN apt-get update && apt-get install -y --no-install-recommends libpq-dev \ 
    && docker-php-ext-install pdo_pgsql \
    && rm -rf /var/lib/apt/lists/*
# Apache mendengarkan di $PORT (bawaan 8080); semua alamat ke index.php 
ENV PORT=8080
RUN sed -i 's/^Listen 80$/Listen ${PORT}/' /etc/apache2/ports.conf \
    && sed -i 's/<VirtualHost \*:80>/<VirtualHost *:${PORT}>/' \
    /etc/apache2/sites-available/000-default.conf \
    && echo 'FallbackResource /index.php' > /etc/apache2/conf-enabled/fallback.conf 
    # kode paling akhir: lapisan di atas tetap ter-cache
COPY . /var/www/html/ 
EXPOSE 8080
