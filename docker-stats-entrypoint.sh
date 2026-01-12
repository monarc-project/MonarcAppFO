#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Starting MONARC Stats Service setup...${NC}"

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
    
    # Install npm dependencies
    echo -e "${YELLOW}Installing npm dependencies...${NC}"
    npm ci
    
    # Install Python dependencies with Poetry
    echo -e "${YELLOW}Installing Python dependencies with Poetry...${NC}"
    poetry install --no-dev
    
    # Create instance directory and configuration
    echo -e "${YELLOW}Creating configuration...${NC}"
    mkdir -p instance
    cat > instance/production.py <<EOF
HOST = '${STATS_HOST}'
PORT = ${STATS_PORT}
DEBUG = False
TESTING = False
INSTANCE_URL = 'http://stats-service:${STATS_PORT}'

ADMIN_EMAIL = 'info@cases.lu'
ADMIN_URL = 'https://www.cases.lu'

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
    
    # Initialize database
    echo -e "${YELLOW}Initializing database...${NC}"
    poetry run flask db_create
    poetry run flask db_init
    
    # Create admin client
    echo -e "${YELLOW}Creating admin client...${NC}"
    poetry run flask client_create --name ADMIN --role admin
    
    # Create client for MONARC and capture the API key
    echo -e "${YELLOW}Creating MONARC client...${NC}"
    poetry run flask client_create --name admin_localhost | tee /tmp/client_output.txt
    
    # Mark initialization as complete
    touch /var/www/stats-service/.docker-initialized
    echo -e "${GREEN}Stats service initialization complete!${NC}"
else
    echo -e "${GREEN}Stats service already initialized, starting...${NC}"
fi

# Start the Flask application
echo -e "${GREEN}Starting Flask application on ${STATS_HOST}:${STATS_PORT}${NC}"
exec poetry run flask run --host=${STATS_HOST} --port=${STATS_PORT}
