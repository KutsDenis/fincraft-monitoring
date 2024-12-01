#!/bin/bash

mkdir -p prometheus

targets=()

if [ -f .env ]; then
    while IFS='=' read -r key value; do
        if [[ "$key" == FINCRAFT_*_ADDRESS ]]; then
            targets+=("$value")
        fi
    done < .env
fi

if [ ${#targets[@]} -eq 0 ]; then
    echo "Error: No microservice address variables (FINCRAFT_*_ADDRESS) found. Check the .env file or environment variables."
    exit 1
fi

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
