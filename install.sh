#!/usr/bin/env bash
# Install Asta Claude Code skills
#
# One-liner install (from the repo containing this script):
#   bash install.sh [--mcp-only] [--skills-only]
#
# Or via curl (replace with your fork URL if applicable):
#   REPO="https://github.com/YOUR_USERNAME/asta-claude-code"
#   curl -fsSL "$REPO/raw/main/install.sh" | bash
set -e

SKILLS_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
MCP_CONFIG="${CLAUDE_SETTINGS:-$HOME/.claude/settings.json}"

# Detect repo URL from git remote, fall back to upstream
REPO_URL=$(git -C "$(dirname "${BASH_SOURCE[0]}")" remote get-url origin 2>/dev/null | \
           sed 's|git@github.com:|https://github.com/|;s|\.git$||') || \
REPO_URL="https://github.com/TheFermiSea/asta-claude-code"

log()  { printf '\033[0;32m✓\033[0m %s\n' "$1"; }
warn() { printf '\033[0;33m⚠\033[0m %s\n' "$1"; }
err()  { printf '\033[0;31m✗\033[0m %s\n' "$1" >&2; exit 1; }

INSTALL_MCP=true
INSTALL_SKILLS=true
for arg in "$@"; do
  case $arg in
    --mcp-only)    INSTALL_SKILLS=false ;;
    --skills-only) INSTALL_MCP=false ;;
  esac
done

# --- 1. Check uv ---
if ! command -v uv &>/dev/null; then
  err "uv not found. Install it first: https://docs.astral.sh/uv/getting-started/installation/"
fi

# --- 2. Install asta MCP server ---
if $INSTALL_MCP; then
  echo "Installing asta MCP server..."
  uvx asta --version &>/dev/null && log "asta MCP server ready" || warn "Could not verify asta version"

  if command -v claude &>/dev/null; then
    claude mcp add asta -- uvx asta 2>/dev/null && log "Registered asta MCP server in Claude Code" || \
      warn "Could not auto-register MCP server. Add it manually (see README)."
  else
    warn "claude CLI not found — add the MCP server manually to $MCP_CONFIG"
    warn "  See README: $REPO_URL#2-register-it-in-claude-code"
  fi
fi

# --- 3. Install skills ---
if $INSTALL_SKILLS; then
  mkdir -p "$SKILLS_DIR"
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  if [[ -d "$SCRIPT_DIR/skills/asta-research" ]]; then
    # Running from a local clone
    cp -r "$SCRIPT_DIR/skills/asta-research" "$SKILLS_DIR/"
    cp -r "$SCRIPT_DIR/skills/asta-documents" "$SKILLS_DIR/"
  else
    # Running via curl — download from GitHub
    echo "Downloading skills from $REPO_URL ..."
    TMP=$(mktemp -d)
    curl -fsSL "$REPO_URL/archive/refs/heads/main.tar.gz" | tar -xz -C "$TMP" --strip-components=1
    cp -r "$TMP/skills/asta-research" "$SKILLS_DIR/"
    cp -r "$TMP/skills/asta-documents" "$SKILLS_DIR/"
    rm -rf "$TMP"
  fi

  log "Installed → $SKILLS_DIR/asta-research/"
  log "Installed → $SKILLS_DIR/asta-documents/"
fi

# --- 4. Optional: asta-documents CLI ---
echo
echo "Optional: install the asta-documents CLI for local document library management:"
echo "  uv tool install git+https://github.com/allenai/asta-resource-repo.git"
echo
log "Done. Restart Claude Code and try: /asta-research"
