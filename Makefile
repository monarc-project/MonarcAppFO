.DEFAULT_GOAL := help

SHELL := /bin/bash

ENV ?= dev
COMPOSE_FILE ?= docker-compose.$(ENV).yml
COMPOSE := docker compose -f $(COMPOSE_FILE)

GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m

.PHONY: help check-env check-sibling-repos start local-repos remote-repos repo-status stop restart logs logs-app logs-stats shell shell-stats db migrate reset status stats-key

help:
	@printf "%b\n" "$(GREEN)MONARC FrontOffice Docker Development Environment Manager$(NC)"
	@printf "\n%b\n" "Usage: make <command>"
	@printf "%b\n" "Environment: ENV=<name> (default: dev, uses docker-compose.<name>.yml)"
	@printf "\n%b\n" "Commands:"
	@printf "  %-12s %s\n" "start" "Start all services (builds on first run)"
	@printf "  %-12s %s\n" "local-repos" "Start and use the mounted sibling repositories"
	@printf "  %-12s %s\n" "local-php-repos" "Use mounted PHP repositories without changing frontend dependencies"
	@printf "  %-12s %s\n" "remote-repos" "Use release backend packages and cloned frontends"
	@printf "  %-12s %s\n" "repo-status" "Show whether local or remote sources are active"
	@printf "  %-12s %s\n" "stop" "Stop all services"
	@printf "  %-12s %s\n" "restart" "Restart all services"
	@printf "  %-12s %s\n" "logs" "View logs from all services"
	@printf "  %-12s %s\n" "logs-app" "View logs from MONARC application"
	@printf "  %-12s %s\n" "logs-stats" "View logs from stats service"
	@printf "  %-12s %s\n" "shell" "Open a shell in the MONARC container"
	@printf "  %-12s %s\n" "shell-stats" "Open a shell in the stats service container"
	@printf "  %-12s %s\n" "db" "Open MySQL client in the database"
	@printf "  %-12s %s\n" "migrate" "Run Core and FrontOffice DB migrations in the app container"
	@printf "  %-12s %s\n" "stats-key" "Show the stats API key"
	@printf "  %-12s %s\n" "reset" "Reset everything (removes all data)"
	@printf "  %-12s %s\n" "status" "Show status of all services"

check-env:
	@if [ ! -f .env ]; then \
		printf "%b\n" "$(YELLOW)No .env file found. Creating from .env.dev...$(NC)"; \
		cp .env.dev .env; \
		printf "%b\n" "$(GREEN).env file created. You can edit it to customize configuration.$(NC)"; \
	fi

check-sibling-repos:
	@for repo in zm-core zm-client ng-anr ng-client; do \
		if [ ! -d "../$$repo" ]; then \
			printf "%b\\n" "$(RED)Missing required sibling repository: ../$$repo$(NC)"; \
			exit 1; \
		fi; \
	done

start: check-env check-sibling-repos
	@printf "%b\n" "$(GREEN)Starting MONARC FrontOffice development environment...$(NC)"
	@$(COMPOSE) up -d --build
	@printf "%b\n" "$(GREEN)Services started!$(NC)"
	@binding=$$($(COMPOSE) port monarcfoapp 80) && printf "%b\n" "MONARC FrontOffice: http://localhost:$${binding##*:}"
	@binding=$$($(COMPOSE) port stats-service 5005) && printf "%b\n" "Stats Service: http://localhost:$${binding##*:}"
	@binding=$$($(COMPOSE) port mailcatcher 1080) && printf "%b\n" "MailCatcher: http://localhost:$${binding##*:}"
	@printf "\n%b\n" "$(YELLOW)To view logs: make logs ENV=$(ENV)$(NC)"

local-repos: start
	@./scripts/switch_repo_sources.sh local

local-php-repos: start
	@./scripts/switch_repo_sources.sh local-php

remote-repos: check-env
	@./scripts/switch_repo_sources.sh remote

repo-status: check-env
	@./scripts/switch_repo_sources.sh status

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
	@$(COMPOSE) logs -f monarcfoapp

logs-stats:
	@$(COMPOSE) logs -f stats-service

shell:
	@printf "%b\n" "$(GREEN)Opening shell in MONARC container...$(NC)"
	@$(COMPOSE) exec monarcfoapp bash

shell-stats:
	@printf "%b\n" "$(GREEN)Opening shell in stats service container...$(NC)"
	@$(COMPOSE) exec stats-service bash

db:
	@printf "%b\n" "$(GREEN)Opening MySQL client...$(NC)"
	@$(COMPOSE) exec fodb sh -c 'MYSQL_PWD="$$MYSQL_PASSWORD" exec mysql -u"$$MYSQL_USER" "$$MYSQL_DATABASE"'

migrate: check-env
	@printf "%b\n" "$(GREEN)Running Core and FrontOffice DB migrations...$(NC)"
	@$(COMPOSE) exec -T monarcfoapp bash -lc "./scripts/upgrade-db.sh"
	@printf "%b\n" "$(GREEN)Migrations completed.$(NC)"

stats-key:
	@printf "%b\n" "$(GREEN)Retrieving stats API key...$(NC)"
	@$(COMPOSE) logs stats-service | grep "Token:" | tail -1
	@printf "\n%b\n" "$(YELLOW)Note: Update this key in your .env file and restart MONARC service:$(NC)"
	@printf "%b\n" "  1. Edit .env and set STATS_API_KEY=<key>"
	@printf "%b\n" "  2. Run: docker compose -f \"$(COMPOSE_FILE)\" up -d --no-deps monarcfoapp"

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
