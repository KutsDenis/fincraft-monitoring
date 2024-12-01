$NGINX_DIR = ".\nginx"
if (-Not (Test-Path $NGINX_DIR)) {
    New-Item -ItemType Directory -Path $NGINX_DIR
}

$CurrentDir = (Get-Location).Path
$HTPASSWD_FILE = "$NGINX_DIR\.htpasswd"

if (-Not (Test-Path $HTPASSWD_FILE)) {
    docker run --rm -v "${CurrentDir}\${NGINX_DIR}:/workdir" httpd:alpine htpasswd -cb /workdir/.htpasswd "admin" "password"
}
