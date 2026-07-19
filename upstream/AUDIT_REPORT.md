# Full Audit Report

Generated: 2026-07-19 13:30:59

## Results Matrix

| Category | Item | Verdict | Detail |
|---|---|---|---|
| Category | Item | Verdict | Detail |
| --- | --- | --- | --- |
| MCP | mcp.json | PASS | Valid JSON, 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 servers |
| MCP | github config | PASS | type=http cmd= |
| MCP | figma config | PASS | type=http cmd= |
| MCP | huggingface config | PASS | type=http cmd= |
| MCP | duckdb config | PASS | type=stdio cmd=uvx |
| MCP | playwright config | PASS | type=stdio cmd=npx |
| MCP | microsoft-docs config | PASS | type=http cmd= |
| MCP | microsoft/markitdown config | PASS | type=stdio cmd=uvx |
| MCP | microsoft/playwright-mcp config | PASS | type=stdio cmd=npx |
| MCP | firecrawl/firecrawl-mcp-server config | PASS | type=stdio cmd=npx |
| MCP | makenotion/notion-mcp-server config | PASS | type=http cmd= |
| MCP | io.github.tavily-ai/tavily-mcp config | PASS | type=stdio cmd=npx |
| MCP | io.github.github/github-mcp-server config | PASS | type=http cmd= |
| MCP | io.github.hashicorp/terraform-mcp-server config | PASS | type=stdio cmd=docker |
| MCP | io.github.ihor-sokoliuk/mcp-searxng config | PASS | type=stdio cmd=npx |
| MCP | codebase-memory-mcp config | PASS | type=stdio cmd=C:/Users/cubecloud-io/AppData/Local/Programs/codebase-memory-mcp/cbm-launcher.cmd |
| MCP | skillspector config | PASS | type=stdio cmd=skillspector |
| MCP | firecrawl config | PASS | type=stdio cmd=npx |
| MCP | scrapling config | PASS | type=stdio cmd=scrapling |
| MCP | gbrain config | PASS | type=stdio cmd=gbrain |
| MCP | graphify config | PASS | type=stdio cmd=graphify-mcp |
| MCP | markitdown daemon | PASS | Started OK (out=0B, err=288B) |
| MCP | skillspector daemon | PASS | Started OK (out=0B, err=0B) |
| MCP | firecrawl daemon | PASS | Started OK (out=0B, err=245B) |
| MCP | scrapling daemon | PASS | Started OK (out=0B, err=0B) |
| MCP | gbrain daemon | PASS | Started OK (out=0B, err=0B) |
| MCP | graphify daemon | PASS | Started OK (out=0B, err=0B) |
| CLI | skillspector | PASS | v: SkillSpector v2.3.13 |
| CLI | skills-ref | PASS | v: skills-ref, version 0.1.0 |
| CLI | specify | PASS | v: specify 0.13.0 |
| CLI | skillopt-eval | PASS | v: usage: skillopt-eval [-h] --config CONFIG --skill SKILL [--s |
| CLI | agent-reach | PASS | v: usage: agent-reach [-h] [-v] [--version] |
| CLI | graphify | PASS | v: graphify 0.9.20 |
| CLI | markitdown | PASS | v: C:\Users\1\AppData\Roaming\uv\tools\markitdown\Lib\site-pack |
| CLI | uipro | PASS | v: 2.11.0 |
| CLI | firecrawl | PASS | v: 1.19.26 |
| CLI | gbrain | PASS | v: gbrain 0.42.62.0 |
| SKILLS-REF | airunway-aks-setup | ADVISORY | Validation failed for C:\Users\1\.agents\skills\airunway-aks-setup: ;   - Unexpe... |
| SKILLS-REF | hallmark | ADVISORY | Validation failed for C:\Users\1\.agents\skills\hallmark: ;   - Unexpected field... |
| SKILLS-REF | ponytail | ADVISORY | Validation failed for C:\Users\1\.agents\skills\ponytail: ;   - Unexpected field... |
| SKILLS-REF | taste-skill | ADVISORY | Validation failed for C:\Users\1\.agents\skills\taste-skill: ;   - Directory nam... |
| SKILLS-REF | Summary | INFO | Valid: 42, Advisory: 4, Fail: 0 |
| SKILL-FILE | All skills | PASS | All 46 skills have SKILL.md |
| MIRROR | Parity | WARN | Not mirrored: airunway-aks-setup, appinsights-instrumentation, azure-ai, azure-aigateway, azure-cloud-migrate, azure-compliance, azure-compute, azure-cost, azure-deploy, azure-diagnostics, azure-enterprise-infra-planner, azure-kubernetes, azure-kusto, azure-messaging, azure-prepare, azure-quotas, azure-reliability, azure-resource-lookup, azure-resource-visualizer, azure-storage, azure-upgrade, azure-validate, entra-agent-id, entra-app-registration, microsoft-foundry, python-appservice-deploy |
| MIRROR | Extra in Claude | INFO | Extra: caveman |
| DISABLED | caveman | PASS | Properly disabled (SKILL.md.disabled) |
| DOCS | README.md | PASS | 8 lines |
| DOCS | CONFLICTS.md | PASS | 4 lines |
| DOCS | MEMORY_POLICY.md | PASS | 4 lines |
| DOCS | UPDATE_POLICY.md | PASS | 3 lines |
| DOCS | SCAN_LOG.md | PASS | 22 lines |
| FORKS | JZKK720 mirrors | PASS | 22 fork repos cloned |
| HELPER | install-skill.ps1 | PASS | 145 lines |
| SKILLSPECTOR | hallmark | PASS | Scan exit 0 (safe) |
| SKILLSPECTOR | ponytail | PASS | Scan exit 0 (safe) |
| SKILLSPECTOR | improve | PASS | Scan exit 0 (safe) |

## Summary Counts

- PASS: 49
- FAIL: 0
- WARN/ADVISORY: 5

## Skill Count
- Total in ~/.agents/skills/: 46
- Azure: 26
- New: 20
- Disabled: 1
- Claude Code mirror: 21
- Fork mirrors: 22
