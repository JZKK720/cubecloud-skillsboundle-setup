# 🧊 CubeCloud Skills Bundle

> One-command setup for a full **VS Code Copilot Chat** agent-skills stack on Windows — 94 skills, 12 CLIs, 7 MCP servers, and a 74-site design-system library, all security-gated.

[![Skills](https://img.shields.io/badge/skills-94-2ea44f)](#whats-included)
[![CLIs](https://img.shields.io/badge/CLIs-12-blue)](#clis-installed)
[![MCP servers](https://img.shields.io/badge/MCP%20servers-7-purple)](#mcp-servers)
[![Security gate](https://img.shields.io/badge/security%20gate-SkillSpector-green)](#security-model)
[![Platform](https://img.shields.io/badge/platform-Windows-0078D4)](#prerequisites)
[![License](https://img.shields.io/badge/license-MIT-success)](LICENSE)

---

## Why this exists

VS Code Copilot Chat gets dramatically more powerful when you give it **skills** — markdown instruction packs that teach it domain-specific workflows (TDD, systematic debugging, design systems, Azure patterns, PR review). But assembling a trustworthy stack by hand is painful: you have to find skills, vet them for safety, wire up the MCP servers, install the CLIs, and repeat on every machine.

**CubeCloud Skills Bundle** does all of it in one command. Every skill passes through [NVIDIA SkillSpector](https://github.com/NVIDIA/skillspector) before landing on your machine — vulnerable skills are blocked by design, not after the fact.

## What you get

| | Count | What |
|---|---|---|
| 🧠 Skills | **94** | Discovered by Copilot Chat — superpowers methodology, ui-skills, agent-skills, Azure patterns, design systems, code review, debugging, and more |
| 🔧 CLIs | **12** | On PATH: `skillspector`, `skills-ref`, `specify`, `agent-reach`, `graphify`, `markitdown`, `gbrain`, `scrapling`, `uipro`, `firecrawl`, `skillopt-eval`, `headroom` |
| 🔌 MCP servers | **7** | Configured in VS Code `mcp.json`: markitdown, skillspector, firecrawl, scrapling, gbrain, graphify, headroom |
| 📚 Fork mirrors | **23** | Read-only backups in `~/dev/forks/JZKK720/`, including VoltAgent/awesome-design-md |
| 🎨 DESIGN.md files | **74** | Real-world design systems (Apple, Stripe, Linear, Vercel, Notion, Airbnb, Tesla…) indexed by the `design-md-library` skill |
| 🔒 Security-gated | **yes** | Every skill scanned by SkillSpector before install; 5 skills blocked by design |

## Quick start

```powershell
git clone https://github.com/JZKK720/cubecloud-skillsboundle-setup.git ~/dev/setup
powershell -NoProfile -ExecutionPolicy Bypass -File ~/dev/setup/setup-global-skills.ps1
```

Then **restart VS Code**, open Copilot Chat, and type `#` to see your MCP tools appear.

**Total time: ~15 minutes** (or ~10 min with `-SkipForks`).

### Prerequisites

The script checks for and (where possible) installs these. Pre-install on a fresh machine:

```powershell
winget install Python.Python.3.13
winget install OpenJS.NodeJS
winget install Git.Git
winget install Microsoft.VisualStudioCode
```

## What's included

### Skills (94 active, 1 disabled, 5 blocked — 2 with clean ports)

**Superpowers methodology (12 skills)** from [obra/superpowers](https://github.com/obra/superpowers):
test-driven-development · systematic-debugging · writing-plans · executing-plans · subagent-driven-development · requesting-code-review · receiving-code-review · using-git-worktrees · finishing-a-development-branch · writing-skills · using-superpowers · dispatching-parallel-agents

**oz-skills (14 active)** from the JZKK720 fork mirror:
analysis-artifacts · ci-fix · create-pull-request · dbt-model-index · docs-update · github-bug-report-triage · github-issue-dedupe · mcp-builder · scheduler · seo-aeo-audit · slack-qa-investigate · terraform-style-check · web-accessibility-audit · web-performance-audit

**ui-skills (6 active)** from [ibelick/ui-skills](https://github.com/ibelick/ui-skills):
ui-skills-root · baseline-ui · fixing-accessibility · fixing-metadata · fixing-motion-performance · improve-ui

**agent-skills (23 active, unique entries)** from [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills):
api-and-interface-design · browser-testing-with-devtools · ci-cd-and-automation · code-review-and-quality · code-simplification · context-engineering · debugging-and-error-recovery · deprecation-and-migration · documentation-and-adrs · doubt-driven-development · frontend-ui-engineering · git-workflow-and-versioning · idea-refine · incremental-implementation · interview-me · observability-and-instrumentation · performance-optimization · planning-and-task-breakdown · security-and-hardening · shipping-and-launch · source-driven-development · spec-driven-development · using-agent-skills

**Azure & cloud (24 skills)** — bundled with VS Code Azure extensions, discovered automatically:
ai-mlstudio · airunway-aks-setup · appinsights-instrumentation · azure-ai · azure-aigateway · azure-cloud-migrate · azure-compliance · azure-compute · azure-cost · azure-deploy · azure-diagnostics · azure-enterprise-infra-planner · azure-kubernetes · azure-kusto · azure-messaging · azure-prepare · azure-quotas · azure-reliability · azure-resource-lookup · azure-resource-visualizer · azure-storage · azure-upgrade · azure-validate · entra-agent-id · entra-app-registration · microsoft-foundry · python-appservice-deploy

**Crafted individual skills:**
- **self-learning** — capture hard-won workflows as reusable skills
- **improve** — audit a codebase into prioritized implementation plans
- **loopy** — discover, run, and publish repeatable agent loops
- **ponytail** — force the laziest solution that actually works (YAGNI)
- **hallmark** — anti-slop UI design for landing pages and redesigns
- **taste-skill** — frontend taste/polish, anti-templated output
- **karpathy-guidelines** — coding behavioral guidelines
- **agent-reach** — research across 15 platforms (Twitter, Reddit, YouTube, GitHub, LinkedIn, Xueqiu, Bilibili, XiaoHongShu, and more)
- **graphify** — turn any folder into a knowledge graph

**Hand-ported:**
- **gstack-review** — pre-landing PR review with structural-issue checklist + 8 specialist lenses (security, testing, maintainability, performance, data-migration, api-contract, red-team). Adapted from [garrytan/gstack](https://github.com/garrytan/gstack) (MIT).
- **design-md-library** — indexes the 74 DESIGN.md files in the awesome-design-md fork mirror so agents can self-serve "make it look like Stripe" requests
- **idea-to-design** — clean port of obra/superpowers `brainstorming` (upstream blocked by SkillSpector for tool parameter abuse in `stop-server.sh`). Methodology only: collaborative design dialogue, hard gate before implementation, spec self-review, user review gate. No browser server, no scripts.
- **webapp-testing** — clean port of JZKK720/oz-skills `webapp-testing` (upstream blocked by SkillSpector for `shell=True` tool parameter abuse in `scripts/with_server.py`). Methodology only: reconnaissance-then-action pattern, static vs dynamic decision tree. No bundled scripts; agent writes native Playwright or uses browser MCP tools.

**Disabled by default:**
- **caveman** — token compression, opt-in only

**Blocked by SkillSpector (not installed — by design):**

| Skill | Reason | Clean port? |
|---|---|---|
| brainstorming | Tool parameter abuse in `stop-server.sh` | **Yes** → `idea-to-design` |
| last30days | Info stealer (reads browser cookies) | No — use `agent-reach` |
| ui-ux-pro-max | Prompt extraction + unsafe defaults | No — use `hallmark` + `taste-skill` |
| anysearch | Vulnerable `requests==2.20` (8 CVEs) | No |
| webapp-testing (oz-skills) | HIGH TM1 — tool parameter abuse (`shell=True` in `scripts/with_server.py:69`) | **Yes** → `webapp-testing` (clean port) |

### CLIs installed

| Tool | Source | Purpose |
|---|---|---|
| `skillspector` | uv | Security scanner — hard gate for every skill install |
| `skills-ref` | uv | Spec validator (advisory) |
| `specify` | uv | Spec-Driven Development CLI (spec-kit) |
| `skillopt-eval` | uv | Skill evaluation harness |
| `agent-reach` | uv | 15-platform research access |
| `graphify` | uv | Folder → knowledge graph |
| `markitdown` | uv | Convert anything to Markdown |
| `scrapling` | uv | Stealthy web scraping |
| `uipro` | npm | UI/UX workflow CLI |
| `firecrawl` | npm | Firecrawl API CLI |
| `gbrain` | bun | Persistent agent memory |
| `headroom` | uv | Context compression layer for AI agents (60-95% fewer tokens); MCP server exposes `headroom_compress`, `headroom_retrieve`, `headroom_stats`. Requires Defender exclusion for `ast-grep-cli` — see [Platform limitations](#platform-limitations-windows). |

### MCP servers

Configured in VS Code User `mcp.json`:
- **markitdown** — convert anything to Markdown
- **skillspector** — skill security scanning
- **firecrawl** — web scraping/crawling
- **scrapling** — stealthy fetching
- **gbrain** — persistent memory
- **graphify** — codebase knowledge graphs
- **headroom** — context compression (`headroom_compress`, `headroom_retrieve`, `headroom_stats`)

## Security model

Every skill is scanned by **NVIDIA SkillSpector** before install:

```
skillspector scan --no-llm <dir>
```

- Exit 0 → safe → install proceeds
- Exit 1 → `do_not_install` → **HARD BLOCK**, skill is not installed
- Exit 2 → error → investigate before retrying

`skills-ref validate` runs as an **advisory** check (logs spec drift, doesn't block).

Full verdict history is in [`upstream/SCAN_LOG.md`](upstream/SCAN_LOG.md).

## Repository layout

```
~/dev/
├── setup/                      # the one-command installer + config
│   ├── setup-global-skills.ps1 # master installer
│   ├── install-skill.ps1       # security-gated skill install helper
│   ├── skills-list.csv         # manifest of skills to install
│   ├── mcp.json.template       # 7 MCP server config
│   └── SETUP_GUIDE.md          # detailed guide
├── bin/                        # 17 audit/fix/install helper scripts
├── upstream/                   # governance docs + design-md-library wrapper skill
└── forks/JZKK720/              # 23 read-only fork mirrors (gitignored, re-cloned)
```

## How to use after setup

In Copilot Chat, try:

- *"use the **improve** skill to audit this codebase"*
- *"use **systematic-debugging** to investigate this error"*
- *"use the **design-md-library** to build me a page that looks like Stripe"*
- *"use **gstack-review** to review my PR"*
- *"use **agent-reach** to research what people are saying about X on Reddit"*

## To update later

```powershell
# Re-run the installer (skips already-installed items)
powershell -NoProfile -ExecutionPolicy Bypass -File ~/dev/setup/setup-global-skills.ps1

# Update tools
uv tool upgrade --all
npm update -g
bun pm -g update

# Re-scan all skills quarterly
skillspector scan ~/.agents/skills/ --recursive --no-llm
```

## To add a new skill

```powershell
cd ~/dev/bin
.\install-skill.ps1 -Repo "owner/repo" -Name "skill-name"
# Disabled:
.\install-skill.ps1 -Repo "owner/repo" -Name "skill-name" -Disabled
# Custom path:
.\install-skill.ps1 -Repo "owner/repo" -Name "skill-name" -SkillRelPath "path/to/skill"
```

## Platform limitations (Windows)

| Tool | Issue | Workaround |
|---|---|---|
| EverOS | `import fcntl` (Unix-only) | Not installed. `gbrain` MCP used instead. |
| headroom | Windows Defender blocks `ast-grep-cli.exe` (false positive on Rust binary) | Run `bin/add-defender-exclusion-ast-grep.ps1` in an elevated PowerShell, then `uv tool install "headroom-ai[proxy]"`. Exclusion is scoped to ast-grep only. |
| recall | Needs Claude Code hooks | Claude Code only; not for VS Code Copilot. |

## License

MIT — see [LICENSE](LICENSE).

The bundled skills retain their upstream licenses (mostly MIT). `gstack-review` is adapted from [garrytan/gstack](https://github.com/garrytan/gstack) (MIT, © 2026 Garry Tan). The `design-md-library` wrapper indexes content from [VoltAgent/awesome-design-md](https://github.com/VoltAgent/awesome-design-md) (MIT), which extracts publicly visible CSS values from public websites — no ownership of any site's visual identity is claimed.

## Contributing

This is a personal setup bundle. Issues and PRs are welcome, but the install pipeline is opinionated about security (SkillSpector is a hard gate, not a suggestion). If you submit a skill for inclusion, it must pass `skillspector scan` with exit 0.

## Acknowledgements

Built on the work of many open-source authors. See [`setup/skills-list.csv`](setup/skills-list.csv) for the full list of upstream sources. Special thanks to:
- [obra/superpowers](https://github.com/obra/superpowers) — the core methodology
- [NVIDIA/skillspector](https://github.com/NVIDIA/skillspector) — the security gate
- [VoltAgent/awesome-design-md](https://github.com/VoltAgent/awesome-design-md) — the design system library
- [garrytan/gstack](https://github.com/garrytan/gstack) — the PR review methodology