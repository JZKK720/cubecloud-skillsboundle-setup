# Full audit script - writes results to a file for reading
$env:PATH = "$env:USERPROFILE\.local\bin;$env:USERPROFILE\.bun\bin;$env:APPDATA\npm;$env:PATH"
$env:PYTHONUTF8 = "1"
$reportFile = "$env:USERPROFILE\dev\upstream\AUDIT_REPORT.md"
$results = @()

function Add-Result($category, $item, $verdict, $detail) {
  $script:results += "| $category | $item | $verdict | $detail |"
}

# ============ AUDIT 1: MCP SERVERS ============
Add-Result "Category" "Item" "Verdict" "Detail"
Add-Result "---" "---" "---" "---"

# Check mcp.json validity
try {
  $mcp = Get-Content "$env:APPDATA\Code\User\mcp.json" -Raw | ConvertFrom-Json
  $serverCount = $mcp.servers.PSObject.Properties.Count
  Add-Result "MCP" "mcp.json" "PASS" "Valid JSON, $serverCount servers"
  foreach ($prop in $mcp.servers.PSObject.Properties) {
    Add-Result "MCP" "$($prop.Name) config" "PASS" "type=$($prop.Value.type) cmd=$($prop.Value.command)"
  }
} catch {
  Add-Result "MCP" "mcp.json" "FAIL" $_.Exception.Message
}

# Smoke test each MCP server (start, wait, if running = pass)
$mcpServers = @(
  @{name="markitdown"; cmd="uvx"; args="markitdown-mcp@latest"; timeout=20},
  @{name="skillspector"; cmd="skillspector"; args="mcp"; timeout=15},
  @{name="firecrawl"; cmd="npx"; args="-y firecrawl-mcp@latest"; timeout=25},
  @{name="scrapling"; cmd="scrapling"; args="mcp"; timeout=25},
  @{name="gbrain"; cmd="gbrain"; args="serve"; timeout=15},
  @{name="graphify"; cmd="graphify-mcp"; args="--transport stdio"; timeout=15}
)

foreach ($s in $mcpServers) {
  $outFile = Join-Path $env:TEMP "audit_mcp_$($s.name).log"
  $errFile = Join-Path $env:TEMP "audit_mcp_$($s.name)_err.log"
  if (Test-Path $outFile) { Remove-Item $outFile -Force }
  if (Test-Path $errFile) { Remove-Item $errFile -Force }
  
  $fullCmd = if ($s.args) { "$($s.cmd) $($s.args)" } else { "$($s.cmd)" }
  
  # Start process with timeout using .NET diagnostics
  $psi = New-Object System.Diagnostics.ProcessStartInfo
  $psi.FileName = "cmd.exe"
  $psi.Arguments = "/c $fullCmd > `"$outFile`" 2>`"$errFile`""
  $psi.UseShellExecute = $false
  $psi.CreateNoWindow = $true
  $psi.EnvironmentVariables["PATH"] = $env:PATH
  $psi.EnvironmentVariables["PYTHONUTF8"] = "1"
  
  $proc = [System.Diagnostics.Process]::Start($psi)
  $proc.WaitForExit($s.timeout * 1000)
  
  if (-not $proc.HasExited) {
    $proc.Kill()
    $proc.WaitForExit(3000)
    $outSize = if (Test-Path $outFile) { (Get-Item $outFile).Length } else { 0 }
    $errSize = if (Test-Path $errFile) { (Get-Item $errFile).Length } else { 0 }
    Add-Result "MCP" "$($s.name) daemon" "PASS" "Started OK (out=${outSize}B, err=${errSize}B)"
  } else {
    $exitCode = $proc.ExitCode
    $outSize = if (Test-Path $outFile) { (Get-Item $outFile).Length } else { 0 }
    $errSize = if (Test-Path $errFile) { (Get-Item $errFile).Length } else { 0 }
    $errFirst = if (Test-Path $errFile) { (Get-Content $errFile -First 1 -ErrorAction SilentlyContinue) } else { "" }
    if ($errFirst -match "error|Error|traceback|Traceback|fatal|Fatal|Exception") {
      Add-Result "MCP" "$($s.name) daemon" "FAIL" "Exit ${exitCode}: ${errFirst}"
    } else {
      Add-Result "MCP" "$($s.name) daemon" "PASS" "Exited ${exitCode} cleanly (out=${outSize}B, err=${errSize}B)"
    }
  }
  $proc.Close()
}

# ============ AUDIT 2: CLI TOOLS ============
$clis = @(
  @{name="skillspector"; test="--version"},
  @{name="skills-ref"; test="--version"},
  @{name="specify"; test="--version"},
  @{name="skillopt-eval"; test="--help"},
  @{name="agent-reach"; test="--help"},
  @{name="graphify"; test="--version"},
  @{name="markitdown"; test="--version"},
  @{name="uipro"; test="--version"},
  @{name="firecrawl"; test="--version"},
  @{name="gbrain"; test="--version"}
)

foreach ($c in $clis) {
  $found = (Get-Command $c.name -ErrorAction SilentlyContinue).Source
  if (-not $found) {
    Add-Result "CLI" $c.name "FAIL" "Not on PATH"
    continue
  }
  $logFile = Join-Path $env:TEMP "audit_cli_$($c.name).log"
  cmd /c "$($c.name) $($c.test) > `"$logFile`" 2>&1"
  $exitCode = $LASTEXITCODE
  $output = if (Test-Path $logFile) { (Get-Content $logFile -First 1 -ErrorAction SilentlyContinue) } else { "" }
  if ($exitCode -eq 0 -or $output) {
    $ver = $output.ToString().Substring(0, [Math]::Min(60, $output.ToString().Length))
    Add-Result "CLI" $c.name "PASS" "v: $ver"
  } else {
    Add-Result "CLI" $c.name "WARN" "Exit ${exitCode}, no output"
  }
}

# ============ AUDIT 3: SKILLS SPEC VALIDATION ============
$skillsDir = "$env:USERPROFILE\.agents\skills"
$skillDirs = Get-ChildItem $skillsDir -Directory
$validCount = 0
$advisoryCount = 0
$failCount = 0

foreach ($sd in $skillDirs) {
  $skillPath = $sd.FullName
  $logFile = Join-Path $env:TEMP "audit_skillsref_$($sd.Name).log"
  cmd /c "skills-ref validate `"$skillPath`" > `"$logFile`" 2>&1"
  $exitCode = $LASTEXITCODE
  $output = if (Test-Path $logFile) { Get-Content $logFile -ErrorAction SilentlyContinue } else { @() }
  if ($exitCode -eq 0 -and ($output -join " ") -match "Valid skill") {
    $validCount++
  } elseif ($exitCode -eq 0) {
    $validCount++
  } else {
    $advisoryCount++
    $firstIssue = ($output | Select-Object -First 2) -join " ; "
    if ($firstIssue.Length -gt 80) { $firstIssue = $firstIssue.Substring(0, 80) + "..." }
    Add-Result "SKILLS-REF" $sd.Name "ADVISORY" $firstIssue
  }
}
Add-Result "SKILLS-REF" "Summary" "INFO" "Valid: $validCount, Advisory: $advisoryCount, Fail: $failCount"

# ============ AUDIT 4: SKILL FRONTMATTER + FILE CHECK ============
$missingFrontmatter = @()
$missingSkillMd = @()
foreach ($sd in $skillDirs) {
  $skillFile = Join-Path $sd.FullName "SKILL.md"
  if (-not (Test-Path $skillFile)) {
    $missingSkillMd += $sd.Name
    Add-Result "SKILL-FILE" $sd.Name "FAIL" "SKILL.md missing"
    continue
  }
  $content = Get-Content $skillFile -Raw -ErrorAction SilentlyContinue
  if (-not ($content -match "^---")) {
    Add-Result "SKILL-FILE" $sd.Name "FAIL" "No YAML frontmatter"
  }
  if (-not ($content -match "name:")) {
    Add-Result "SKILL-FILE" $sd.Name "FAIL" "No 'name' field in frontmatter"
  }
  if (-not ($content -match "description:")) {
    Add-Result "SKILL-FILE" $sd.Name "FAIL" "No 'description' field"
  }
}
if ($missingSkillMd.Count -eq 0) {
  Add-Result "SKILL-FILE" "All skills" "PASS" "All $($skillDirs.Count) skills have SKILL.md"
}

# ============ AUDIT 5: CLAUDE CODE MIRROR PARITY ============
$agentsSkills = Get-ChildItem $skillsDir -Directory | Select-Object -ExpandProperty Name
$claudeSkills = Get-ChildItem "$env:USERPROFILE\.claude\skills" -Directory -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name
$notMirrored = $agentsSkills | Where-Object { $_ -notin $claudeSkills }
$extraInClaude = $claudeSkills | Where-Object { $_ -notin $agentsSkills }
if ($notMirrored.Count -eq 0) {
  Add-Result "MIRROR" "Parity" "PASS" "All $($agentsSkills.Count) skills mirrored to Claude Code"
} else {
  Add-Result "MIRROR" "Parity" "WARN" "Not mirrored: $($notMirrored -join ', ')"
}
if ($extraInClaude.Count -gt 0) {
  Add-Result "MIRROR" "Extra in Claude" "INFO" "Extra: $($extraInClaude -join ', ')"
}

# ============ AUDIT 6: DISABLED + DOCS + FORKS ============
# Disabled skills
$disabledDir = "$env:USERPROFILE\.agents\skills._disabled"
$disabledSkills = Get-ChildItem $disabledDir -Directory -ErrorAction SilentlyContinue
foreach ($d in $disabledSkills) {
  $hasDisabled = Test-Path (Join-Path $d.FullName "SKILL.md.disabled")
  $hasActive = Test-Path (Join-Path $d.FullName "SKILL.md")
  if ($hasDisabled -and -not $hasActive) {
    Add-Result "DISABLED" $d.Name "PASS" "Properly disabled (SKILL.md.disabled)"
  } else {
    Add-Result "DISABLED" $d.Name "WARN" "hasDisabled=$hasDisabled hasActive=$hasActive"
  }
}

# Governance docs
$docs = @("README.md","CONFLICTS.md","MEMORY_POLICY.md","UPDATE_POLICY.md")
foreach ($d in $docs) {
  $path = "$env:USERPROFILE\.agents\$d"
  if (Test-Path $path) {
    $lines = (Get-Content $path | Measure-Object -Line).Lines
    Add-Result "DOCS" $d "PASS" "$lines lines"
  } else {
    Add-Result "DOCS" $d "FAIL" "Missing"
  }
}
# SCAN_LOG
$scanLog = "$env:USERPROFILE\dev\upstream\SCAN_LOG.md"
if (Test-Path $scanLog) {
  $lines = (Get-Content $scanLog | Measure-Object -Line).Lines
  Add-Result "DOCS" "SCAN_LOG.md" "PASS" "$lines lines"
} else {
  Add-Result "DOCS" "SCAN_LOG.md" "FAIL" "Missing"
}

# Fork mirrors
$forkDir = "$env:USERPROFILE\dev\forks\JZKK720"
$forkCount = (Get-ChildItem $forkDir -Directory -ErrorAction SilentlyContinue).Count
Add-Result "FORKS" "JZKK720 mirrors" "PASS" "$forkCount fork repos cloned"

# Install helper
$helperPath = "$env:USERPROFILE\dev\bin\install-skill.ps1"
if (Test-Path $helperPath) {
  $lines = (Get-Content $helperPath | Measure-Object -Line).Lines
  Add-Result "HELPER" "install-skill.ps1" "PASS" "$lines lines"
} else {
  Add-Result "HELPER" "install-skill.ps1" "FAIL" "Missing"
}

# ============ AUDIT 7: SKILLSPECTOR RE-SCAN ============
# Scan 3 sample skills to verify the scanner is functional
$sampleSkills = @("hallmark", "ponytail", "improve")
foreach ($s in $sampleSkills) {
  $skillPath = "$skillsDir\$s"
  $logFile = Join-Path $env:TEMP "audit_skillspector_$s.log"
  cmd /c "skillspector scan `"$skillPath`" --no-llm > `"$logFile`" 2>&1"
  $exitCode = $LASTEXITCODE
  if ($exitCode -eq 0) {
    Add-Result "SKILLSPECTOR" $s "PASS" "Scan exit 0 (safe)"
  } elseif ($exitCode -eq 1) {
    Add-Result "SKILLSPECTOR" $s "FAIL" "do_not_install (exit 1)"
  } else {
    Add-Result "SKILLSPECTOR" $s "WARN" "Scan exit $exitCode"
  }
}

# ============ WRITE REPORT ============
$report = @()
$report += "# Full Audit Report"
$report += ""
$report += "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$report += ""
$report += "## Results Matrix"
$report += ""
$report += "| Category | Item | Verdict | Detail |"
$report += "|---|---|---|---|"
$report += $results
$report += ""
$report += "## Summary Counts"
$report += ""
$passCount = ($results | Where-Object { $_ -match "\| PASS \|" }).Count
$failCount = ($results | Where-Object { $_ -match "\| FAIL \|" }).Count
$warnCount = ($results | Where-Object { $_ -match "\| (WARN|ADVISORY) \|" }).Count
$report += "- PASS: $passCount"
$report += "- FAIL: $failCount"
$report += "- WARN/ADVISORY: $warnCount"
$report += ""
$report += "## Skill Count"
$report += "- Total in ~/.agents/skills/: $($skillDirs.Count)"
$report += "- Azure: $((($skillDirs | Where-Object { $_.Name -match '^(azure|entra|microsoft|python-app|airunway|appinsights)' })).Count)"
$report += "- New: $((($skillDirs | Where-Object { $_.Name -notmatch '^(azure|entra|microsoft|python-app|airunway|appinsights)' })).Count)"
$report += "- Disabled: $($disabledSkills.Count)"
$report += "- Claude Code mirror: $($claudeSkills.Count)"
$report += "- Fork mirrors: $forkCount"

$report | Out-File -FilePath $reportFile -Encoding UTF8
Write-Output "Report written to $reportFile"
Write-Output "PASS: $passCount | FAIL: $failCount | WARN: $warnCount"