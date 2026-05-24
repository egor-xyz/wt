# wtclaude — zsh plugin entry point.
# Compatible with antidote, antigen, zinit, sheldon, oh-my-zsh custom plugins.
0=${(%):-%N}
WTCLAUDE_DIR=${0:A:h}
WTCLAUDE_VERSION=$(git -C "$WTCLAUDE_DIR" describe --tags --always --dirty 2>/dev/null)
WTCLAUDE_VERSION=${WTCLAUDE_VERSION#v}
# Load persisted settings (overrides env defaults)
_wtclaude_cfg=${XDG_CONFIG_HOME:-$HOME/.config}/wtclaude/settings
[[ -r $_wtclaude_cfg ]] && source "$_wtclaude_cfg"
unset _wtclaude_cfg
fpath=("$WTCLAUDE_DIR/functions" $fpath)
autoload -Uz wtclaude crazy-robot
