$directory = ".\prometheus"
if (-Not (Test-Path $directory)) {
    New-Item -ItemType Directory -Path $directory
}

@"
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: prometheus
    static_configs:
      - targets: [localhost:9090]
"@ | Out-File -FilePath .\prometheus\prometheus.yml -Encoding UTF8
