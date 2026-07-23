# Installs only the skills missing from ~/.agents/skills/ via the security-gated
# install-skill.ps1 helper. Reads skills-list.csv, skips already-present skills,
# and routes local/* rows through -SourcePath (no git clone).
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$env:PYTHONUTF8 = '1'
$env:PATH = "$env:USERPROFILE\.local\bin;$env:PATH"

$repoRoot = "$env:USERPROFILE\dev\cubecloud-skillsboundle-setup"
$csv   = Join-Path $repoRoot 'setup\skills-list.csv'
$helper = "$env:USERPROFILE\dev\bin\install-skill.ps1"

if (-not (Test-Path $csv))   { Write-Host "CSV not found: $csv" -ForegroundColor Red; exit 1 }
if (-not (Test-Path $helper)) { Write-Host "Helper not found: $helper" -ForegroundColor Red; exit 1 }

Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -Force
# SCAN_LOG must exist before the helper tries to append.
if (-not (Test-Path "$env:USERPROFILE\dev\upstream\SCAN_LOG.md")) {
  @("# SkillSpector Scan Log","","| Date | Repo | Skill | Verdict | Status | Notes |","|---|---|---|---|---|---|") |
    Out-File "$env:USERPROFILE\dev\upstream\SCAN_LOG.md" -Encoding UTF8
}

$lines = Get-Content $csv | Where-Object { $_ -and -not $_.StartsWith("#") }
$installed = 0; $blocked = 0; $skipped = 0

foreach ($line in $lines) {
  $parts = $line -split '\|'
  $repo       = $parts[0].Trim()
  $name       = $parts[1].Trim()
  $relPath    = $parts[2].Trim()
  $disabled   = $parts[3].Trim() -eq "true"
  $sourcePath = if ($parts.Length -ge 5) { $parts[4].Trim() } else { '' }

  $destDir = if ($disabled) { "$env:USERPROFILE\.agents\skills._disabled\$name" }
             else { "$env:USERPROFILE\.agents\skills\$name" }
  if (Test-Path $destDir) { $skipped++; Write-Host "skip $name (present)"; continue }

  Write-Host "install $name ..." -NoNewline
  if ($repo -like 'local/*' -or $sourcePath) {
    if (-not $sourcePath) { $sourcePath = "upstream/$name" }
    if (-not [System.IO.Path]::IsPathRooted($sourcePath)) {
      $sourcePath = Join-Path $repoRoot $sourcePath
    }
    $installArgs = @("-Name", $name, "-SourcePath", $sourcePath)
  } else {
    $installArgs = @("-Repo", $repo, "-Name", $name)
    if ($relPath) { $installArgs += @("-SkillRelPath", $relPath) }
  }
  if ($disabled) { $installArgs += "-Disabled" }

  $argLine = ($installArgs | ForEach-Object { '"' + $_ + '"' }) -join ' '
  $out = cmd /c "powershell -NoProfile -ExecutionPolicy Bypass -File `"$helper`" $argLine 2>&1" | Out-String
  if ($out -match "complete:.*active" -or $out -match "complete:.*DISABLED") {
    Write-Host " OK"; $installed++
  } elseif ($out -match "BLOCK|FAIL|Die") {
    Write-Host " BLOCKED"; $blocked++; Write-Host $out -ForegroundColor DarkYellow
  } else {
    Write-Host " ?"; $skipped++; Write-Host $out -ForegroundColor DarkGray
  }
}
Write-Host ""
Write-Host "Installed: $installed  Blocked: $blocked  Skipped: $skipped" -ForegroundColor Cyan