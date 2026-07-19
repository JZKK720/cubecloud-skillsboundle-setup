try {
  $m = Get-Content "$env:APPDATA\Code\User\mcp.json" -Raw | ConvertFrom-Json
  Write-Output "JSON valid"
  $m.servers.PSObject.Properties.Name | ForEach-Object { Write-Output "  $_" }
  Write-Output ""
  Write-Output "scrapling args: $($m.servers.scrapling.args -join ', ')"
  Write-Output "graphify args: $($m.servers.graphify.args -join ', ')"
} catch {
  Write-Output "ERROR: $($_.Exception.Message)"
}