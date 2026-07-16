# Mirrors Docker MinIO data (on C:) to network share Z:\...\MinioMonica.
# Docker Desktop cannot bind-mount Z: into the Linux VM.

$ErrorActionPreference = "Continue"
$Source = Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) "data\minio"
if (-not (Test-Path $Source)) {
    $Source = "C:\Users\testii\Downloads\Monica\data\minio"
}

$Dest = $null
Get-ChildItem -Path "Z:\" -Directory -ErrorAction Stop | ForEach-Object {
    $candidate = Join-Path $_.FullName "MinioMonica"
    if (Test-Path $candidate) { $Dest = $candidate }
}
if (-not $Dest) {
    throw "MinioMonica not found under Z:\"
}

Write-Host "Mirror: $Source -> $Dest"
Write-Host "Press Ctrl+C to stop."

while ($true) {
    if (Test-Path $Source) {
        robocopy $Source $Dest /MIR /E /R:1 /W:1 /NFL /NDL /NJH /NJS /NC /NS | Out-Null
    }
    Start-Sleep -Seconds 3
}
