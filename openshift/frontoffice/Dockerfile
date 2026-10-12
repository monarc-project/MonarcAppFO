FROM debian:bookworm

ARG SMTP_HOST
ARG SMTP_FROM
ARG SMTP_DOMAIN

ENV DEBIAN_FRONTEND=noninteractive
ENV LANGUAGE=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Install system dependencies
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        vim zip unzip git gettext curl gsfonts mariadb-client apache2 php php-cli \
        php-common php-mysql php-zip php-gd php-mbstring php-curl php-xml \
        php-bcmath php-intl php-imagick locales wget ca-certificates gnupg \
        python3 pkg-config libcairo2-dev libpango1.0-dev libjpeg-dev libreoffice-writer \
        build-essential pango1.0-dev \
        libgif-dev librsvg2-dev libpixman-1-dev composer nodejs npm node-grunt-cli \
        msmtp msmtp-mta mailutils netcat-openbsd; \
    sed "s/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" -i /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /etc/apt/auth.conf /etc/apt/sources.list.d/*

# Configure PHP
RUN sed -i 's/upload_max_filesize = .*/upload_max_filesize = 200M/' /etc/php/*/apache2/php.ini && \
    sed -i 's/post_max_size = .*/post_max_size = 50M/' /etc/php/*/apache2/php.ini && \
    sed -i 's/max_execution_time = .*/max_execution_time = 100/' /etc/php/*/apache2/php.ini && \
    sed -i 's/max_input_time = .*/max_input_time = 223/' /etc/php/*/apache2/php.ini && \
    sed -i 's/memory_limit = .*/memory_limit = 512M/' /etc/php/*/apache2/php.ini && \
    sed -i 's/session\.gc_maxlifetime = .*/session.gc_maxlifetime = 604800/' /etc/php/*/apache2/php.ini && \
    sed -i 's/session\.gc_probability = .*/session.gc_probability = 1/' /etc/php/*/apache2/php.ini && \
    sed -i 's/session\.gc_divisor = .*/session.gc_divisor = 1000/' /etc/php/*/apache2/php.ini

# Enable Apache modules
RUN a2enmod rewrite ssl headers

# Set global ServerName to avoid AH00558 warning
RUN echo "ServerName localhost" > /etc/apache2/conf-available/servername.conf \
    && a2enconf servername

# Set working directory
WORKDIR /var/www/html/monarc

# Configure Apache
COPY 000-default.conf /etc/apache2/sites-available/000-default.conf
COPY local.php config/autoload/local.php
COPY ports.conf /etc/apache2/ports.conf

# Allow Apache override to all
RUN sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf

# Create necessary directories
RUN mkdir -p /var/www/html/monarc/data/cache \
    /var/www/html/monarc/data/LazyServices/Proxy \
    /var/www/html/monarc/data/DoctrineORMModule/Proxy \
    /var/www/html/monarc/data/import/files \
    /var/www/html/monarc/public/captcha

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/

# Copy fully prepared application source into the image.
# The workflow pre-build step ensures vendor/node_modules/resources are already ready.
COPY --from=monarcdir . /var/www/html/monarc
RUN chown -R www-data:0 /var/www/html/monarc
RUN mkdir -p /var/run/apache2 && chown 0:0 /var/run/apache2 -R && chmod a+rw /var/run/apache2 && chmod +x /var/run/apache2

USER www-data
RUN COMPOSER_ALLOW_SUPERUSER=1 composer install --ignore-platform-req=php --no-interaction
RUN mkdir -p module/Monarc node_modules/ng_anr node_modules/ng_client; cd module/Monarc; ln -sfn ./../../vendor/monarc/core Core; ln -sfn ./../../vendor/monarc/frontoffice FrontOffice
RUN curl -sL https://github.com/monarc-project/ng-client/archive/refs/tags/v2.14.2.tar.gz | tar --strip-components=1 -xz -C /var/www/html/monarc/node_modules/ng_client/
RUN curl -sL https://github.com/monarc-project/ng-anr/archive/refs/tags/v2.14.2.tar.gz | tar --strip-components=1 -xz -C /var/www/html/monarc/node_modules/ng_anr/

USER root
RUN /var/www/html/monarc/scripts/update-all.sh -b -c
RUN chown -R www-data:0 /var/www/html/monarc && chown -R 0:0 /var/log/apache2 && chmod -R ug+rw /var/www/html/monarc && chmod -R a+rw /var/log/apache2 && chmod a+x /var/log/apache2

# Copy configuration template and make it world-readable/writable for OpenShift UID
COPY msmtprc /etc/msmtprc
RUN sed -i "s/SMTP_HOST/$SMTP_HOST/g; s/SMTP_FROM/$SMTP_FROM/g; s/SMTP_DOMAIN/$SMTP_DOMAIN/g" /etc/msmtprc && \
    chmod 0666 /etc/msmtprc

EXPOSE 8080

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["apachectl", "-D", "FOREGROUND"]
