$env:PATH = "$env:USERPROFILE\.local\bin;$env:USERPROFILE\.bun\bin;$env:APPDATA\npm;$env:PATH"
$env:PYTHONUTF8 = "1"
$results = @()

$servers = @(
  @{name="markitdown"; cmd="uvx"; args="markitdown-mcp@latest"; timeout=20},
  @{name="skillspector"; cmd="skillspector"; args="mcp"; timeout=15},
  @{name="firecrawl"; cmd="npx"; args="-y firecrawl-mcp@latest"; timeout=25},
  @{name="scrapling"; cmd="scrapling"; args="mcp"; timeout=25},
  @{name="gbrain"; cmd="gbrain"; args="serve"; timeout=15},
  @{name="graphify"; cmd="graphify-mcp"; args="--transport stdio"; timeout=15}
)

foreach ($s in $servers) {
  Write-Host -NoNewline "  $($s.name)..."
  $outFile = Join-Path $env:TEMP "mcpaudit_$($s.name)_out.log"
  $errFile = Join-Path $env:TEMP "mcpaudit_$($s.name)_err.log"
  if (Test-Path $outFile) { Remove-Item $outFile -Force }
  if (Test-Path $errFile) { Remove-Item $errFile -Force }

  # Build the full command line for cmd /c
  if ($s.args -and $s.args.Length -gt 0) {
    $fullCmd = "$($s.cmd) $($s.args)"
  } else {
    $fullCmd = "$($s.cmd)"
  }

  # Start process with timeout via .NET (avoids Start-Job over-quoting the command line)
  $psi = New-Object System.Diagnostics.ProcessStartInfo
  $psi.FileName = "cmd.exe"
  $psi.Arguments = "/c $fullCmd > `"$outFile`" 2>`"$errFile`""
  $psi.UseShellExecute = $false
  $psi.CreateNoWindow = $true
  $psi.EnvironmentVariables["PATH"] = $env:PATH
  $psi.EnvironmentVariables["PYTHONUTF8"] = "1"

  $proc = [System.Diagnostics.Process]::Start($psi)
  $exited = $proc.WaitForExit($s.timeout * 1000)

  if (-not $exited) {
    # Still running after timeout = MCP daemon started OK
    $proc.Kill()
    $proc.WaitForExit(3000)
    $outSize = if (Test-Path $outFile) { (Get-Item $outFile).Length } else { 0 }
    $errSize = if (Test-Path $errFile) { (Get-Item $errFile).Length } else { 0 }
    Write-Host " PASS (daemon up, out=${outSize}B err=${errSize}B)" -ForegroundColor Green
    $results += "PASS: $($s.name) daemon started (out=${outSize}B, err=${errSize}B)"
  } else {
    $exitCode = $proc.ExitCode
    $outSize = if (Test-Path $outFile) { (Get-Item $outFile).Length } else { 0 }
    $errSize = if (Test-Path $errFile) { (Get-Item $errFile).Length } else { 0 }
    $errLines = if (Test-Path $errFile) { (Get-Content $errFile -ErrorAction SilentlyContinue | Select-Object -First 2) -join " | " } else { "" }
    Write-Host " CHECK (exited, out=${outSize}B err=${errSize}B)" -ForegroundColor Yellow
    if ($errLines) { Write-Host "    err: $errLines" -ForegroundColor DarkYellow }
    $results += "CHECK: $($s.name) exited (out=${outSize}B, err=${errSize}B): $errLines"
  }
  $proc.Close()
}

Write-Host ""
Write-Host "=== AUDIT 1: MCP SERVERS SUMMARY ===" -ForegroundColor Cyan
$results | ForEach-Object { Write-Host "  $_" }

# Save results to file for the final report
$results | Out-File "$env:TEMP\audit1_results.txt"
Write-Host ""
Write-Host "Results saved to $env:TEMP\audit1_results.txt"