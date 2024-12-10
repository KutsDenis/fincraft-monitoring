#!/bin/bash

# Создаём директорию для конфигов prometheus
mkdir -p prometheus

# Проверяем, есть ли файл .env
if [ ! -f .env ]; then
    echo "Error: Файл .env не найден."
    exit 1
fi

# Подгружаем переменные окружения из .env
# Благодаря set -o allexport все переменные из файла будут экспортированы в окружение
set -o allexport
source .env
set +o allexport

targets=()

# Перебираем все переменные окружения и ищем те, которые подходят под шаблон FINCRAFT_*_ADDRESS
for var in $(env | grep -E '^FINCRAFT_.*_ADDRESS=' | cut -d '=' -f1); do
    targets+=("${!var}")
done

# Проверяем, найдены ли какие-либо адреса
if [ ${#targets[@]} -eq 0 ]; then
    echo "Error: Не найдены переменные окружения FINCRAFT_*_ADDRESS. Проверьте файл .env или переменные окружения."
    exit 1
fi

# Создаём конфиг для prometheus
cat <<EOF > prometheus/prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: prometheus
    static_configs:
      - targets: [localhost:9090]

  - job_name: fincraft-services
    static_configs:
      - targets: [$(IFS=,; echo "${targets[*]}")]
EOF