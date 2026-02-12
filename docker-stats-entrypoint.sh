#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Starting MONARC Stats Service setup...${NC}"

write_health_wrapper() {
    cat > /var/www/stats-service/monarc_health_app.py <<'PY'
import importlib
import os
import pkgutil
import sys

from flask.cli import ScriptInfo

base_app = os.environ.get("STATS_BASE_APP") or "app"

info = ScriptInfo(app_import_path=base_app)
app = info.load_app()

try:
    import statsservice
    for _, modname, _ in pkgutil.walk_packages(statsservice.__path__, statsservice.__name__ + "."):
        try:
            importlib.import_module(modname)
        except Exception:
            pass
except Exception:
    pass

@app.get("/health")
def health():
    return {"status": "ok"}
PY
}

detect_flask_app() {
    if [ -f "/var/www/stats-service/app.py" ]; then
        echo "app.py"
        return 0
    fi
    if [ -f "/var/www/stats-service/runserver.py" ]; then
        echo "runserver.py"
        return 0
    fi
    if [ -f "/var/www/stats-service/statsservice/bootstrap.py" ]; then
        echo "statsservice.bootstrap"
        return 0
    fi
    return 1
}

ensure_flask_app() {
    local detected_app
    local flask_app_missing=0

    if [ -n "${FLASK_APP}" ]; then
        if [[ "${FLASK_APP}" == *.py ]]; then
            [ -f "/var/www/stats-service/${FLASK_APP}" ] || flask_app_missing=1
        else
            local module_path="/var/www/stats-service/${FLASK_APP//.//}.py"
            local module_dir="/var/www/stats-service/${FLASK_APP//.//}/__init__.py"
            if [ ! -f "${module_path}" ] && [ ! -f "${module_dir}" ]; then
                flask_app_missing=1
            fi
        fi
    fi

    if [ -z "${FLASK_APP}" ] || [ "${flask_app_missing}" -eq 1 ]; then
        detected_app=$(detect_flask_app || true)
        if [ -z "${detected_app}" ]; then
            echo -e "${YELLOW}Could not detect Flask app entrypoint. Check stats-service repo layout.${NC}"
            exit 1
        fi
        export FLASK_APP="${detected_app}"
        echo -e "${GREEN}Using FLASK_APP=${FLASK_APP}${NC}"
    fi

    BASE_FLASK_APP="${FLASK_APP}"
}

ensure_python_deps() {
    if ! poetry run python - <<'PY'
import importlib
import sys
try:
    importlib.import_module("flask")
except Exception:
    sys.exit(1)
PY
    then
        echo -e "${YELLOW}Installing Python dependencies with Poetry...${NC}"
        poetry install --only=main
    fi
}

write_instance_config() {
    echo -e "${YELLOW}Creating configuration...${NC}"
    mkdir -p instance
    STATS_INSTANCE_URL_VALUE="${STATS_INSTANCE_URL:-http://localhost:${STATS_PORT}}"
    cat > instance/production.py <<EOF
HOST = '${STATS_HOST}'
PORT = ${STATS_PORT}
DEBUG = False
TESTING = False
INSTANCE_URL = '${STATS_INSTANCE_URL_VALUE}'

ADMIN_EMAIL = 'info@nc3.lu'
ADMIN_URL = 'https://www.nc3.lu'

REMOTE_STATS_SERVER = 'https://dashboard.monarc.lu'

DB_CONFIG_DICT = {
    'user': '${STATS_DB_USER}',
    'password': '${STATS_DB_PASSWORD}',
    'host': '${STATS_DB_HOST}',
    'port': 5432,
}
DATABASE_NAME = '${STATS_DB_NAME}'
SQLALCHEMY_DATABASE_URI = 'postgresql://{user}:{password}@{host}:{port}/{name}'.format(
    name=DATABASE_NAME, **DB_CONFIG_DICT
)
SQLALCHEMY_TRACK_MODIFICATIONS = False

SECRET_KEY = '${STATS_SECRET_KEY}'

LOG_PATH = './var/stats.log'

MOSP_URL = 'https://objects.monarc.lu'
EOF
}

# Wait for PostgreSQL to be ready
echo -e "${YELLOW}Waiting for PostgreSQL to be ready...${NC}"
until PGPASSWORD=$STATS_DB_PASSWORD psql -h "$STATS_DB_HOST" -U "$STATS_DB_USER" -d postgres -c '\q' 2>/dev/null; do
    echo "Waiting for PostgreSQL..."
    sleep 2
done
echo -e "${GREEN}PostgreSQL is ready!${NC}"

# Check if this is the first run
if [ ! -f "/var/www/stats-service/.docker-initialized" ]; then
    echo -e "${GREEN}First run detected, initializing stats service...${NC}"
    
    # Clone the stats service repository
    if [ ! -d "/var/www/stats-service/.git" ]; then
        echo -e "${YELLOW}Cloning stats-service repository...${NC}"
        cd /var/www
        git clone https://github.com/monarc-project/stats-service stats-service-tmp
        cp -r stats-service-tmp/* stats-service/
        cp -r stats-service-tmp/.git stats-service/
        rm -rf stats-service-tmp
        cd /var/www/stats-service
    fi
    
    ensure_flask_app

    flask_has_command() {
        local cmd="$1"
        poetry run flask --app "${FLASK_APP}" --help 2>/dev/null | grep -qE "^[[:space:]]+${cmd}[[:space:]]"
    }

    run_flask() {
        poetry run flask --app "${FLASK_APP}" "$@"
    }

    run_db_upgrade() {
        run_flask db upgrade
    }

    run_db_stamp_head() {
        run_flask db stamp head
    }

    db_has_tables() {
        local count
        count=$(PGPASSWORD=$STATS_DB_PASSWORD psql -h "$STATS_DB_HOST" -U "$STATS_DB_USER" -d "$STATS_DB_NAME" -tAc "select count(*) from information_schema.tables where table_schema='public';" 2>/dev/null | tr -d '[:space:]')
        if [ -z "${count}" ]; then
            return 1
        fi
        [ "${count}" -gt 0 ]
    }

    create_schema_fallback() {
        echo -e "${YELLOW}Attempting SQLAlchemy create_all() fallback...${NC}"
        poetry run python - <<'PY'
import importlib
import os
import sys
import pkgutil

from flask.cli import ScriptInfo

app_path = os.environ.get("FLASK_APP")
if not app_path:
    print("FLASK_APP is not set; cannot load app.", file=sys.stderr)
    sys.exit(1)

info = ScriptInfo(app_import_path=app_path)
app = info.load_app()

with app.app_context():
    try:
        import statsservice
        for _, modname, _ in pkgutil.walk_packages(statsservice.__path__, statsservice.__name__ + "."):
            try:
                importlib.import_module(modname)
            except Exception:
                pass
    except Exception:
        for mod in (
            "statsservice.models",
            "statsservice.model",
            "statsservice.api.v1",
            "statsservice.api",
        ):
            try:
                importlib.import_module(mod)
            except Exception:
                pass

    ext = app.extensions.get("sqlalchemy")
    db = None
    if ext is not None:
        db = ext if hasattr(ext, "create_all") else getattr(ext, "db", None)
    if db is None:
        for mod in ("statsservice.extensions", "statsservice.models", "statsservice"):
            try:
                candidate = importlib.import_module(mod)
                if hasattr(candidate, "db"):
                    db = candidate.db
                    break
            except Exception:
                pass

    if db is None or not hasattr(db, "create_all"):
        print("Could not resolve SQLAlchemy db instance.", file=sys.stderr)
        sys.exit(1)

    db.create_all()
    print("Schema created via SQLAlchemy create_all().")
PY
    }

    # Install npm dependencies
    echo -e "${YELLOW}Installing npm dependencies...${NC}"
    npm ci

    ensure_python_deps
    
    write_instance_config
    
    # Initialize database
    echo -e "${YELLOW}Initializing database...${NC}"
    if flask_has_command "db_create"; then
        run_flask db_create
    fi

    if flask_has_command "db_init"; then
        run_flask db_init
    fi

    if flask_has_command "db"; then
        if ! db_has_tables; then
            if create_schema_fallback; then
                echo -e "${YELLOW}Empty database detected. Stamping head after create_all...${NC}"
                run_db_stamp_head
            else
                echo -e "${YELLOW}Schema fallback failed on empty database.${NC}"
                exit 1
            fi
        else
            if ! UPGRADE_OUT=$(run_db_upgrade 2>&1); then
                if echo "${UPGRADE_OUT}" | grep -q "DuplicateColumn"; then
                    echo -e "${YELLOW}Migration already applied (duplicate column). Stamping head...${NC}"
                    run_db_stamp_head
                elif create_schema_fallback; then
                    echo -e "${YELLOW}Schema created. Stamping head to match models...${NC}"
                    run_db_stamp_head
                else
                    echo -e "${YELLOW}Database upgrade failed and schema fallback failed.${NC}"
                    exit 1
                fi
            fi
        fi
    elif ! flask_has_command "db_create" && ! flask_has_command "db_init"; then
        echo -e "${YELLOW}No database init/create/upgrade command found in Flask CLI.${NC}"
    fi
    
    # Create admin client
    echo -e "${YELLOW}Creating admin client...${NC}"
    if flask_has_command "client_create"; then
        run_flask client_create --name ADMIN --role admin
        
        # Create client for MONARC and capture the API key
        echo -e "${YELLOW}Creating MONARC client...${NC}"
        run_flask client_create --name admin_localhost
    else
        echo -e "${YELLOW}No client_create command found in Flask CLI. Skipping client setup.${NC}"
    fi
    
    # Mark initialization as complete
    touch /var/www/stats-service/.docker-initialized
    echo -e "${GREEN}Stats service initialization complete!${NC}"
else
    echo -e "${GREEN}Stats service already initialized, starting...${NC}"
    cd /var/www/stats-service
    ensure_flask_app
    ensure_python_deps
    write_instance_config
fi

# Start the Flask application
write_health_wrapper
export STATS_BASE_APP="${BASE_FLASK_APP}"
export FLASK_APP="monarc_health_app.py"
echo -e "${GREEN}Starting Flask application on ${STATS_HOST}:${STATS_PORT}${NC}"
exec poetry run flask --app "${FLASK_APP}" run --host=${STATS_HOST} --port=${STATS_PORT}
