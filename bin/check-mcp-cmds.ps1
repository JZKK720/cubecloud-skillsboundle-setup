$env:PATH = "C:\Users\KkJz-Th\.local\bin;C:\Users\KkJz-Th\.bun\bin;C:\Users\KkJz-Th\AppData\Roaming\npm;$env:PATH"
$env:PYTHONUTF8 = "1"

Write-Output "=== graphify-mcp --help ==="
cmd /c "graphify-mcp --help > C:\Users\KkJz-Th\AppData\Local\Temp\graphify_mcp_help.log 2>&1"
Get-Content "C:\Users\KkJz-Th\AppData\Local\Temp\graphify_mcp_help.log" -ErrorAction SilentlyContinue | Select-Object -First 15

Write-Output ""
Write-Output "=== scrapling --help (look for mcp subcommand) ==="
cmd /c "scrapling --help > C:\Users\KkJz-Th\AppData\Local\Temp\scrapling_help.log 2>&1"
Get-Content "C:\Users\KkJz-Th\AppData\Local\Temp\scrapling_help.log" -ErrorAction SilentlyContinue | Select-Object -First 15