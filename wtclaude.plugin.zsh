# wtclaude — zsh plugin entry point.
# Compatible with antidote, antigen, zinit, sheldon, oh-my-zsh custom plugins.
0=${(%):-%N}
WTCLAUDE_DIR=${0:A:h}
WTCLAUDE_VERSION=$(git -C "$WTCLAUDE_DIR" describe --tags --abbrev=0 2>/dev/null \
  || git -C "$WTCLAUDE_DIR" describe --tags --always 2>/dev/null)
WTCLAUDE_VERSION=${WTCLAUDE_VERSION#v}
# Backfill tags on shallow clones so future invocations show real version.
if [[ -f $WTCLAUDE_DIR/.git/shallow ]]; then
  ( git -C "$WTCLAUDE_DIR" fetch --unshallow --tags --quiet 2>/dev/null ) &!
fi
# Load persisted settings (overrides env defaults)
_wtclaude_cfg=${XDG_CONFIG_HOME:-$HOME/.config}/wtclaude/settings
[[ -r $_wtclaude_cfg ]] && source "$_wtclaude_cfg"
unset _wtclaude_cfg
fpath=("$WTCLAUDE_DIR/functions" $fpath)
# Drop any previously cached autoload bodies so re-sourcing this file
# (e.g. after `git pull`) picks up the new function definitions.
unfunction wtclaude 2>/dev/null
autoload -Uz wtclaude
WTCLAUDE_LOADED_AT=$(date +%s)
