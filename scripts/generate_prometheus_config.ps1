$directory = ".\prometheus"
if (-Not (Test-Path $directory)) {
    New-Item -ItemType Directory -Path $directory
}

$envFilePath = ".\.env"
$targets = @()

if (Test-Path $envFilePath) {
    $envVars = Get-Content $envFilePath | Where-Object { $_ -match "=" -and $_ -notmatch "^#" }
    foreach ($line in $envVars) {
        $parts = $line -split "="
        $key = $parts[0].Trim()
        $value = $parts[1].Trim()

        if ($key -like "FINCRAFT_*_ADDRESS") {
            $targets += $value
        }
    }
}

if ($targets.Count -eq 0) {
    Write-Error "Error: No microservice address variables (FINCRAFT_*_ADDRESS) found. Check the .env file or environment variables."
    exit 1
}

@"
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: prometheus
    static_configs:
      - targets: [localhost:9090]

  - job_name: fincraft-services
    static_configs:
      - targets: [$($targets -join ", ")]
"@ | Out-File -FilePath .\prometheus\prometheus.yml -Encoding UTF8
