FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV LANGUAGE=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Install system dependencies
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
    vim \
    zip \
    unzip \
    git \
    gettext \
    curl \
    gsfonts \
    apache2 \
    php8.1 \
    php8.1-cli \
    php8.1-common \
    php8.1-mysql \
    php8.1-zip \
    php8.1-gd \
    php8.1-mbstring \
    php8.1-curl \
    php8.1-xml \
    php8.1-bcmath \
    php8.1-intl \
    php8.1-imagick \
    php8.1-xdebug \
    locales \
    wget \
    ca-certificates \
    gnupg && \
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
RUN echo "zend_extension=xdebug.so" > /etc/php/8.1/apache2/conf.d/20-xdebug.ini && \
    echo "xdebug.mode=debug" >> /etc/php/8.1/apache2/conf.d/20-xdebug.ini && \
    echo "xdebug.discover_client_host=1" >> /etc/php/8.1/apache2/conf.d/20-xdebug.ini && \
    echo "xdebug.idekey=IDEKEY" >> /etc/php/8.1/apache2/conf.d/20-xdebug.ini

# Enable Apache modules
RUN a2enmod rewrite ssl headers

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Node.js and npm
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_15.x nodistro main" > /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y nodejs npm && \
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
CMD ["apache2-foreground"]
