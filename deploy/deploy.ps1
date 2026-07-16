# Deploy Monica to VPS. Usage:
#   .\deploy\deploy.ps1 -HostIp 159.194.232.74 -Password 'YOUR_PASSWORD'
param(
    [string]$HostIp = "159.194.232.74",
    [Parameter(Mandatory = $true)][string]$Password,
    [string]$User = "root",
    [string]$RemoteDir = "/opt/monica"
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")

function Test-SshPort {
    param([string]$Ip)
    $r = Test-NetConnection -ComputerName $Ip -Port 22 -WarningAction SilentlyContinue
    return [bool]$r.TcpTestSucceeded
}

Write-Host "Checking SSH $HostIp:22 ..."
if (-not (Test-SshPort -Ip $HostIp)) {
    Write-Host @"

SSH port 22 is CLOSED on $HostIp.

Open Beget panel -> VPS -> VNC / Console and run:
  systemctl status ssh || systemctl status sshd
  systemctl enable --now ssh || systemctl enable --now sshd
  ss -tlnp | grep ':22'

If UFW is on:
  ufw allow OpenSSH
  ufw allow 80/tcp
  ufw allow 9010/tcp
  ufw reload

Then re-run this script.

"@ -ForegroundColor Yellow
    exit 1
}

if (-not (Get-Command plink -ErrorAction SilentlyContinue) -and -not (Get-Command sshpass -ErrorAction SilentlyContinue)) {
    # Use Posh-SSH if available, else expect ssh with key / interactive
    Write-Host "Using OpenSSH. Prefer key auth; password may need interactive entry for scp/ssh."
}

$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$archive = Join-Path $env:TEMP "monica-deploy-$stamp.tar.gz"

Write-Host "Creating archive..."
Push-Location $ProjectRoot
try {
    # Prefer tar (Windows 10+)
    tar -czf $archive `
        --exclude=node_modules `
        --exclude=frontend/monica/build `
        --exclude=backend/venv `
        --exclude=.git `
        --exclude=data `
        --exclude=mobile `
        --exclude=*.sqlite3 `
        docker-compose.prod.yml `
        .env.prod `
        backend `
        frontend/monica `
        deploy
} finally {
    Pop-Location
}

Write-Host "Archive: $archive"
Write-Host "Next: upload and start (requires working SSH)."
Write-Host @"

Manual commands once SSH works:

scp $archive ${User}@${HostIp}:/tmp/monica.tar.gz
ssh ${User}@${HostIp}
  mkdir -p $RemoteDir
  tar -xzf /tmp/monica.tar.gz -C $RemoteDir
  bash $RemoteDir/deploy/bootstrap-server.sh
  cd $RemoteDir
  cp .env.prod .env
  docker compose -f docker-compose.prod.yml --env-file .env.prod up -d --build
  docker compose -f docker-compose.prod.yml ps

"@
