#!/bin/bash
# Helper script for managing MONARC Docker development environment

set -e

COMPOSE_FILE="docker-compose.dev.yml"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

usage() {
    echo -e "${GREEN}MONARC Docker Development Environment Manager${NC}"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  start         Start all services (builds on first run)"
    echo "  stop          Stop all services"
    echo "  restart       Restart all services"
    echo "  logs          View logs from all services"
    echo "  logs-app      View logs from MONARC application"
    echo "  logs-stats    View logs from stats service"
    echo "  shell         Open a shell in the MONARC container"
    echo "  shell-stats   Open a shell in the stats service container"
    echo "  db            Open MySQL client in the database"
    echo "  reset         Reset everything (removes all data)"
    echo "  status        Show status of all services"
    echo "  stats-key     Show the stats API key"
    echo ""
}

check_env() {
    if [ ! -f .env ]; then
        echo -e "${YELLOW}No .env file found. Creating from .env.dev...${NC}"
        cp .env.dev .env
        echo -e "${GREEN}.env file created. You can edit it to customize configuration.${NC}"
    fi
}

case "$1" in
    start)
        check_env
        echo -e "${GREEN}Starting MONARC development environment...${NC}"
        docker compose -f "$COMPOSE_FILE" up -d --build
        echo -e "${GREEN}Services started!${NC}"
        echo -e "MONARC FrontOffice: http://localhost:5001"
        echo -e "Stats Service: http://localhost:5005"
        echo -e "MailCatcher: http://localhost:1080"
        echo -e "\n${YELLOW}To view logs: $0 logs${NC}"
        ;;
    
    stop)
        echo -e "${YELLOW}Stopping all services...${NC}"
        docker compose -f "$COMPOSE_FILE" stop
        echo -e "${GREEN}Services stopped.${NC}"
        ;;
    
    restart)
        echo -e "${YELLOW}Restarting all services...${NC}"
        docker compose -f "$COMPOSE_FILE" restart
        echo -e "${GREEN}Services restarted.${NC}"
        ;;
    
    logs)
        docker compose -f "$COMPOSE_FILE" logs -f
        ;;
    
    logs-app)
        docker compose -f "$COMPOSE_FILE" logs -f monarc
        ;;
    
    logs-stats)
        docker compose -f "$COMPOSE_FILE" logs -f stats-service
        ;;
    
    shell)
        echo -e "${GREEN}Opening shell in MONARC container...${NC}"
        docker exec -it monarc-fo-app bash
        ;;
    
    shell-stats)
        echo -e "${GREEN}Opening shell in stats service container...${NC}"
        docker exec -it monarc-fo-stats bash
        ;;
    
    db)
        echo -e "${GREEN}Opening MySQL client...${NC}"
        docker exec -it monarc-fo-db mysql -usqlmonarcuser -psqlmonarcuser monarc_common
        ;;
    
    reset)
        echo -e "${RED}WARNING: This will remove all data!${NC}"
        read -p "Are you sure? (yes/no): " confirm
        if [ "$confirm" = "yes" ]; then
            echo -e "${YELLOW}Stopping and removing all containers, volumes, and data...${NC}"
            docker compose -f "$COMPOSE_FILE" down -v
            echo -e "${GREEN}Reset complete. Run '$0 start' to start fresh.${NC}"
        else
            echo -e "${GREEN}Reset cancelled.${NC}"
        fi
        ;;
    
    status)
        docker compose -f "$COMPOSE_FILE" ps
        ;;
    
    stats-key)
        echo -e "${GREEN}Retrieving stats API key...${NC}"
        docker compose -f "$COMPOSE_FILE" logs stats-service | grep "Token:" | tail -1
        echo -e "\n${YELLOW}Note: Update this key in your .env file and restart MONARC service:${NC}"
        echo -e "  1. Edit .env and set STATS_API_KEY=<key>"
        echo -e "  2. Run: docker compose -f \"\$COMPOSE_FILE\" restart monarc"
        ;;
    
    *)
        usage
        exit 1
        ;;
esac
