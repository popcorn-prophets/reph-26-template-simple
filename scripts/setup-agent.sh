#!/usr/bin/env bash
# Wire .agents/ (canonical skills + MCP) into the chosen agent's expected paths.
# Usage: scripts/setup-agent.sh claude|copilot|codex|all
set -euo pipefail
cd "$(dirname "$0")/.."

link() { mkdir -p "$(dirname "$2")"; rm -rf "$2"; ln -s "$1" "$2"; echo "linked $2 -> $1"; }

# mcp <outfile> <js expr over m = parsed .agents/mcp.json>
mcp() {
  mkdir -p "$(dirname "$1")"
  node -e "const m=require('./.agents/mcp.json');console.log(JSON.stringify($2,null,2))" > "$1" && echo "wrote $1"
}

setup() {
  case "$1" in
    claude)  # CLAUDE.md already imports AGENTS.md
      link ../.agents/skills .claude/skills
      link .agents/mcp.json .mcp.json ;;
    copilot) # reads AGENTS.md + .github/copilot-instructions.md; VS Code MCP uses "servers" key
      link ../.agents/skills .github/skills
      mcp .vscode/mcp.json "{servers:m.mcpServers}" ;;
    codex)   # reads AGENTS.md + .agents/skills natively; MCP is global TOML
      echo "skills: nothing to do. MCP: add to ~/.codex/config.toml, e.g."
      echo '  [mcp_servers.shadcn]'; echo '  command = "npx"'; echo '  args = ["-y","shadcn@latest","mcp"]' ;;
    *) echo "unknown agent: $1"; exit 1 ;;
  esac
}

if [ "${1:-}" = all ]; then for a in claude copilot codex; do setup $a; done
else setup "${1:?usage: $0 claude|copilot|codex|all}"; fi
