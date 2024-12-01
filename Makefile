# Переменные
DOCKER_COMPOSE = docker-compose
PROMETHEUS_DIR = prometheus
NGINX_DIR = nginx
HTPASSWD_FILE = $(NGINX_DIR)/.htpasswd
NGINX_CONF_FILE = $(NGINX_DIR)/nginx.conf
PROMETHEUS_CONF_FILE = $(PROMETHEUS_DIR)/prometheus.yml
ENV_FILE = .env

# Команды
.PHONY: init setup start stop restart clean logs

init: setup start

setup: $(PROMETHEUS_CONF_FILE) $(NGINX_CONF_FILE) $(HTPASSWD_FILE)

$(HTPASSWD_FILE): scripts/generate_htpasswd.sh
ifeq ($(OS),Windows_NT)
	@powershell -ExecutionPolicy Bypass -File scripts/generate_htpasswd.ps1
else
	@sh scripts/generate_htpasswd.sh
endif

$(NGINX_CONF_FILE): scripts/generate_nginx_conf.ps1
ifeq ($(OS),Windows_NT)
	@powershell -ExecutionPolicy Bypass -File scripts/generate_nginx_conf.ps1
else
	@sh scripts/generate_nginx_conf.sh
endif

$(PROMETHEUS_CONF_FILE): scripts/generate_prometheus_config.ps1
ifeq ($(OS),Windows_NT)
	@powershell -ExecutionPolicy Bypass -File scripts/generate_prometheus_config.ps1
else
	@sh scripts/generate_prometheus_config.sh
endif

start:
	@$(DOCKER_COMPOSE) up -d

stop:
	@$(DOCKER_COMPOSE) down

restart: stop start

clean: stop
ifeq ($(OS),Windows_NT)
	@if exist "$(PROMETHEUS_DIR)" rmdir /s /q "$(PROMETHEUS_DIR)"
	@if exist "$(NGINX_DIR)" rmdir /s /q "$(NGINX_DIR)"
else
	@rm -rf "$(PROMETHEUS_DIR)" "$(NGINX_DIR)"
endif

logs:
	@$(DOCKER_COMPOSE) logs -f
