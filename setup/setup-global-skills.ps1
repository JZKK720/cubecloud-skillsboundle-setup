<#
.SYNOPSIS
  Global Skills + CLIs + MCP Setup for VS Code Copilot on Windows.
  Reproduces the full implementation on any Windows machine.

.DESCRIPTION
  This is a one-command setup script that:
  1. Installs prerequisites (uv, bun, ensures Node/Python/git)
  2. Creates directory skeleton (~/.agents/skills, ~/.claude/skills, ~/dev/upstream, etc.)
  3. Installs SkillSpector (security scanner) + skills-ref (spec validator)
  4. Persists PATH (~/.local/bin, ~/.bun/bin, ~/AppData/Roaming/npm) + PYTHONUTF8=1
  5. Installs all CLI tools (uv tool install + npm install -g + bun install -g)
  6. Installs all skills through the security-gated pipeline (scan -> validate -> copy)
  7. Copies the MCP server config to User/mcp.json
  8. Creates governance docs (README, CONFLICTS, MEMORY_POLICY, UPDATE_POLICY)
  9. Runs a final audit

  Run from any PowerShell terminal:
    powershell -NoProfile -ExecutionPolicy Bypass -File .\setup-global-skills.ps1

  Prerequisites already on the machine:
    - Python 3.13+ (winget install Python.Python.3.13)
    - Node.js 20+ (winget install OpenJS.NodeJS)
    - Git (winget install Git.Git)
    - VS Code (winget install Microsoft.VisualStudioCode)

.PARAMETER SkipForks
  Skip cloning the 22 JZKK720 fork mirror repos (saves time if you don't need backups).

.PARAMETER SkipAudit
  Skip the final audit pass.

.EXAMPLE
  .\setup-global-skills.ps1
  .\setup-global-skills.ps1 -SkipForks
  .\setup-global-skills.ps1 -SkipForks -SkipAudit
#>

[CmdletBinding()]
param(
  [switch]$SkipForks,
  [switch]$SkipAudit
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

function Write-Step($msg) { Write-Host "`n=== $msg ===" -ForegroundColor Cyan }
function Write-OK($msg)   { Write-Host "  OK: $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "  WARN: $msg" -ForegroundColor Yellow }
function Write-Fail($msg) { Write-Host "  FAIL: $msg" -ForegroundColor Red }

function Set-JsoncSetting([string]$Path, [hashtable]$Values) {
  $content = if (Test-Path $Path) { Get-Content $Path -Raw } else { "{`r`n}`r`n" }
  $missingLines = New-Object System.Collections.Generic.List[string]

  foreach ($entry in $Values.GetEnumerator()) {
    $escapedKey = [regex]::Escape($entry.Key)
    $pattern = '(?m)^\s*"' + $escapedKey + '"\s*:\s*"[^"]*"\s*,?\s*$'
    $replacementLine = "  `"$($entry.Key)`": `"$($entry.Value)`","

    if ($content -match $pattern) {
      $content = [regex]::new($pattern).Replace($content, $replacementLine, 1)
    } else {
      $null = $missingLines.Add($replacementLine)
    }
  }

  if ($missingLines.Count -gt 0) {
    $content = $content.TrimEnd()
    $insertBlock = ($missingLines -join "`r`n")
    if ($content.EndsWith('}')) {
      $content = $content.Substring(0, $content.Length - 1).TrimEnd()
      if (-not $content.EndsWith("`r`n") -and -not $content.EndsWith("`n")) {
        $content += "`r`n"
      }
      $content += $insertBlock + "`r`n}`r`n"
    } else {
      if (-not $content.EndsWith("`r`n") -and -not $content.EndsWith("`n")) {
        $content += "`r`n"
      }
      $content += $insertBlock + "`r`n"
    }
  }

  [System.IO.File]::WriteAllText($Path, $content, [System.Text.UTF8Encoding]::new($false))
}

# ============================================================
# PHASE 0: PREREQUISITES
# ============================================================
Write-Step "Phase 0: Prerequisites"

# Check Python
$pythonOk = $false
try { $null = & python --version 2>&1; $pythonOk = $true } catch {}
if (-not $pythonOk) { Write-Fail "Python not found. Install: winget install Python.Python.3.13"; exit 1 }
Write-OK "Python: $(python --version 2>&1)"

# Check Node
$nodeOk = $false
try { $null = & node --version 2>&1; $nodeOk = $true } catch {}
if (-not $nodeOk) { Write-Fail "Node.js not found. Install: winget install OpenJS.NodeJS"; exit 1 }
Write-OK "Node: $(node --version 2>&1)"

# Check Git
try { $null = & git --version 2>&1; Write-OK "Git: $(git --version 2>&1)" }
catch { Write-Fail "Git not found. Install: winget install Git.Git"; exit 1 }

# Install uv (Python package manager) if not present
try { $null = & uv --version 2>&1; Write-OK "uv: $(uv --version 2>&1)" }
catch {
  Write-Host "  Installing uv..." -NoNewline
  cmd /c "winget install --id astral-sh.uv --silent --accept-source-agreements --accept-package-agreements --disable-interactivity >nul 2>nul"
  Write-OK "uv installed (restart terminal to pick up PATH)"
}

# Install bun if not present
try { $null = & bun --version 2>&1; Write-OK "bun: $(bun --version 2>&1)" }
catch {
  Write-Host "  Installing bun..." -NoNewline
  cmd /c "winget install --id Oven-sh.Bun --silent --accept-source-agreements --accept-package-agreements --disable-interactivity >nul 2>nul"
  Write-OK "bun installed (restart terminal to pick up PATH)"
}

# Refresh PATH for this session
$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")
$env:PYTHONUTF8 = "1"

# ============================================================
# PHASE 0b: PERSISTENT PATH + ENV
# ============================================================
Write-Step "Phase 0b: Persistent PATH + PYTHONUTF8"

$userPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
$requiredDirs = @(
  "$env:USERPROFILE\.local\bin",
  "$env:USERPROFILE\.bun\bin",
  "$env:APPDATA\npm"
)
foreach ($dir in $requiredDirs) {
  if ($userPath -notlike "*$dir*") {
    $userPath = "$dir;$userPath"
    Write-OK "Added $dir to user PATH"
  } else {
    Write-OK "$dir already on PATH"
  }
}
[System.Environment]::SetEnvironmentVariable("PATH", $userPath, "User")

$utf8 = [System.Environment]::GetEnvironmentVariable("PYTHONUTF8", "User")
if ($utf8 -ne "1") {
  [System.Environment]::SetEnvironmentVariable("PYTHONUTF8", "1", "User")
  Write-OK "Set PYTHONUTF8=1 for user"
} else {
  Write-OK "PYTHONUTF8 already set"
}

# ============================================================
# PHASE 0c: DIRECTORY SKELETON
# ============================================================
Write-Step "Phase 0c: Directory skeleton"

$dirs = @(
  "$env:USERPROFILE\.agents\skills._disabled",
  "$env:USERPROFILE\.agents\skills._staging",
  "$env:USERPROFILE\.agents\skills._reference",
  "$env:USERPROFILE\.claude\skills",
  "$env:USERPROFILE\.claude\commands",
  "$env:USERPROFILE\.claude\hooks",
  "$env:USERPROFILE\dev\upstream",
  "$env:USERPROFILE\dev\forks\JZKK720",
  "$env:USERPROFILE\dev\bin",
  "$env:USERPROFILE\dev\setup"
)
foreach ($d in $dirs) { New-Item -ItemType Directory -Force -Path $d | Out-Null }
Write-OK "$($dirs.Count) directories created/verified"

# ============================================================
# PHASE 1: SECURITY GATE (SkillSpector + skills-ref)
# ============================================================
Write-Step "Phase 1: Security gate — SkillSpector + skills-ref"

$env:PATH = "$env:USERPROFILE\.local\bin;$env:PATH"

# Install skillspector[mcp]
try { $null = & skillspector --version 2>&1; Write-OK "skillspector: $(skillspector --version 2>&1)" }
catch {
  Write-Host "  Installing skillspector[mcp]..." -NoNewline
  cmd /c "uv tool install --python 3.13 `"skillspector[mcp] @ git+https://github.com/NVIDIA/skillspector.git`" >nul 2>nul"
  cmd /c "uv tool update-shell >nul 2>nul"
  $env:PATH = "$env:USERPROFILE\.local\bin;$env:PATH"
  Write-OK "skillspector installed"
}

# Install skills-ref
try { $null = & skills-ref --version 2>&1; Write-OK "skills-ref: $(skills-ref --version 2>&1)" }
catch {
  Write-Host "  Installing skills-ref..." -NoNewline
  $tmpClone = "$env:TEMP\agentskills_setup"
  if (Test-Path $tmpClone) { Remove-Item $tmpClone -Recurse -Force }
  cmd /c "git clone --depth 1 https://github.com/agentskills/agentskills.git `"$tmpClone`" >nul 2>nul"
  cmd /c "uv tool install --python 3.13 `"$tmpClone\skills-ref`" >nul 2>nul"
  Remove-Item $tmpClone -Recurse -Force -ErrorAction SilentlyContinue
  Write-OK "skills-ref installed"
}

# ============================================================
# PHASE 1b: INSTALL HELPER SCRIPT
# ============================================================
Write-Step "Phase 1b: Install helper script"

$helperSrc = Join-Path $PSScriptRoot "install-skill.ps1"
$helperDst = "$env:USERPROFILE\dev\bin\install-skill.ps1"
if (Test-Path $helperSrc) {
  Copy-Item $helperSrc $helperDst -Force
  Write-OK "install-skill.ps1 copied to ~/dev/bin/"
} else {
  Write-Warn "install-skill.ps1 not found in $PSScriptRoot — you need to copy it manually"
}

# ============================================================
# PHASE 2: CLI TOOLS
# ============================================================
Write-Step "Phase 2: CLI tools"

$pyTools = @(
  @{name="specify-cli"; pkg="specify-cli"},
  @{name="skillopt"; pkg="skillopt"},
  @{name="agent-reach"; pkg="git+https://github.com/Panniantong/Agent-Reach.git"},
  @{name="graphifyy[mcp]"; pkg="graphifyy[mcp]"},
  @{name="markitdown[all]"; pkg="markitdown[all]"},
  @{name="scrapling[ai]"; pkg="scrapling[ai]"}
)
foreach ($t in $pyTools) {
  $binName = $t.name -replace '\[.*\]',''
  $already = Get-Command $binName -ErrorAction SilentlyContinue
  if ($already) { Write-OK "$binName already installed"; continue }
  Write-Host "  Installing $($t.name)..." -NoNewline
  cmd /c "uv tool install --python 3.13 `"$($t.pkg)`" > `"$env:TEMP\install_$($t.name).log`" 2>&1"
  if ($LASTEXITCODE -eq 0) { Write-OK "" } else { Write-Fail "exit $LASTEXITCODE" }
}

# npm tools
$npm = "C:\Program Files\nodejs\npm.cmd"
if (-not (Test-Path $npm)) { $npm = (Get-Command npm -ErrorAction SilentlyContinue).Source }
if ($npm) {
  foreach ($pkg in @("ui-ux-pro-max-cli","firecrawl-cli")) {
    $binName = $pkg -replace '-cli$',''
    if ($binName -eq "ui-ux-pro-max-cli") { $binName = "uipro" }
    $already = Get-Command $binName -ErrorAction SilentlyContinue
    if ($already) { Write-OK "$binName already installed"; continue }
    Write-Host "  Installing $pkg..." -NoNewline
    cmd /c "`"$npm`" install -g $pkg >nul 2>nul"
    if ($LASTEXITCODE -eq 0) { Write-OK "" } else { Write-Fail "exit $LASTEXITCODE" }
  }
}

# bun tools
foreach ($pkg in @("github:garrytan/gbrain")) {
  $binName = ($pkg -split ':')[-1] -replace 'github:',''
  $already = Get-Command $binName -ErrorAction SilentlyContinue
  if ($already) { Write-OK "$binName already installed"; continue }
  Write-Host "  Installing $pkg..." -NoNewline
  cmd /c "bun install -g $pkg >nul 2>nul"
  if ($LASTEXITCODE -eq 0) { Write-OK "" } else { Write-Fail "exit $LASTEXITCODE" }
}

# agent-reach setup
$ar = Get-Command agent-reach -ErrorAction SilentlyContinue
if ($ar) {
  Write-Host "  Running agent-reach install --env=auto..." -NoNewline
  cmd /c "agent-reach install --env=auto >nul 2>nul"
  Write-OK "agent-reach channels configured"
}

# gbrain init
$gb = Get-Command gbrain -ErrorAction SilentlyContinue
if ($gb) {
  Write-Host "  Running gbrain init --pglite --no-embedding..." -NoNewline
  cmd /c "gbrain init --pglite --no-embedding >nul 2>nul"
  Write-OK "gbrain initialized (PGLite, deferred embeddings)"
}

# ============================================================
# PHASE 3: FORK MIRRORS (optional)
# ============================================================
if (-not $SkipForks) {
  Write-Step "Phase 3: Fork mirrors (JZKK720)"
  $forks = @(
    "Gskills","caveman","last30days-skill","EverOS","agentskills",
    "markitdown","firecrawl","ponytail","improve","headroom",
    "taste-skill","ECC","gstack","gbrain","agent-skills",
    "spec-kit","superpowers","llm_wiki","hallmark","Scrapling",
    "graphify","oz-skills"
  )
  $dest = "$env:USERPROFILE\dev\forks\JZKK720"
  foreach ($f in $forks) {
    $target = Join-Path $dest $f
    if (Test-Path $target) { continue }
    cmd /c "git clone --depth 1 https://github.com/JZKK720/$f.git `"$target`" >nul 2>nul"
  }
  # Non-JZKK720 fork mirror: VoltAgent/awesome-design-md (74 DESIGN.md design system
  # files, MIT). Indexed by the design-md-library wrapper skill. Different owner, so
  # handled outside the JZKK720 loop above.
  $admTarget = Join-Path $dest "awesome-design-md"
  if (-not (Test-Path $admTarget)) {
    cmd /c "git clone --depth 1 https://github.com/VoltAgent/awesome-design-md.git `"$admTarget`" >nul 2>nul"
  }
  $forkCount = (Get-ChildItem $dest -Directory).Count
  Write-OK "$forkCount fork repos mirrored"
}

# ============================================================
# PHASE 4: SKILLS INSTALL (via install-skill.ps1)
# ============================================================
Write-Step "Phase 4: Skills install (security-gated)"

$skillsCsv = Join-Path $PSScriptRoot "skills-list.csv"
if (-not (Test-Path $skillsCsv)) {
  Write-Fail "skills-list.csv not found in $PSScriptRoot"
  exit 1
}

$helper = "$env:USERPROFILE\dev\bin\install-skill.ps1"
if (-not (Test-Path $helper)) {
  Write-Fail "install-skill.ps1 not found at $helper"
  exit 1
}

Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -Force
# Ensure the governance/log dir exists before skills try to append to SCAN_LOG.md
# (the helper warns if missing; this prevents that warning on a fresh machine).
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\dev\upstream" | Out-Null
if (-not (Test-Path "$env:USERPROFILE\dev\upstream\SCAN_LOG.md")) {
  @("# SkillSpector Scan Log","","| Date | Repo | Skill | Verdict | Status | Notes |","|---|---|---|---|---|---|") |
    Out-File "$env:USERPROFILE\dev\upstream\SCAN_LOG.md" -Encoding UTF8
}
$lines = Get-Content $skillsCsv | Where-Object { $_ -and -not $_.StartsWith("#") }
$installed = 0; $blocked = 0; $skipped = 0

foreach ($line in $lines) {
  $parts = $line -split '\|'
  $repo = $parts[0].Trim()
  $name = $parts[1].Trim()
  $relPath = $parts[2].Trim()
  $disabled = $parts[3].Trim() -eq "true"

  # Skip if already installed
  $destDir = if ($disabled) { "$env:USERPROFILE\.agents\skills._disabled\$name" }
             else { "$env:USERPROFILE\.agents\skills\$name" }
  if (Test-Path $destDir) { $skipped++; continue }

  Write-Host "  $name..." -NoNewline
  # NOTE: do not use $args here — it is an automatic variable in PowerShell
  # and reassigning it corrupts splatting. Use a plain-named array instead.
  $installArgs = @("-Repo", $repo, "-Name", $name)
  if ($relPath) { $installArgs += @("-SkillRelPath", $relPath) }
  if ($disabled) { $installArgs += "-Disabled" }

  # Invoke via `powershell -ExecutionPolicy Bypass -File` so the helper loads
  # even when the user's effective execution policy would block `& $helper`.
  $argLine = ($installArgs | ForEach-Object { '"' + $_ + '"' }) -join ' '
  $out = cmd /c "powershell -NoProfile -ExecutionPolicy Bypass -File `"$helper`" $argLine 2>&1" | Out-String
  if ($out -match "complete:.*active" -or $out -match "complete:.*DISABLED") {
    Write-Host " OK"; $installed++
  } elseif ($out -match "BLOCK|FAIL|Die") {
    Write-Host " BLOCKED"; $blocked++
  } else {
    Write-Host " ?"; $skipped++
  }
}
Write-OK "Installed: $installed, Blocked: $blocked, Skipped (already present): $skipped"

# ============================================================
# PHASE 5: MCP CONFIG
# ============================================================
Write-Step "Phase 5: MCP server config"

$mcpTemplate = Join-Path $PSScriptRoot "mcp.json.template"
$mcpDest = "$env:APPDATA\Code\User\mcp.json"
if (Test-Path $mcpTemplate) {
  # Preserve existing servers if mcp.json already exists
  if (Test-Path $mcpDest) {
    try {
      $existing = Get-Content $mcpDest -Raw | ConvertFrom-Json
      $template = Get-Content $mcpTemplate -Raw | ConvertFrom-Json
      # Merge: add template servers that don't exist
      foreach ($prop in $template.servers.PSObject.Properties) {
        if (-not $existing.servers.PSObject.Properties[$prop.Name]) {
          $existing.servers | Add-Member -MemberType NoteProperty -Name $prop.Name -Value $prop.Value
        }
      }
      $existing | ConvertTo-Json -Depth 10 | Out-File $mcpDest -Encoding UTF8
      Write-OK "Merged MCP servers into existing mcp.json"
    } catch {
      Copy-Item $mcpTemplate $mcpDest -Force
      Write-OK "Replaced mcp.json with template (existing was invalid)"
    }
  } else {
    Copy-Item $mcpTemplate $mcpDest -Force
    Write-OK "Created mcp.json from template"
  }
} else {
  Write-Warn "mcp.json.template not found — copy manually"
}

# ============================================================
# PHASE 5b: COPILOT UTILITY MODEL PINS
# ============================================================
Write-Step "Phase 5b: Copilot utility model pins"

$copilotSettingsPath = "$env:APPDATA\Code\User\settings.json"
Set-JsoncSetting -Path $copilotSettingsPath -Values @{
  "chat.utilityModel" = "ollama-models/gemma4:26b-a4b-it-qat"
  "chat.utilitySmallModel" = "ollama-models/ornith:9b-q8_0"
  "chat.byokUtilityModelDefault" = "mainAgent"
}
Write-OK "Pinned VS Code Copilot utility models in user settings"

# ============================================================
# PHASE 6: GOVERNANCE DOCS
# ============================================================
Write-Step "Phase 6: Governance docs"

# README.md
$readme = @(
  "# Global Agent Skills Stack",
  "",
  "This directory is the VS Code Copilot Chat skill discovery root.",
  "See ~/dev/setup/SETUP_GUIDE.md for full setup instructions.",
  "",
  "## Install pipeline",
  "All skills installed via ~/dev/bin/install-skill.ps1 (SkillSpector scan -> skills-ref validate -> copy).",
  "",
  "## Security policy",
  "SkillSpector is a hard gate. No skill lands without a passing scan (exit 0).",
  "See ~/dev/upstream/SCAN_LOG.md for full verdict history."
)
$readme | Out-File "$env:USERPROFILE\.agents\README.md" -Encoding UTF8
Write-OK "README.md"

# SCAN_LOG.md
if (-not (Test-Path "$env:USERPROFILE\dev\upstream\SCAN_LOG.md")) {
  @(
    "# SkillSpector Scan Log",
    "",
    "| Date | Repo | Skill | Verdict | Status | Notes |",
    "|---|---|---|---|---|---|"
  ) | Out-File "$env:USERPROFILE\dev\upstream\SCAN_LOG.md" -Encoding UTF8
  Write-OK "SCAN_LOG.md created"
} else {
  Write-OK "SCAN_LOG.md already exists"
}

# CONFLICTS.md, MEMORY_POLICY.md, UPDATE_POLICY.md
@( "# Known Conflicts", "", "Active methodology: superpowers (single).", "Caveman: disabled by default (opt-in token compression).", "Memory: gbrain MCP (primary)." ) | Out-File "$env:USERPROFILE\.agents\CONFLICTS.md" -Encoding UTF8
@( "# Memory Policy", "", "Primary: gbrain MCP (PGLite, zero-config).", "EverOS: Windows-incompatible (fcntl). Not used.", "recall: Claude Code only (needs hooks)." ) | Out-File "$env:USERPROFILE\.agents\MEMORY_POLICY.md" -Encoding UTF8
@( "# Update Policy", "", "Monthly: git pull upstreams, re-scan changed skills, uv tool upgrade --all.", "After any skill change: reload VS Code window." ) | Out-File "$env:USERPROFILE\.agents\UPDATE_POLICY.md" -Encoding UTF8
Write-OK "All governance docs created"

# ============================================================
# PHASE 7: FINAL AUDIT (optional)
# ============================================================
if (-not $SkipAudit) {
  Write-Step "Phase 7: Quick audit"

  $skillCount = (Get-ChildItem "$env:USERPROFILE\.agents\skills" -Directory).Count
  Write-OK "Total skills: $skillCount"

  $mcpValid = $false
  try { $null = Get-Content $mcpDest -Raw | ConvertFrom-Json; $mcpValid = $true } catch {}
  Write-OK "mcp.json valid: $mcpValid"

  try {
    $copilotSettings = Get-Content "$env:APPDATA\Code\User\settings.json" -Raw
    $utilityPinned = $copilotSettings -match '"chat\.utilityModel"\s*:\s*"ollama-models/gemma4:26b-a4b-it-qat"'
    $utilitySmallPinned = $copilotSettings -match '"chat\.utilitySmallModel"\s*:\s*"ollama-models/ornith:9b-q8_0"'
    $byokFallbackPinned = $copilotSettings -match '"chat\.byokUtilityModelDefault"\s*:\s*"mainAgent"'
    Write-OK "Copilot utility model pinned: $utilityPinned"
    Write-OK "Copilot small utility model pinned: $utilitySmallPinned"
    Write-OK "Copilot BYOK fallback pinned: $byokFallbackPinned"
  } catch {
    Write-Warn "Copilot user settings unavailable for audit"
  }

  $cliOk = 0; $cliFail = 0
  foreach ($c in @("skillspector","skills-ref","specify","agent-reach","graphify","markitdown","gbrain","scrapling","uipro","firecrawl")) {
    if (Get-Command $c -ErrorAction SilentlyContinue) { $cliOk++ } else { $cliFail++ }
  }
  Write-OK "CLI tools: $cliOk OK, $cliFail missing"

  $claudeCount = (Get-ChildItem "$env:USERPROFILE\.claude\skills" -Directory -ErrorAction SilentlyContinue).Count
  Write-OK "Claude Code skills: $claudeCount"

  $forkCount = (Get-ChildItem "$env:USERPROFILE\dev\forks\JZKK720" -Directory -ErrorAction SilentlyContinue).Count
  Write-OK "Fork mirrors: $forkCount"
}

# ============================================================
# DONE
# ============================================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  SETUP COMPLETE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Restart VS Code (or reload window: Ctrl+Shift+P -> Developer: Reload Window)"
Write-Host "  2. In Copilot Chat, type # to see MCP tools"
Write-Host "  3. Try: 'use the improve skill to audit this codebase'"
Write-Host ""
Write-Host "Files created:"
Write-Host "  ~/.agents/skills/          — $skillCount skills (VS Code Copilot discovery)"
Write-Host "  ~/.claude/skills/          — Claude Code mirror"
Write-Host "  ~/dev/bin/install-skill.ps1 — security-gated install helper"
Write-Host "  ~/dev/setup/               — this setup package (portable)"
Write-Host "  ~/dev/upstream/SCAN_LOG.md — security scan log"