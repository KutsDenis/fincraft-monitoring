#!/bin/bash

NGINX_DIR="./nginx"
HTPASSWD_FILE="$NGINX_DIR/.htpasswd"

mkdir -p "$NGINX_DIR"

if [ -z "$PROMETHEUS_USER" ] || [ -z "$PROMETHEUS_PASS" ]; then
  if [ -f ".env" ]; then
    while IFS='=' read -r key value; do
      if [[ $key != \#* && -n $key ]]; then
        export "$key=$value"
      fi
    done < .env
  else
    echo "Error: PROMETHEUS_USER or PROMETHEUS_PASS is not set and .env file is missing"
    exit 1
  fi
fi

if [ ! -f "$HTPASSWD_FILE" ]; then
  docker run --rm -v "$(pwd)/$NGINX_DIR:/workdir" httpd:alpine htpasswd -cb /workdir/.htpasswd "$PROMETHEUS_USER" "$PROMETHEUS_PASS"
fi
