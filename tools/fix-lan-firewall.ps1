$ErrorActionPreference = 'SilentlyContinue'
$node = (Get-Command node).Source
Write-Host "Node: $node"

New-NetFirewallRule -DisplayName 'Monica Node.exe' -Direction Inbound -Program $node -Action Allow -Profile Any | Out-Null
New-NetFirewallRule -DisplayName 'Monica Frontend 4000 Domain' -Direction Inbound -Protocol TCP -LocalPort 4000 -Action Allow -Profile Domain | Out-Null
New-NetFirewallRule -DisplayName 'Monica Backend 5612 Domain' -Direction Inbound -Protocol TCP -LocalPort 5612 -Action Allow -Profile Domain | Out-Null
Enable-NetFirewallRule -DisplayName 'Monica*' | Out-Null

Get-NetFirewallRule -DisplayName 'Monica*' |
  Format-Table DisplayName, Enabled, Profile, Direction, Action -AutoSize
