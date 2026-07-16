# Start MinIO with data on network drive Z: (outside Docker).
# Docker Desktop cannot sync bind-mounts to mapped drive Z: (\\192.168.1.198\Files).

$ErrorActionPreference = "Stop"

$MinioExe = Join-Path $PSScriptRoot "minio.exe"
if (-not (Test-Path $MinioExe)) {
    throw "minio.exe not found: $MinioExe"
}

# Resolve Z:\...\MinioMonica without Cyrillic literals (encoding-safe)
$DataDir = $null
Get-ChildItem -Path "Z:\" -Directory -ErrorAction Stop | ForEach-Object {
    $candidate = Join-Path $_.FullName "MinioMonica"
    if (Test-Path $candidate) {
        $DataDir = $candidate
    }
}
if (-not $DataDir) {
    throw "Folder MinioMonica not found under Z:\ (expected under Электронный АРХИВ)"
}

$env:MINIO_ROOT_USER = if ($env:MINIO_ROOT_USER) { $env:MINIO_ROOT_USER } else { "minioadmin" }
$env:MINIO_ROOT_PASSWORD = if ($env:MINIO_ROOT_PASSWORD) { $env:MINIO_ROOT_PASSWORD } else { "minioadmin123" }

Write-Host "MinIO data: $DataDir"
Write-Host "API: http://localhost:9010  Console: http://localhost:9011"

& $MinioExe server $DataDir --address ":9010" --console-address ":9011"
