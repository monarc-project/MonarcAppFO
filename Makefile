.DEFAULT_GOAL := help

SHELL := /bin/bash

ENV ?= dev
COMPOSE_FILE ?= docker-compose.$(ENV).yml
COMPOSE := docker compose -f $(COMPOSE_FILE)

GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m

.PHONY: help check-env start stop restart logs logs-app logs-stats shell shell-stats db reset status stats-key

help:
	@printf "%b\n" "$(GREEN)MONARC FrontOffice Docker Development Environment Manager$(NC)"
	@printf "\n%b\n" "Usage: make <command>"
	@printf "%b\n" "Environment: ENV=<name> (default: dev, uses docker-compose.<name>.yml)"
	@printf "\n%b\n" "Commands:"
	@printf "  %-12s %s\n" "start" "Start all services (builds on first run)"
	@printf "  %-12s %s\n" "stop" "Stop all services"
	@printf "  %-12s %s\n" "restart" "Restart all services"
	@printf "  %-12s %s\n" "logs" "View logs from all services"
	@printf "  %-12s %s\n" "logs-app" "View logs from MONARC application"
	@printf "  %-12s %s\n" "logs-stats" "View logs from stats service"
	@printf "  %-12s %s\n" "shell" "Open a shell in the MONARC container"
	@printf "  %-12s %s\n" "shell-stats" "Open a shell in the stats service container"
	@printf "  %-12s %s\n" "db" "Open MySQL client in the database"
	@printf "  %-12s %s\n" "stats-key" "Show the stats API key"
	@printf "  %-12s %s\n" "reset" "Reset everything (removes all data)"
	@printf "  %-12s %s\n" "status" "Show status of all services"

check-env:
	@if [ ! -f .env ]; then \
		printf "%b\n" "$(YELLOW)No .env file found. Creating from .env.dev...$(NC)"; \
		cp .env.dev .env; \
		printf "%b\n" "$(GREEN).env file created. You can edit it to customize configuration.$(NC)"; \
	fi

start: check-env
	@printf "%b\n" "$(GREEN)Starting MONARC FrontOffice development environment...$(NC)"
	@$(COMPOSE) up -d --build
	@printf "%b\n" "$(GREEN)Services started!$(NC)"
	@printf "%b\n" "MONARC FrontOffice: http://localhost:5001"
	@printf "%b\n" "Stats Service: http://localhost:5005"
	@printf "%b\n" "MailCatcher: http://localhost:1080"
	@printf "\n%b\n" "$(YELLOW)To view logs: make logs ENV=$(ENV)$(NC)"

stop:
	@printf "%b\n" "$(YELLOW)Stopping all services...$(NC)"
	@$(COMPOSE) stop
	@printf "%b\n" "$(GREEN)Services stopped.$(NC)"

restart:
	@printf "%b\n" "$(YELLOW)Restarting all services...$(NC)"
	@$(COMPOSE) restart
	@printf "%b\n" "$(GREEN)Services restarted.$(NC)"

logs:
	@$(COMPOSE) logs -f

logs-app:
	@$(COMPOSE) logs -f monarc

logs-stats:
	@$(COMPOSE) logs -f stats-service

shell:
	@printf "%b\n" "$(GREEN)Opening shell in MONARC container...$(NC)"
	@docker exec -it monarc-fo-app bash

shell-stats:
	@printf "%b\n" "$(GREEN)Opening shell in stats service container...$(NC)"
	@docker exec -it monarc-fo-stats bash

db:
	@printf "%b\n" "$(GREEN)Opening MySQL client...$(NC)"
	@if [ -f .env ]; then \
		export $$(grep -v '^#' .env | xargs); \
	fi; \
	export MYSQL_PWD="$${DBPASSWORD_MONARC:-sqlmonarcuser}"; \
	docker exec -it monarc-fo-db mysql -u"$${DBUSER_MONARC:-sqlmonarcuser}" "$${DBNAME_COMMON:-monarc_common}"

stats-key:
	@printf "%b\n" "$(GREEN)Retrieving stats API key...$(NC)"
	@$(COMPOSE) logs stats-service | grep "Token:" | tail -1
	@printf "\n%b\n" "$(YELLOW)Note: Update this key in your .env file and restart MONARC service:$(NC)"
	@printf "%b\n" "  1. Edit .env and set STATS_API_KEY=<key>"
	@printf "%b\n" "  2. Run: docker compose -f \"$(COMPOSE_FILE)\" restart monarc"

reset:
	@printf "%b\n" "$(RED)WARNING: This will remove all data!$(NC)"; \
	read -p "Are you sure? (yes/no): " confirm; \
	if [ "$$confirm" = "yes" ]; then \
		printf "%b\n" "$(YELLOW)Stopping and removing all containers, volumes, and data...$(NC)"; \
		$(COMPOSE) down -v; \
		printf "%b\n" "$(GREEN)Reset complete. Run 'make start' to start fresh.$(NC)"; \
	else \
		printf "%b\n" "$(GREEN)Reset cancelled.$(NC)"; \
	fi

status:
	@$(COMPOSE) ps
