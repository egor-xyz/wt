#!/usr/bin/env bash
# wtclaude one-liner installer.
#   curl -fsSL https://raw.githubusercontent.com/egor-xyz/wtclaude/main/install.sh | bash
set -euo pipefail

DEST="${WTCLAUDE_DIR:-$HOME/.wtclaude}"
REPO="https://github.com/egor-xyz/wtclaude.git"
ZSHRC="${ZDOTDIR:-$HOME}/.zshrc"
LINE="source \"$DEST/wtclaude.plugin.zsh\""

RELEASES_API="https://api.github.com/repos/egor-xyz/wtclaude/releases/latest"

latest_release_tag() {
  curl -fsSL --max-time 10 "$RELEASES_API" 2>/dev/null \
    | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -1
}

if [ -d "$DEST/.git" ]; then
  echo "→ updating $DEST"
  git -C "$DEST" fetch --tags --quiet origin
else
  echo "→ cloning into $DEST"
  git clone --quiet "$REPO" "$DEST"
fi

# `|| true`: under `set -euo pipefail` a curl/sed pipeline failure (no network,
# API rate limit) would otherwise abort the installer here — before the .zshrc
# source line is appended — leaving a silent half-install. Fall through instead.
LATEST=$(latest_release_tag || true)
if [ -n "$LATEST" ]; then
  echo "→ checking out release $LATEST"
  git -C "$DEST" checkout --quiet "$LATEST"
else
  echo "⚠  could not resolve latest release (no network or API limit); leaving HEAD as-is"
fi

if [ ! -f "$ZSHRC" ] || ! grep -qsF "$LINE" "$ZSHRC"; then
  echo "$LINE" >> "$ZSHRC"
  echo "→ added source line to $ZSHRC"
else
  echo "→ $ZSHRC already sources wtclaude"
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "⚠  jq not found — install it: brew install jq"
fi

echo "✓ installed. reload: source $ZSHRC && wtclaude"
