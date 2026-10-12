FROM python:3.12-slim-bookworm

# Environment variables required at runtime (with proposed defaults):
# ARG STATS_HOST=0.0.0.0
# ARG STATS_DB_USER=sqlmonarcuser
# ARG STATS_DB_PASSWORD=sqlmonarcuser
# ARG STATS_DB_HOST=postgres
# ARG STATS_DB_NAME=statsservice
# ARG STATS_SECRET_KEY
ARG STATS_PORT=5005

ENV DEBIAN_FRONTEND=noninteractive \
    LANGUAGE=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    HOME=/var/www/stats-service \
    POETRY_CACHE_DIR=/var/www/stats-service/.cache \
    POETRY_VIRTUALENVS_PATH=/var/www/stats-service/.cache/virtualenvs \
    POETRY_VIRTUALENVS_CREATE=false \
    PATH="/var/www/stats-service/.local/bin:$PATH"

# Install dependencies
RUN echo "deb [trusted=yes] http://apt.postgresql.org/pub/repos/apt bookworm-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    apt-get update && \
    apt-get -o Dpkg::Options::="--force-confdef" install --no-install-recommends -y \
        locales \
        curl \
        git \
        postgresql-client-16 \
        nodejs \
        npm \
        g++ && \
    sed -i "s/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN curl -sSL https://install.python-poetry.org | python3 -

# Fetch stats-service
RUN curl -sL https://github.com/monarc-project/stats-service/archive/refs/heads/master.tar.gz | tar --strip-components=1 -xz -C /var/www/stats-service/

# Copy project manifests and install dependencies
WORKDIR /var/www/stats-service
RUN poetry install --no-root --no-interaction --no-ansi

COPY monarc_health_app.py /var/www/stats-service/monarc_health_app.py
COPY production.py instance/production.py
COPY db_create_schema.py /var/www/stats-service/db_create_schema.py
COPY docker-stats-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN npm ci --engine-strict=false --loglevel=error
RUN poetry install --only=main

RUN useradd -m monarcuser -u 1001 -g 0
RUN chown 0:0 /var/www && chown -R 1001:0 /var/www/stats-service && chmod g+rw /var/www/stats-service

USER 1001

EXPOSE ${STATS_PORT}

ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]
CMD ["sh", "-c", "poetry run flask --app monarc_health_app.py run --host=${STATS_HOST} --port=${STATS_PORT}"]
