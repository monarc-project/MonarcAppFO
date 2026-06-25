FROM ubuntu:22.04

ARG XDEBUG_ENABLED=1
ARG XDEBUG_MODE=debug
ARG XDEBUG_START_WITH_REQUEST=trigger
ARG XDEBUG_CLIENT_HOST=host.docker.internal
ARG XDEBUG_CLIENT_PORT=9003
ARG XDEBUG_IDEKEY=IDEKEY
ARG XDEBUG_DISCOVER_CLIENT_HOST=0
ARG NODE_MAJOR=16

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV LANGUAGE=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Install system dependencies
RUN apt-get update && apt-get upgrade -y && \
    packages="vim zip unzip git gettext curl gsfonts mariadb-client apache2 php8.1 php8.1-cli \
    php8.1-common php8.1-mysql php8.1-zip php8.1-gd php8.1-mbstring php8.1-curl php8.1-xml \
    php8.1-bcmath php8.1-intl php8.1-imagick locales wget ca-certificates gnupg \
    build-essential python3 pkg-config libcairo2-dev libpango1.0-dev libjpeg-dev \
    libgif-dev librsvg2-dev libpixman-1-dev"; \
    if [ "$XDEBUG_ENABLED" = "1" ] || [ "$XDEBUG_ENABLED" = "true" ] || [ "$XDEBUG_ENABLED" = "yes" ]; then \
        packages="$packages php8.1-xdebug"; \
    fi; \
    apt-get install -y $packages && \
    locale-gen en_US.UTF-8 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configure PHP
RUN sed -i 's/upload_max_filesize = .*/upload_max_filesize = 200M/' /etc/php/8.1/apache2/php.ini && \
    sed -i 's/post_max_size = .*/post_max_size = 50M/' /etc/php/8.1/apache2/php.ini && \
    sed -i 's/max_execution_time = .*/max_execution_time = 100/' /etc/php/8.1/apache2/php.ini && \
    sed -i 's/max_input_time = .*/max_input_time = 223/' /etc/php/8.1/apache2/php.ini && \
    sed -i 's/memory_limit = .*/memory_limit = 512M/' /etc/php/8.1/apache2/php.ini && \
    sed -i 's/session\.gc_maxlifetime = .*/session.gc_maxlifetime = 604800/' /etc/php/8.1/apache2/php.ini && \
    sed -i 's/session\.gc_probability = .*/session.gc_probability = 1/' /etc/php/8.1/apache2/php.ini && \
    sed -i 's/session\.gc_divisor = .*/session.gc_divisor = 1000/' /etc/php/8.1/apache2/php.ini

# Configure Xdebug for development
RUN if [ "$XDEBUG_ENABLED" = "1" ] || [ "$XDEBUG_ENABLED" = "true" ] || [ "$XDEBUG_ENABLED" = "yes" ]; then \
        echo "zend_extension=xdebug.so" > /etc/php/8.1/apache2/conf.d/20-xdebug.ini && \
        echo "xdebug.mode=${XDEBUG_MODE}" >> /etc/php/8.1/apache2/conf.d/20-xdebug.ini && \
        echo "xdebug.start_with_request=${XDEBUG_START_WITH_REQUEST}" >> /etc/php/8.1/apache2/conf.d/20-xdebug.ini && \
        echo "xdebug.client_host=${XDEBUG_CLIENT_HOST}" >> /etc/php/8.1/apache2/conf.d/20-xdebug.ini && \
        echo "xdebug.client_port=${XDEBUG_CLIENT_PORT}" >> /etc/php/8.1/apache2/conf.d/20-xdebug.ini && \
        echo "xdebug.discover_client_host=${XDEBUG_DISCOVER_CLIENT_HOST}" >> /etc/php/8.1/apache2/conf.d/20-xdebug.ini && \
        echo "xdebug.idekey=${XDEBUG_IDEKEY}" >> /etc/php/8.1/apache2/conf.d/20-xdebug.ini; \
    fi

# Enable Apache modules
RUN a2enmod rewrite ssl headers

# Set global ServerName to avoid AH00558 warning
RUN echo "ServerName localhost" > /etc/apache2/conf-available/servername.conf \
    && a2enconf servername

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Node.js and npm
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" > /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y nodejs && \
    npm install -g grunt-cli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /var/www/html/monarc

# Configure Apache
RUN echo '<VirtualHost *:80>\n\
    ServerName localhost\n\
    DocumentRoot /var/www/html/monarc/public\n\
\n\
    <Directory /var/www/html/monarc/public>\n\
        DirectoryIndex index.php\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
\n\
    <IfModule mod_headers.c>\n\
       Header always set X-Content-Type-Options nosniff\n\
       Header always set X-XSS-Protection "1; mode=block"\n\
       Header always set X-Robots-Tag none\n\
       Header always set X-Frame-Options SAMEORIGIN\n\
    </IfModule>\n\
\n\
    SetEnv APP_ENV development\n\
    SetEnv APP_DIR /var/www/html/monarc\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# Allow Apache override to all
RUN sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf

# Create necessary directories
RUN mkdir -p /var/www/html/monarc/data/cache \
    /var/www/html/monarc/data/LazyServices/Proxy \
    /var/www/html/monarc/data/DoctrineORMModule/Proxy \
    /var/www/html/monarc/data/import/files

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 80

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apachectl", "-D", "FOREGROUND"]
