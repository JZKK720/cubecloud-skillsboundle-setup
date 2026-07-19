# Final Global Audit Pass

Generated: 2026-07-19 13:12:47

## Results Matrix

| Category | Item | Verdict | Detail |
|---|---|---|---|
| PATH | .local\bin | PASS | Persistent user PATH |
| PATH | .bun\bin | PASS | Persistent user PATH |
| PATH | AppData\Roaming\npm | PASS | Persistent user PATH |
| ENV | PYTHONUTF8 | PASS | Permanent user env = 1 |
| MCP | mcp.json | PASS | Valid JSON, 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 servers |
| MCP | github | PASS | cmd= args= |
| MCP | figma | PASS | cmd= args= |
| MCP | huggingface | PASS | cmd= args= |
| MCP | duckdb | PASS | cmd=uvx args=mcp-server-duckdb,--db-path,${input:duckdb_db_path} |
| MCP | playwright | PASS | cmd=npx args=@playwright/mcp@latest |
| MCP | microsoft-docs | PASS | cmd= args= |
| MCP | microsoft/markitdown | PASS | cmd=uvx args=markitdown-mcp@0.0.1a4 |
| MCP | microsoft/playwright-mcp | PASS | cmd=npx args=@playwright/mcp@latest |
| MCP | firecrawl/firecrawl-mcp-server | PASS | cmd=npx args=-y,firecrawl-mcp@latest |
| MCP | makenotion/notion-mcp-server | PASS | cmd= args= |
| MCP | io.github.tavily-ai/tavily-mcp | PASS | cmd=npx args=tavily-mcp@0.2.15 |
| MCP | io.github.github/github-mcp-server | PASS | cmd= args= |
| MCP | io.github.hashicorp/terraform-mcp-server | PASS | cmd=docker args=run,-i,--rm,-e,TFE_ADDRESS=${input:address},-e,TFE_TOKEN=${input:token},-e,ENABLE_TF_OPERATIONS=${input:enabled},docker.io/hashicorp/terraform-mcp-server:1.0.0 |
| MCP | io.github.ihor-sokoliuk/mcp-searxng | PASS | cmd=npx args=mcp-searxng@1.8.0 |
| MCP | codebase-memory-mcp | PASS | cmd=C:/Users/cubecloud-io/AppData/Local/Programs/codebase-memory-mcp/cbm-launcher.cmd args= |
| MCP | skillspector | PASS | cmd=skillspector args=mcp |
| MCP | firecrawl | PASS | cmd=npx args=-y,firecrawl-mcp@latest |
| MCP | scrapling | PASS | cmd=scrapling args=mcp |
| MCP | gbrain | PASS | cmd=gbrain args=serve |
| MCP | graphify | PASS | cmd=graphify-mcp args=--transport,stdio |
| CLI | skillspector | PASS | C:\Users\1\.local\bin\skillspector.exe |
| CLI | skills-ref | PASS | C:\Users\1\.local\bin\skills-ref.exe |
| CLI | specify | PASS | C:\Users\1\.local\bin\specify.exe |
| CLI | skillopt-eval | PASS | C:\Users\1\.local\bin\skillopt-eval.exe |
| CLI | agent-reach | PASS | C:\Users\1\.local\bin\agent-reach.exe |
| CLI | graphify | PASS | C:\Users\1\.local\bin\graphify.exe |
| CLI | markitdown | PASS | C:\Users\1\.local\bin\markitdown.exe |
| CLI | uipro | PASS | C:\Users\1\AppData\Roaming\npm\uipro.ps1 |
| CLI | firecrawl | PASS | C:\Users\1\AppData\Roaming\npm\firecrawl.ps1 |
| CLI | gbrain | PASS | C:\Users\1\.bun\bin\gbrain.exe |
| CLI | scrapling | PASS | C:\Users\1\.local\bin\scrapling.exe |
| SKILLS | Total count | PASS | 46 (Azure: 26, New: 20) |
| SKILLS | SKILL.md files | PASS | All 46 have SKILL.md |
| KARPATHY | SKILL.md exists | PASS | C:\Users\1\.agents\skills\karpathy-guidelines |
| KARPATHY | frontmatter name | PASS | Has name field |
| KARPATHY | frontmatter description | PASS | Has description field |
| KARPATHY | Claude mirror | PASS | Mirrored to ~/.claude/skills/ |
| MIRROR | Parity | PASS | All 20 new skills mirrored to Claude Code |
| MIRROR | Claude count | INFO | 21 skills in ~/.claude/skills/ |
| DISABLED | caveman | PASS | Properly disabled |
| DOCS | README.md | PASS | 8 lines |
| DOCS | CONFLICTS.md | PASS | 4 lines |
| DOCS | MEMORY_POLICY.md | PASS | 4 lines |
| DOCS | UPDATE_POLICY.md | PASS | 3 lines |
| DOCS | SCAN_LOG.md | PASS | 22 lines |
| FORKS | JZKK720 | PASS | 22 repos |
| HELPER | install-skill.ps1 | PASS | Present |
| SKILLSPECTOR | karpathy-guidelines | PASS | SAFE (exit 0) |
| SKILLSPECTOR | hallmark | PASS | SAFE (exit 0) |
| SKILLSPECTOR | ponytail | PASS | SAFE (exit 0) |
| SKILLSPECTOR | improve | PASS | SAFE (exit 0) |

## Summary

- **PASS: 55**
- **FAIL: 0**
- **WARN/INFO: 1**

## Key Counts
- Total skills: 46 (Azure: 26, New: 20)
- Claude Code mirror: 21
- Disabled: 1
- Fork mirrors: 22
- MCP servers: 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
- CLI tools: 11

## Permanent PATH Status
- `~/.local\bin` on user PATH: YES
- `~/.bun\bin` on user PATH: YES
- `~/AppData\Roaming\npm` on user PATH: YES
- `PYTHONUTF8=1` set for user: YES

## New Skill: karpathy-guidelines
- SkillSpector: SAFE (no issues, 0 executables)
- skills-ref: Valid
- Installed to: ~/.agents/skills/karpathy-guidelines/
- Mirrored to: ~/.claude/skills/karpathy-guidelines/
- Logged in: SCAN_LOG.md
