<div align="center">

# wtclaude 🤖

### One keystroke. Right Claude session. Right worktree. Done.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![zsh](https://img.shields.io/badge/shell-zsh-89e051.svg)](https://www.zsh.org/)
[![Plugin managers](https://img.shields.io/badge/plugin-antidote%20%7C%20zinit%20%7C%20sheldon%20%7C%20omz-purple.svg)](#plugin-manager)

</div>

---

You run Claude Code in five worktrees. You forget which terminal has which.
You `cd` into the wrong one. You curse.

**`wtclaude` finds them all, groups them, and `cd`s you into the right one.**
A robot does a little dance while you pick. 🤖

```
   .-----.
   [o   o]
   /|===|\
    o   o
 ───────────────────────────────────────────────────────  v0.1.0 ─
  ~/code/myproject
  ├─ feature-login     (login flow refactor)
  ├─ bugfix-cache      (cache invalidation)
  └─ exp-new-router    (router experiment)
```

---

## ✨ Why you'll like it

- 🤖 **Animated robot mascot.** Walks, blinks, waves, dances. Press `Space` for 🎰.
- 🌳 **Worktree-aware grouping.** Sessions cluster under their parent repo as a tree.
- 💀 **Dead sessions filtered.** Only live PIDs show up.
- 🗂️ **Idle worktrees too.** Every worktree under a known repo, not just the running ones.
- ⌨️ **Pure keyboard.** Arrow keys, `j`/`k`, `Enter`, `q`. No mouse, no config.
- 🪶 **Zero dependencies** beyond `zsh` and `jq`. Pure zsh autoload — no daemon, no cache file.

---

## 🚀 Install

### One-liner

```sh
curl -fsSL https://raw.githubusercontent.com/egor-xyz/wtclaude/main/install.sh | bash
```

Re-run the same line later to update.

### Plugin manager

<details>
<summary><b>antidote / antibody</b></summary>

```zsh
antidote bundle egor-xyz/wtclaude
```
</details>

<details>
<summary><b>zinit</b></summary>

```zsh
zinit light egor-xyz/wtclaude
```
</details>

<details>
<summary><b>sheldon</b></summary>

`~/.config/sheldon/plugins.toml`:

```toml
[plugins.wtclaude]
github = "egor-xyz/wtclaude"
```
</details>

<details>
<summary><b>oh-my-zsh</b> (custom plugin)</summary>

```sh
git clone https://github.com/egor-xyz/wtclaude.git \
  ~/.oh-my-zsh/custom/plugins/wtclaude
```

Then add `wtclaude` to your `plugins=(...)` line.
</details>

<details>
<summary><b>Manual</b></summary>

```sh
git clone https://github.com/egor-xyz/wtclaude.git ~/.wtclaude
echo 'source ~/.wtclaude/wtclaude.plugin.zsh' >> ~/.zshrc
```
</details>

---

## 📋 Requirements

- `zsh` ≥ 5.0
- `jq` — `brew install jq`
- [Claude Code](https://claude.com/claude-code) (writes `~/.claude/sessions/*.json`)

---

## 🎮 Usage

```sh
wtclaude
```

| Key         | Action                            |
| ----------- | --------------------------------- |
| `↑` / `↓`   | Move selection (also `k` / `j`)   |
| `Enter`     | Pick session, `cd` into its cwd   |
| `Esc` / `q` | Quit                              |
| `Space`     | 🎰 Slot machine easter egg        |

---

## 🧠 How it works

`wtclaude` scans `~/.claude/sessions/*.json`, filters out dead sessions (PIDs
that no longer exist), groups worktree sessions under their parent repo, and
shows you an arrow-key picker. Pick one → your shell `cd`s straight into that
session's working directory.

For every repo with at least one live session, idle worktrees under
`<repo>/.claude/worktrees/*` are listed too — so you can hop into a sibling
worktree even when nothing is running there.

While you scroll, the robot does its thing.

---

## ⚙️ Settings

All optional. Set in `~/.zshrc` before sourcing the plugin.

| Variable                   | Default | Effect                                                                                                  |
| -------------------------- | ------- | ------------------------------------------------------------------------------------------------------- |
| `WTCLAUDE_NO_ROBOT`        | `0`     | `1` hides the robot mascot (faster, less whimsical).                                                    |
| `WTCLAUDE_UPDATE_CHECK`    | `0`     | `1` checks origin/main in the background; shows `↑ vX.Y.Z available` on the separator when behind.     |
| `WTCLAUDE_AUTO_UPDATE`     | `0`     | `1` auto-runs `git pull --ff-only` when an update is detected. Implies update check.                    |
| `WTCLAUDE_CHECK_INTERVAL`  | `3600`  | Seconds between background update checks. Result cached under `$XDG_CACHE_HOME/wtclaude/`.              |

```zsh
# example: silent robot, auto-update
export WTCLAUDE_NO_ROBOT=1
export WTCLAUDE_AUTO_UPDATE=1
```

## 📦 Versioning

Versions follow [Semantic Versioning](https://semver.org/) and are derived from
the latest git tag at plugin load (shown dim-grey on the picker's separator).
Releases are fully automatic: push to `main` with [Conventional
Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `feat!:`),
[`semantic-release`](https://github.com/semantic-release/semantic-release)
analyzes commits, cuts a tag, and publishes a GitHub Release with grouped
notes. No manual steps.

---

<div align="center">

Made with 🤖 by [@egor-xyz](https://github.com/egor-xyz) · MIT

</div>
