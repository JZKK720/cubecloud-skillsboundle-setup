# MCP daemon smoke test - tests each MCP server by starting it with a timeout.
# If still running after timeout = PASS (daemon started). If exited = check error.
$env:PATH = "$env:USERPROFILE\.local\bin;$env:USERPROFILE\.bun\bin;$env:APPDATA\npm;$env:PATH"
$env:PYTHONUTF8 = "1"
$reportFile = "$env:USERPROFILE\dev\upstream\MCP_SMOKE_TEST.md"
$results = @()

$servers = @(
  @{name="markitdown"; cmd="uvx"; args="markitdown-mcp@latest"; timeout=20},
  @{name="skillspector"; cmd="skillspector"; args="mcp"; timeout=15},
  @{name="firecrawl"; cmd="npx"; args="-y firecrawl-mcp@latest"; timeout=30},
  @{name="scrapling"; cmd="scrapling"; args="mcp"; timeout=25},
  @{name="gbrain"; cmd="gbrain"; args="serve"; timeout=15},
  @{name="graphify"; cmd="graphify-mcp"; args="--transport stdio"; timeout=15}
)

foreach ($s in $servers) {
  $outFile = Join-Path $env:TEMP "mcpfinal_$($s.name)_out.log"
  $errFile = Join-Path $env:TEMP "mcpfinal_$($s.name)_err.log"
  if (Test-Path $outFile) { Remove-Item $outFile -Force }
  if (Test-Path $errFile) { Remove-Item $errFile -Force }
  
  $fullCmd = if ($s.args -and $s.args.Length -gt 0) { "$($s.cmd) $($s.args)" } else { "$($s.cmd)" }
  
  # Use .NET Process with timeout
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
    # Still running = daemon started OK
    $proc.Kill()
    $proc.WaitForExit(3000)
    $outSize = if (Test-Path $outFile) { (Get-Item $outFile).Length } else { 0 }
    $errSize = if (Test-Path $errFile) { (Get-Item $errFile).Length } else { 0 }
    $results += "| $($s.name) | PASS | Daemon started (out=${outSize}B, err=${errSize}B) |"
  } else {
    $exitCode = $proc.ExitCode
    $outSize = if (Test-Path $outFile) { (Get-Item $outFile).Length } else { 0 }
    $errSize = if (Test-Path $errFile) { (Get-Item $errFile).Length } else { 0 }
    $errFirst = if (Test-Path $errFile) { (Get-Content $errFile -First 2 -ErrorAction SilentlyContinue) -join " | " } else { "" }
    if ($errFirst.Length -gt 100) { $errFirst = $errFirst.Substring(0,100) + "..." }
    if ($errFirst -match "(?i)error|traceback|fatal|exception|cannot find|not recognized") {
      $results += "| $($s.name) | FAIL | Exit ${exitCode}: ${errFirst} |"
    } else {
      $results += "| $($s.name) | PASS | Exited ${exitCode} cleanly (out=${outSize}B, err=${errSize}B): ${errFirst} |"
    }
  }
  $proc.Close()
}

$report = @()
$report += "# MCP Daemon Smoke Test Results"
$report += ""
$report += "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$report += ""
$report += "Each MCP server was started with a timeout. If still running after timeout = PASS (daemon). If exited = check error log."
$report += ""
$report += "| Server | Verdict | Detail |"
$report += "|---|---|---|"
$report += $results
$report += ""
$passN = ($results | Where-Object { $_ -match "\| PASS \|" }).Count
$failN = ($results | Where-Object { $_ -match "\| FAIL \|" }).Count
$report += "**PASS: $passN | FAIL: $failN**"

$report | Out-File -FilePath $reportFile -Encoding UTF8
Write-Output "MCP smoke test report: $reportFile"
Write-Output "PASS=$passN FAIL=$failN"