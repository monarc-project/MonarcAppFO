FROM php:7.4-fpm-alpine

# Set user to root
USER root

# Set working directory
WORKDIR /var/www/html

# Install Additional dependencies
RUN apk update && apk add --no-cache \
    build-base shadow vim curl zlib libzip-dev \
    libpng-dev libjpeg-turbo-dev libwebp-dev libxpm-dev zlib-dev \
    openssl-dev oniguruma-dev \
    icu-dev bzip2-dev freetype freetype-dev \
    php \
    php-cli \
    php-gd \
    php-pdo \
    php-pdo_mysql \
    php-mysqli \
    php-curl \
    php-intl \
    php-json \
    php-mbstring \
    php-pear \
    php-xml \
    php-phar \
    php-zip

RUN docker-php-source extract \
    pecl install xdebug-3.1.5

RUN apk add git
RUN apk add --update nodejs npm

COPY php.ini /etc/php/7.4/php.ini
COPY php-fpm-pool.conf /etc/php/7.4/pool.d/www.conf

RUN mkdir -p docker/php/conf.d
COPY xdebug.ini docker/php/conf.d/xdebug.ini
COPY error_reporting.ini docker/php/conf.d/error_reporting.ini

RUN curl -sSk https://getcomposer.org/installer | php -- --disable-tls && \
   mv composer.phar /usr/local/bin/composer

RUN rm -rf /var/lib/apt/lists/*

WORKDIR /home/www/monarc

# RUN ["chmod", "+x", ".docker/php/install-app.sh"]

EXPOSE 9000
CMD ["php-fpm"]
