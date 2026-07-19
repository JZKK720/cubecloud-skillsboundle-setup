$env:PATH = "C:\Users\KkJz-Th\.local\bin;C:\Users\KkJz-Th\.bun\bin;C:\Users\KkJz-Th\AppData\Roaming\npm;$env:PATH"
$env:PYTHONUTF8 = "1"

Write-Output "=== scrapling mcp --help ==="
cmd /c "uvx scrapling mcp --help > C:\Users\KkJz-Th\AppData\Local\Temp\scrapling_mcp_help.log 2>&1"
Get-Content "C:\Users\KkJz-Th\AppData\Local\Temp\scrapling_mcp_help.log" -ErrorAction SilentlyContinue | Select-Object -First 15