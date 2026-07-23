# Global Skills + CLIs + MCP Setup Guide

## How to reproduce this setup on a new Windows machine

### Quick start (one command)

1. Copy the `~/dev/setup/` folder to the new machine (USB, GitHub, OneDrive, etc.)
2. Open PowerShell and run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\setup-global-skills.ps1
```

3. Restart VS Code. Done.

### What the setup script does

| Phase | What | Time |
|---|---|---|
| 0 | Check/install prerequisites (Python, Node, Git, uv, bun) | ~2 min |
| 0b | Persist PATH + PYTHONUTF8=1 for user | instant |
| 0c | Create directory skeleton (~/.agents/skills, ~/.claude/skills, ~/dev/) | instant |
| 1 | Install SkillSpector (security scanner) + skills-ref (spec validator) | ~2 min |
| 1b | Copy install-skill.ps1 helper to ~/dev/bin/ | instant |
| 2 | Install 12 CLI tools (uv tool + npm + bun) | ~5 min |
| 3 | Clone 27 fork mirrors (26 JZKK720 + awesome-design-md) (skip with -SkipForks) | ~2 min |
| 4 | Install 110 skills through security-gated pipeline (139 total incl. Azure-extension and CLI-provisioned skills) | ~5 min |
| 5 | Configure 7 MCP servers in VS Code User/mcp.json | instant |
| 5b | Pin Copilot utility models in VS Code User/settings.json | instant |
| 6 | Create governance docs (README, CONFLICTS, MEMORY_POLICY, UPDATE_POLICY, SCAN_LOG) | instant |
| 7 | Quick audit (skill count, CLI check, mcp.json validation) | instant |

**Total time: ~15 minutes** (or ~10 min with `-SkipForks`)

### Files in this package

```
~/dev/setup/
├── setup-global-skills.ps1   # Master one-command installer
├── install-skill.ps1          # Security-gated skill install helper (scan→validate→copy)
├── skills-list.csv            # List of skills to install (repo|name|relPath|disabled)
├── mcp.json.template          # MCP server config template (7 servers)
└── SETUP_GUIDE.md             # This file
```

### Prerequisites on the new machine

The script checks for these and installs uv/bun if missing. These must be pre-installed:

```powershell
winget install Python.Python.3.13
winget install OpenJS.NodeJS
winget install Git.Git
winget install Microsoft.VisualStudioCode
```

### What gets installed

**7 MCP servers** (in VS Code User/mcp.json):
- markitdown, skillspector, firecrawl, scrapling, gbrain, graphify, headroom

**Copilot utility model pins** (in VS Code User/settings.json):
- `chat.utilityModel = ollama-models/gemma4:26b-a4b-it-qat`
- `chat.utilitySmallModel = ollama-models/ornith:9b-q8_0`
- `chat.byokUtilityModelDefault = mainAgent` (BYOK fallback when a utility flow needs a default)

**12 CLI tools** (on permanent user PATH):
- skillspector, skills-ref, specify, skillopt-eval, agent-reach, graphify, markitdown, scrapling (via uv)
- uipro, firecrawl (via npm)
- gbrain (via bun)
- headroom (via uv, requires Defender exclusion for ast-grep-cli — see below)

**110 skills via pipeline + 2 CLI-provisioned skills + ~27 Azure-extension skills = 139 total** (in ~/.agents/skills/ — discovered by VS Code Copilot Chat):
- superpowers methodology (12 skills): TDD, systematic-debugging, writing/executing-plans, subagent-driven-development, code review, git-worktrees, finishing-branch, writing-skills, using-superpowers, dispatching-parallel-agents
- ECC agent engineering (35 skills): safety-guard, token-budget-advisor, intent-driven-development, verification-loop, eval-harness, agent-self-evaluation, prompt-optimizer, rules-distill, knowledge-ops, codebase-onboarding, repo-scan, code-tour, search-first, blueprint, strategic-compact, enterprise-agent-ops, production-audit, error-handling, delivery-gate, coding-standards, context-budget, security-review, security-scan, security-bounty-hunter, brand-discovery, brand-voice, frontend-design-direction, make-interfaces-feel-better, continuous-agent-loop, cost-tracking, cost-aware-llm-pipeline, automation-audit-ops, connections-optimizer, mcp-server-patterns, backend-patterns
- self-learning (meta-skill for skill authoring)
- improve (audit-to-plan)
- loopy (loop library)
- ponytail (minimal-code YAGNI)
- hallmark (anti-slop UI design)
- taste-skill (frontend taste/polish)
- karpathy-guidelines (coding guidelines)
- agent-reach (15-platform research access, installed via its own CLI)
- graphify (folder→knowledge graph, installed via its own CLI)
- caveman (DISABLED — token compression, opt-in only)
- oz-skills (14 active): analysis-artifacts, ci-fix, create-pull-request, dbt-model-index, docs-update, github-bug-report-triage, github-issue-dedupe, mcp-builder, scheduler, seo-aeo-audit, slack-qa-investigate, terraform-style-check, web-accessibility-audit, web-performance-audit
- ui-skills (7 active): ui-skills-root, baseline-ui, create-design-md, fixing-accessibility, fixing-metadata, fixing-motion-performance, improve-ui
- agent-skills (23 active, unique entries): api-and-interface-design, browser-testing-with-devtools, ci-cd-and-automation, code-review-and-quality, code-simplification, context-engineering, debugging-and-error-recovery, deprecation-and-migration, documentation-and-adrs, doubt-driven-development, frontend-ui-engineering, git-workflow-and-versioning, idea-refine, incremental-implementation, interview-me, observability-and-instrumentation, performance-optimization, planning-and-task-breakdown, security-and-hardening, shipping-and-launch, source-driven-development, spec-driven-development, using-agent-skills
- loop-engineering (5 active): loop-triage, minimal-fix, loop-constraints, loop-verifier, loop-budget
- changelog-generator (1 active): from ComposioHQ/awesome-claude-skills
- ARIS ports (3 active): aris-novelty-check, aris-research-lit, aris-idea-creator (methodology-only ports from wanshuiyin/Auto-claude-code-research-in-sleep)
- design-md-library (wrapper that indexes the 74 DESIGN.md files in the awesome-design-md fork mirror)
- gstack-review (hand-adapted pre-landing PR review port, with 8 reference files)
- idea-to-design (clean port of brainstorming — methodology only, no browser server)
- webapp-testing (clean port — methodology only, no bundled scripts; agent writes native Playwright or uses browser MCP tools)

Notes:
- Azure/Foundry skills are standard extension-provided Copilot skills.
- Custom implementations in this setup are `agent-reach` and `gstack-review`.

**27 fork mirrors** (in ~/dev/forks/JZKK720/ — read-only backups, incl. VoltAgent/awesome-design-md)

**5 governance docs** (in ~/.agents/ + ~/dev/upstream/):
- README.md, CONFLICTS.md, MEMORY_POLICY.md, UPDATE_POLICY.md, SCAN_LOG.md

### Security model

Every skill is scanned by **NVIDIA SkillSpector** before install:
- `skillspector scan --no-llm <dir>` (static analysis, 68 vulnerability patterns)
- Exit 0 = safe → install proceeds
- Exit 1 = do_not_install → HARD BLOCK, skill is not installed
- Exit 2 = error → investigate before retrying

`skills-ref validate` runs as an ADVISORY check (logs spec drift but doesn't block).

### Skills blocked by SkillSpector (not installed — by design)

| Skill | Reason | Clean port available? |
|---|---|---|
| brainstorming | Tool parameter abuse in `stop-server.sh` (visual companion browser server) | **Yes** → `idea-to-design` (methodology only, no browser server) |
| last30days | Info stealer (reads browser cookies) | No — use `agent-reach` for multi-platform research instead |
| ui-ux-pro-max | Prompt extraction + unsafe defaults | No — use `hallmark` + `taste-skill` for UI design instead |
| anysearch | Vulnerable `requests==2.20` (8 CVEs) | No |
| webapp-testing (oz-skills) | HIGH TM1 — tool parameter abuse (`shell=True` in `scripts/with_server.py:69`) | **Yes** → `webapp-testing` (clean port, methodology only, no bundled scripts) |

### Platform limitations (Windows)

| Tool | Issue | Workaround |
|---|---|---|
| EverOS | `import fcntl` (Unix-only) | Not installed. gbrain MCP used instead. |
| headroom | Windows Defender blocks `ast-grep-cli.exe` (false positive on Rust binary) | Run `bin/add-defender-exclusion-ast-grep.ps1` in an elevated PowerShell first, then `uv tool install "headroom-ai[proxy]"`. Exclusion is scoped to the ast-grep path only. |
| recall | Needs Claude Code hooks | Claude Code only; not for VS Code Copilot. |

### After setup

1. **Restart VS Code** (or `Ctrl+Shift+P` → `Developer: Reload Window`)
2. In Copilot Chat, type `#` to see MCP tools appear
3. Try: "use the improve skill to audit this codebase"
4. Try: "use systematic-debugging to investigate this error"

### To update skills later

```powershell
# Re-run the setup script (it skips already-installed items)
powershell -NoProfile -ExecutionPolicy Bypass -File .\setup-global-skills.ps1

# Or update individual tools
uv tool upgrade --all
npm update -g
bun pm -g update

# Re-scan all skills quarterly
skillspector scan ~/.agents/skills/ --recursive --no-llm
```

### To add a new skill

```powershell
cd ~/dev/bin
.\install-skill.ps1 -Repo "owner/repo" -Name "skill-name"
# For disabled skills:
.\install-skill.ps1 -Repo "owner/repo" -Name "skill-name" -Disabled
# For custom skill paths:
.\install-skill.ps1 -Repo "owner/repo" -Name "skill-name" -SkillRelPath "path/to/skill"
```

### To port to GitHub (for cross-machine access)

```powershell
cd ~/dev/setup
git init
git add .
git commit -m "Global skills + CLIs + MCP setup package"
git remote add origin https://github.com/JZKK720/cubecloud-skillsboundle-setup.git
git push -u origin main
```

Then on any new machine:
```powershell
git clone https://github.com/JZKK720/cubecloud-skillsboundle-setup.git ~/dev/setup
powershell -NoProfile -ExecutionPolicy Bypass -File ~/dev/setup/setup-global-skills.ps1
```