#!/bin/bash

mkdir -p nginx

cat <<EOF > nginx/nginx.conf
worker_processes auto;
events {
    worker_connections 1024;
}
http {
    server {
        listen 80;

        location /grafana/ {
            proxy_pass http://grafana:3000/;
            proxy_set_header Host \$host;
        }

        location /prometheus/ {
            proxy_pass http://prometheus:9090/;
            proxy_set_header Host \$host;
        }

        auth_basic "Restricted Content";
        auth_basic_user_file /etc/nginx/.htpasswd;
    }
}
EOF
