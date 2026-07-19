$env:PATH = "$env:USERPROFILE\.local\bin;$env:USERPROFILE\.bun\bin;$env:APPDATA\npm;$env:PATH"
$env:PYTHONUTF8 = "1"

$servers = @(
  @{name="scrapling"; cmd="scrapling"; args="mcp"; timeout=15},
  @{name="graphify"; cmd="graphify-mcp"; args="--transport stdio"; timeout=15}
)

foreach ($s in $servers) {
  Write-Output "=== $($s.name) ==="
  $outFile = "$env:LOCALAPPDATA\Temp\retest_$($s.name)_out.log"
  $errFile = "$env:LOCALAPPDATA\Temp\retest_$($s.name)_err.log"
  if (Test-Path $outFile) { Remove-Item $outFile -Force }
  if (Test-Path $errFile) { Remove-Item $errFile -Force }
  
  $fullCmd = "$($s.cmd) $($s.args)"
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
    $proc.Kill()
    $proc.WaitForExit(3000)
    $errSize = if (Test-Path $errFile) { (Get-Item $errFile).Length } else { 0 }
    Write-Output "  PASS (daemon started, err=${errSize}B)"
  } else {
    $exitCode = $proc.ExitCode
    $errFirst = if (Test-Path $errFile) { (Get-Content $errFile -First 3 -ErrorAction SilentlyContinue) -join " | " } else { "" }
    if ($errFirst.Length -gt 120) { $errFirst = $errFirst.Substring(0,120) + "..." }
    Write-Output "  EXITED ($exitCode): $errFirst"
  }
  $proc.Close()
}