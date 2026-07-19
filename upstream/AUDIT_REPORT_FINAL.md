# Full Audit Report — Final

Generated: 2026-07-18 17:15

## Overall Results

| Category | Total | PASS | FAIL | WARN/ADVISORY |
|---|---|---|---|---|
| MCP Servers (JSON) | 6 | 6 | 0 | 0 |
| MCP Servers (daemon) | 6 | 6 | 0 | 0 |
| CLI Tools | 10 | 10 | 0 | 0 |
| Skills-ref validation | 47 | 43 | 0 | 4 advisory |
| Skill files (SKILL.md) | 47 | 47 | 0 | 0 |
| Claude Code mirror | 21 | 21 | 0 | 0 (Azure skills not mirrored by design) |
| Disabled skills | 1 | 1 | 0 | 0 |
| Governance docs | 5 | 5 | 0 | 0 |
| Fork mirrors | 22 | 22 | 0 | 0 |
| Install helper | 1 | 1 | 0 | 0 |
| SkillSpector sample scans | 3 | 3 | 0 | 0 |
| **TOTAL** | **169** | **165** | **0** | **4 advisory** |

## MCP Server Daemon Smoke Tests

| Server | Command | Verdict | Detail |
|---|---|---|---|
| markitdown | `uvx markitdown-mcp@latest` | PASS | Daemon started (err=294B: ffmpeg warning, non-fatal) |
| skillspector | `skillspector mcp` | PASS | Daemon started (err=0B, clean) |
| firecrawl | `npx -y firecrawl-mcp@latest` | PASS | Daemon started (err=245B: "keyless mode" info, not error) |
| scrapling | `scrapling mcp` | PASS | Daemon started (err=0B, clean) — **FIXED**: was `uvx scrapling[ai]`, changed to `scrapling mcp` |
| gbrain | `gbrain serve` | PASS | Daemon started (err=38B: "Starting GBrain MCP server (stdio)...") |
| graphify | `graphify-mcp --transport stdio` | PASS | Daemon started (err=0B, clean) — **FIXED**: reinstalled with `[mcp]` extra, added `--transport stdio` arg |

### Fixes applied during audit
1. **scrapling**: Changed from `uvx scrapling[ai]` (which showed help text instead of starting MCP) to `scrapling mcp` (installed as uv tool with proper subcommand).
2. **graphify**: Reinstalled `graphifyy` as `graphifyy[mcp]` (the base package was missing the `mcp` Python module). Added `--transport stdio` args to the mcp.json entry.

## CLI Tools

| CLI | Version | Verdict |
|---|---|---|
| skillspector | v2.3.13 | PASS |
| skills-ref | v0.1.0 | PASS |
| specify | 0.13.0 | PASS |
| skillopt-eval | (help output) | PASS |
| agent-reach | v1.5.0 | PASS |
| graphify | 0.9.18 | PASS |
| markitdown | (ffmpeg warning, works) | PASS |
| uipro | 2.11.0 | PASS |
| firecrawl | 1.19.26 | PASS |
| gbrain | 0.42.62.0 | PASS |

## Skills-ref Validation Advisories (4 of 47 — all cosmetic)

| Skill | Issue | Impact |
|---|---|---|
| airunway-aks-setup | Has `argument-hint` field (not in allowed list) | None — pre-existing Azure skill, works fine |
| hallmark | Has `version` at top level instead of `metadata.version` | None — VS Code Copilot discovers it fine |
| ponytail | Has `argument-hint` field | None — common spec extension |
| taste-skill | Directory name `taste-skill` ≠ frontmatter `name: design-taste-frontend` | None — discovered by folder name |

All 4 are frontmatter spec-drift issues that don't affect skill discovery or functionality. The Agent Skills spec allows extensions; `argument-hint` and `version` are widely used but not in the strict allowed-fields list.

## Claude Code Mirror

- 21 skills mirrored to `~/.claude/skills/` (all 20 new skills + caveman disabled)
- 27 Azure skills NOT mirrored by design (they're VS Code Copilot-specific, installed via the Azure bundle)
- **Parity: PASS** for all user-installed skills

## Counts

- Total skills in `~/.agents/skills/`: 47 (Azure: 27, New: 20)
- Disabled: 1 (caveman, properly disabled with SKILL.md.disabled)
- Claude Code mirror: 21
- Fork mirrors: 22
- Governance docs: 5 (README.md, CONFLICTS.md, MEMORY_POLICY.md, UPDATE_POLICY.md, SCAN_LOG.md)
- Install helper: 1 (install-skill.ps1, 145 lines)

## SkillSpector Sample Scans

| Skill | Verdict | Exit Code |
|---|---|---|
| hallmark | SAFE | 0 |
| ponytail | SAFE | 0 |
| improve | SAFE | 0 |

## Blocked Skills (from implementation phase — not re-scanned)

| Skill | Reason |
|---|---|
| brainstorming | YR1+TM1: tool parameter abuse in stop-server.sh |
| last30days | YR1: info_stealer in cookies.js |
| ui-ux-pro-max | P6: prompt extraction + TM3: unsafe defaults |
| anysearch | SC4: vulnerable requests==2.20 (8 CVEs) |
| EverOS | Windows incompatible (fcntl module) |

## Conclusion

**All implementations are working.** 0 failures across 169 checks. 4 advisory notes are cosmetic frontmatter spec-drift with no functional impact. 2 MCP server issues found during audit were fixed (scrapling subcommand, graphify mcp extra). The full stack is operational.