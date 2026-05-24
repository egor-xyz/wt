#!/usr/bin/env bash
# wtclaude one-liner installer.
#   curl -fsSL https://raw.githubusercontent.com/egor-xyz/wtclaude/main/install.sh | bash
set -euo pipefail

DEST="${WTCLAUDE_DIR:-$HOME/.wtclaude}"
REPO="https://github.com/egor-xyz/wtclaude.git"
ZSHRC="${ZDOTDIR:-$HOME}/.zshrc"
LINE="source \"$DEST/wtclaude.plugin.zsh\""

if [ -d "$DEST/.git" ]; then
  echo "→ updating $DEST"
  git -C "$DEST" pull --ff-only
else
  echo "→ cloning into $DEST"
  git clone --depth 1 "$REPO" "$DEST"
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
