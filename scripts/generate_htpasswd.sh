#!/bin/bash

NGINX_DIR="./nginx"
HTPASSWD_FILE="$NGINX_DIR/.htpasswd"

mkdir -p "$NGINX_DIR"

if [ ! -f "$HTPASSWD_FILE" ]; then
  docker run --rm -v "$(pwd)/$NGINX_DIR:/workdir" httpd:alpine htpasswd -cb /workdir/.htpasswd admin password
fi
