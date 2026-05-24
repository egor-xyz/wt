# wtclaude 🤖

Jump between running Claude Code sessions and their git worktrees with a single
keystroke. Animated robot mascot included. 🤖

```
   .-----.
   [o   o]
   /|===|\
    o   o

  ~/code/myproject  (-)
  ├─ feature-login    (login flow refactor)
  ├─ bugfix-cache     (cache invalidation)
  └─ exp-new-router   (router experiment)
```

## What it does

`wtclaude` scans `~/.claude/sessions/*.json`, filters out dead sessions, groups
worktree sessions under their parent repo, and shows an arrow-key picker. Pick
one → your shell `cd`s straight into that session's working directory.

While you scroll, an animated robot walks around the top of the screen, blinks,
waves, dances, surprises, jumps, and occasionally lights up the slot machine.

## Install

### One-liner

```sh
curl -fsSL https://raw.githubusercontent.com/egor-xyz/wtclaude/main/install.sh | bash
```

Re-run the same line later to update.

### Plugin manager

**antidote / antibody**

```zsh
antidote bundle egor-xyz/wtclaude
```

**zinit**

```zsh
zinit light egor-xyz/wtclaude
```

**sheldon** (`~/.config/sheldon/plugins.toml`)

```toml
[plugins.wtclaude]
github = "egor-xyz/wtclaude"
```

**oh-my-zsh** (custom plugin)

```sh
git clone https://github.com/egor-xyz/wtclaude.git \
  ~/.oh-my-zsh/custom/plugins/wtclaude
```

then add `wtclaude` to your `plugins=(...)` line.

### Manual

```sh
git clone https://github.com/egor-xyz/wtclaude.git ~/.wtclaude
echo 'source ~/.wtclaude/wtclaude.plugin.zsh' >> ~/.zshrc
```

## Requirements

- zsh ≥ 5.0
- `jq` (`brew install jq`)
- Claude Code (writes `~/.claude/sessions/*.json`)

## Usage

```
wtclaude
```

Keys:

| Key       | Action                                |
| --------- | ------------------------------------- |
| ↑ / ↓     | Move selection (also `k` / `j`)        |
| Enter     | Pick session, cd into its cwd          |
| Esc / `q` | Quit                                   |
| Space     | 🎰 Slot machine easter egg             |

## License

MIT
