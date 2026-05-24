# wtclaude — zsh plugin entry point.
# Compatible with antidote, antigen, zinit, sheldon, oh-my-zsh custom plugins.
0=${(%):-%N}
WTCLAUDE_DIR=${0:A:h}
fpath=("$WTCLAUDE_DIR/functions" $fpath)
autoload -Uz wtclaude crazy-robot
