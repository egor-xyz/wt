# wtclaude — zsh plugin entry point.
# Compatible with antidote, antigen, zinit, sheldon, oh-my-zsh custom plugins.
0=${(%):-%N}
WTCLAUDE_DIR=${0:A:h}
WTCLAUDE_VERSION=$(git -C "$WTCLAUDE_DIR" describe --tags --abbrev=0 2>/dev/null)
WTCLAUDE_VERSION=${WTCLAUDE_VERSION#v}
fpath=("$WTCLAUDE_DIR/functions" $fpath)
autoload -Uz wtclaude crazy-robot
