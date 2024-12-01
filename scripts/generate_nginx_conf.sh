#!/bin/bash

mkdir -p nginx

cat <<'EOF' > nginx/nginx.conf
worker_processes auto;
events {
    worker_connections 1024;
}
http {
    server {
        listen 80;

        location /prometheus/ {
            rewrite ^/prometheus(/.*)$ $1 break;
            proxy_pass http://prometheus:9090;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";

            sub_filter_once off;
            sub_filter 'href="/' 'href="/prometheus/';
            sub_filter 'src="/' 'src="/prometheus/';
            sub_filter 'action="/' 'action="/prometheus/';
            proxy_set_header Accept-Encoding "";

            proxy_redirect / /prometheus/;
        }

        auth_basic "Restricted Content";
        auth_basic_user_file /etc/nginx/.htpasswd;
    }
}
EOF
