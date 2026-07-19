$env:PATH = "$env:USERPROFILE\.local\bin;$env:USERPROFILE\.bun\bin;$env:APPDATA\npm;$env:PATH"
$env:PYTHONUTF8 = "1"

Write-Output "=== Reinstalling graphifyy[mcp] ==="
cmd /c "uv tool install graphifyy[mcp] --python 3.13 --force > `"$env:LOCALAPPDATA\Temp\graphify_mcp_install.log`" 2>&1"
Write-Output "exit: $LASTEXITCODE"
Get-Content "$env:LOCALAPPDATA\Temp\graphify_mcp_install.log" -Tail 5 -ErrorAction SilentlyContinue

Write-Output ""
Write-Output "=== Re-test graphify-mcp ==="
$errFile = "$env:LOCALAPPDATA\Temp\retest2_graphify_err.log"
$outFile = "$env:LOCALAPPDATA\Temp\retest2_graphify_out.log"
if (Test-Path $errFile) { Remove-Item $errFile -Force }
if (Test-Path $outFile) { Remove-Item $outFile -Force }

$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = "cmd.exe"
$psi.Arguments = "/c graphify-mcp --transport stdio > `"$outFile`" 2>`"$errFile`""
$psi.UseShellExecute = $false
$psi.CreateNoWindow = $true
$psi.EnvironmentVariables["PATH"] = $env:PATH
$psi.EnvironmentVariables["PYTHONUTF8"] = "1"

$proc = [System.Diagnostics.Process]::Start($psi)
$exited = $proc.WaitForExit(15000)

if (-not $exited) {
  $proc.Kill()
  $proc.WaitForExit(3000)
  $errSize = if (Test-Path $errFile) { (Get-Item $errFile).Length } else { 0 }
  Write-Output "PASS (daemon started, err=${errSize}B)"
} else {
  $exitCode = $proc.ExitCode
  $errFirst = if (Test-Path $errFile) { (Get-Content $errFile -First 3 -ErrorAction SilentlyContinue) -join " | " } else { "" }
  Write-Output "EXITED ($exitCode): $errFirst"
}
$proc.Close()