# Add Windows Defender exclusions for ast-grep-cli (sg.exe)
# REQUIRED: Run this in an ELEVATED PowerShell (Right-click PowerShell -> Run as administrator)
#
# Why: ast-grep-cli is a Rust-compiled code-search binary that Defender flags as
# "potentially unwanted software" (false positive, os error 225). This blocks
# headroom-ai from installing because ast-grep-cli is a core dependency used for
# AST-based code compression.
#
# These exclusions are scoped narrowly to the ast-grep-cli install path and the
# sg.exe process name only. They do NOT disable Defender globally.

Add-MpPreference -ExclusionPath "C:\Users\1\AppData\Roaming\uv\tools\ast-grep-cli"
Add-MpPreference -ExclusionProcess "sg.exe"

Write-Host "Defender exclusions added for ast-grep-cli (sg.exe)" -ForegroundColor Green
Write-Host "  Path:    C:\Users\1\AppData\Roaming\uv\tools\ast-grep-cli" -ForegroundColor Cyan
Write-Host "  Process: sg.exe" -ForegroundColor Cyan
Write-Host ""
Write-Host "You can now install headroom-ai. Return to the Copilot Chat session" -ForegroundColor Yellow
Write-Host "and tell the agent to retry the headroom install." -ForegroundColor Yellow