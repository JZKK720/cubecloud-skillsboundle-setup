$env:PATH = "$env:USERPROFILE\.local\bin;$env:USERPROFILE\.bun\bin;$env:APPDATA\npm;$env:PATH"
$env:PYTHONUTF8 = "1"

Write-Output "=== Installing scrapling[ai] as uv tool ==="
cmd /c "uv tool install scrapling[ai] --python 3.13 > `"$env:LOCALAPPDATA\Temp\scrapling_tool.log`" 2>&1"
Write-Output "exit: $LASTEXITCODE"
Get-Content "$env:LOCALAPPDATA\Temp\scrapling_tool.log" -Tail 5 -ErrorAction SilentlyContinue

Write-Output ""
Write-Output "=== Test scrapling mcp --help ==="
cmd /c "scrapling mcp --help > `"$env:LOCALAPPDATA\Temp\scrapling_mcp2.log`" 2>&1"
Write-Output "exit: $LASTEXITCODE"
Get-Content "$env:LOCALAPPDATA\Temp\scrapling_mcp2.log" -First 10 -ErrorAction SilentlyContinue