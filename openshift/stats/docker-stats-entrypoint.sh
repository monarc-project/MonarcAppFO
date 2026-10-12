#!/bin/sh
set -e

# OpenShift Guardrail: Assign an explicit HOME directory inside /tmp 
# since random UIDs will not have a writeable native /root directory.
export HOME=/tmp
export PYTHONUSERBASE=/tmp/.local
export STATS_BASE_APP="app.py"
export FLASK_APP="${STATS_BASE_APP}"

# Environment variables required at runtime (with proposed defaults):
[ -z "${STATS_HOST}" ] && STATS_HOST=0.0.0.0
[ -z "${STATS_PORT}" ] && STATS_PORT=5005
[ -z "${STATS_DB_USER}" ] && STATS_DB_USER=sqlmonarcuser
[ -z "${STATS_DB_PASSWORD}" ] && STATS_DB_PASSWORD=sqlmonarcuser
[ -z "${STATS_DB_HOST}" ] && STATS_DB_HOST=postgres
[ -z "${STATS_DB_NAME}" ] && STATS_DB_NAME=statsservice
[ -z "${STATS_SECRET_KEY}" ] && STATS_SECRET_KEY=$(openssl rand -hex 32)
[ -z "${STATS_INSTANCE_URL}" ] && STATS_INSTANCE_URL=http://${STATS_DB_HOST}:${STATS_PORT}
[ -z "${ENVIRONMENT}" ] && ENVIRONMENT=production

export STATS_HOST STATS_PORT STATS_DB_USER STATS_DB_PASSWORD STATS_DB_HOST STATS_DB_NAME STATS_SECRET_KEY STATS_INSTANCE_URL ENVIRONMENT

run_flask() {
    poetry run flask --app "${FLASK_APP}" "$@"
}

db_has_tables() {
    local count
    count=$(PGPASSWORD=$STATS_DB_PASSWORD psql -h "$STATS_DB_HOST" -U "$STATS_DB_USER" -d "$STATS_DB_NAME" -tAc "select count(*) from information_schema.tables where table_schema='public';" 2>/dev/null | tr -d '[:space:]')
    [ "${count:-0}" -gt 0 ]
}

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
until PGPASSWORD=$STATS_DB_PASSWORD psql -h "$STATS_DB_HOST" -U "$STATS_DB_USER" -d postgres -c '\q' 2>/dev/null; do
    echo "Waiting for PostgreSQL..."
    sleep 2
done
echo "PostgreSQL is ready!"

echo "Initializing MONARC Stats Service..."

run_flask db_create
run_flask db_init

# Handle Database Triage/Migrations safely at startup
# (This runs completely offline matching the built-in image state)
if ! db_has_tables; then
    if poetry run python db_create_schema.py; then
        echo "Empty database detected. Stamping head after create_all..."
        run_flask db stamp head
    else
        echo "Schema fallback failed on empty database."
        exit 1
    fi
    run_flask client_create --name $STATS_DB_USER --role admin
    
    # Create client for MONARC and capture the API key
    echo "Creating MONARC client..."
    run_flask client_create --name admin_localhost

    echo "Initializing DB..."
    poetry run flask db_create
    poetry run flask db_init
    poetry run flask client_create --name $STATS_DB_USER --token $STATS_SECRET_KEY

    echo "Stats service initialization complete!"
fi

# Handoff execution cleanly to the primary container process
echo "Starting Application Layer..."
exec "$@"
