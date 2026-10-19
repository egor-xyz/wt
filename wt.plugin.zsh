# wt — zsh plugin entry point.
# Compatible with antidote, antigen, zinit, sheldon, oh-my-zsh custom plugins.
0=${(%):-%N}
WT_DIR=${0:A:h}
WT_VERSION=$(git -C "$WT_DIR" describe --tags --abbrev=0 2>/dev/null \
  || git -C "$WT_DIR" describe --tags --always 2>/dev/null)
WT_VERSION=${WT_VERSION#v}
# Backfill tags on shallow clones so future invocations show real version.
if [[ -f $WT_DIR/.git/shallow ]]; then
  ( git -C "$WT_DIR" fetch --unshallow --tags --quiet 2>/dev/null ) &!
fi
# Load persisted settings (overrides env defaults)
_wt_cfg=${XDG_CONFIG_HOME:-$HOME/.config}/wt/settings
[[ -r $_wt_cfg ]] && source "$_wt_cfg"
unset _wt_cfg
fpath=("$WT_DIR/functions" $fpath)
# Drop any previously cached autoload bodies so re-sourcing this file
# (e.g. after `git pull`) picks up the new function definitions.
unfunction wt _wt_scan 2>/dev/null
autoload -Uz wt
WT_LOADED_AT=$(date +%s)
