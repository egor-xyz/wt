# Compatibility entry for shells that still use the old source path.
source "${${(%):-%N}:A:h}/wt.plugin.zsh"
unfunction wtclaude 2>/dev/null
autoload -Uz wtclaude
