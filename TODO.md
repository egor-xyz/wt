# TODO

- iTerm2 (friend's setup): no robot animation, picker looks different. Cause:
  fzf installed → fzf branch (functions/wtclaude:67) used instead of native
  picker. fzf path skips `crazy-robot` and shows raw cwd paths, no tree
  grouping. Decide: always use native picker, or port animation/tree to fzf
  (e.g. `--preview` for robot, pre-format labels for tree indent).
- Show idle worktrees too, not just sessions with live pid. Enumerate
  `<repo>/.claude/worktrees/*` (repos derived from session cwds or scanned).
