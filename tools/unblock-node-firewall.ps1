$ErrorActionPreference = 'SilentlyContinue'

# Снять блокировки Node.js (когда пользователь нажал «Запретить» в диалоге Windows)
Get-NetFirewallRule -DisplayName 'Node.js*' |
  Where-Object { $_.Action -eq 'Block' } |
  ForEach-Object {
    Write-Host "Disabling block: $($_.Name)"
    Disable-NetFirewallRule -Name $_.Name
  }

# Разрешить node из PATH и типичные пути
$nodes = @()
$cmd = Get-Command node -ErrorAction SilentlyContinue
if ($cmd) { $nodes += $cmd.Source }
$nodes += @(
  "$env:ProgramFiles\nodejs\node.exe",
  "${env:ProgramFiles(x86)}\nodejs\node.exe",
  "$env:LOCALAPPDATA\Programs\node\node.exe"
) | Where-Object { $_ -and (Test-Path $_) }

$nodes = $nodes | Select-Object -Unique
foreach ($n in $nodes) {
  Write-Host "Allow: $n"
  New-NetFirewallRule -DisplayName "Monica Allow Node $($n.GetHashCode())" `
    -Direction Inbound -Program $n -Action Allow -Profile Any -ErrorAction SilentlyContinue | Out-Null
}

# Порты
@(4000, 5612) | ForEach-Object {
  New-NetFirewallRule -DisplayName "Monica Port $_" -Direction Inbound -Protocol TCP -LocalPort $_ -Action Allow -Profile Any -ErrorAction SilentlyContinue | Out-Null
}

Write-Host "`n=== Node.js rules now ==="
Get-NetFirewallRule -DisplayName 'Node.js*','Monica*' |
  Format-Table DisplayName, Enabled, Action, Direction, Profile -AutoSize
