$NGINX_DIR = ".\nginx"
if (-Not (Test-Path $NGINX_DIR)) {
    New-Item -ItemType Directory -Path $NGINX_DIR
}

$CurrentDir = (Get-Location).Path
$HTPASSWD_FILE = "$NGINX_DIR\.htpasswd"

$EnvFile = ".\.env"
if (-Not [string]::IsNullOrEmpty([System.Environment]::GetEnvironmentVariable("PROMETHEUS_USER")) -and `
    -Not [string]::IsNullOrEmpty([System.Environment]::GetEnvironmentVariable("PROMETHEUS_PASS"))) {
    $PrometheusUser = [System.Environment]::GetEnvironmentVariable("PROMETHEUS_USER")
    $PrometheusPass = [System.Environment]::GetEnvironmentVariable("PROMETHEUS_PASS")
} elseif (Test-Path $EnvFile) {
    Get-Content $EnvFile | ForEach-Object {
        $parts = $_ -split "="
        if ($parts.Length -eq 2) {
            [System.Environment]::SetEnvironmentVariable($parts[0], $parts[1])
        }
    }
    $PrometheusUser = [System.Environment]::GetEnvironmentVariable("PROMETHEUS_USER")
    $PrometheusPass = [System.Environment]::GetEnvironmentVariable("PROMETHEUS_PASS")
} else {
    Write-Output "Error: PROMETHEUS_USER or PROMETHEUS_PASS is not set and .env file is missing"
    exit 1
}

if (-Not (Test-Path $HTPASSWD_FILE)) {
    docker run --rm -v "${CurrentDir}\${NGINX_DIR}:/workdir" httpd:alpine htpasswd -cb /workdir/.htpasswd $PrometheusUser $PrometheusPass
}
