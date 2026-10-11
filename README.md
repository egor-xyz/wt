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
Want a robot to dance while you pick? Install the optional
[`robot`](https://github.com/egor-xyz/robot) plugin alongside it. 🤖

<img width="1280" height="640" alt="wtclaude" src="https://github.com/user-attachments/assets/1d1b6066-c4e0-42bb-a2ec-eef0b24fcb99" />

---

## ✨ Why you'll like it

- 🌳 **Worktree-aware grouping.** Sessions cluster under their parent repo as a tree.
- 💀 **Dead sessions filtered.** Only live PIDs show up.
- 🗂️ **Idle worktrees too.** Every worktree under a known repo, not just the running ones.
- 🔎 **Search everything.** Type to filter by worktree, repo, branch, session name or path. Every word must match.
- 🧭 **Clear columns.** Each row shows the worktree, its git branch (`⎇`) and the live Claude session (`●`).
- 📌 **Pin and delete.** `→` opens a menu: go, pin to top, or delete the worktree (with confirmation).
- ⌨️ **Pure keyboard.** Arrows, `Enter`, `→` for actions, `←` for settings. Mouse works too. No config.
- 🤖 **Optional robot mascot.** Install [`robot`](https://github.com/egor-xyz/robot) and it dances in the picker while you choose.
- 🪶 **Zero dependencies** beyond `zsh` and `jq`. Pure zsh autoload — no daemon, no cache file.

---

## 🚀 Install

### One-liner

```sh
curl -fsSL https://raw.githubusercontent.com/egor-xyz/wtclaude/main/install.sh | bash
```

Re-run the same line later to update — the installer pins your local
copy to the latest [GitHub Release](https://github.com/egor-xyz/wtclaude/releases)
tag, so you always land on a published, version-tagged commit (never an
unreleased `main`).

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
| `↑` / `↓`   | Move selection                    |
| `Enter`     | Pick session, `cd` into its cwd   |
| `→`         | Open actions: go / pin / delete   |
| `←`         | Open settings                     |
| type        | Search (name, branch, session, path) |
| `Esc`       | Clear search, or quit             |
| click       | Select a row; click it again to go |
| right-click | Open actions for that row         |
| wheel       | Move selection                    |

**Delete** runs `git worktree remove` and always asks first (`y` to confirm).
If the worktree has uncommitted changes, it asks a second time before it
uses `--force`. If that still fails (for example, root-owned files), it asks a
third time before it runs `sudo rm -rf` on the worktree and then
`git worktree prune`. A locked worktree never gets the sudo step. The branch
is kept. Only worktrees under
`.claude/worktrees/` can be deleted, never the repo root.

**Pins** are saved in `~/.config/wtclaude/pins`, one path per line.

---

## 🧠 How it works

`wtclaude` scans `~/.claude/sessions/*.json`, filters out dead sessions (PIDs
that no longer exist), groups worktree sessions under their parent repo, and
shows you an arrow-key picker. Pick one → your shell `cd`s straight into that
session's working directory.

For every repo with at least one live session, idle worktrees under
`<repo>/.claude/worktrees/*` are listed too — so you can hop into a sibling
worktree even when nothing is running there.

If the optional [`robot`](https://github.com/egor-xyz/robot) plugin is
installed, its mascot dances above the list while you scroll.

---

## ⚙️ Settings

All optional. Set in `~/.zshrc` before sourcing the plugin.

| Variable                   | Default | Effect                                                                                                  |
| -------------------------- | ------- | ------------------------------------------------------------------------------------------------------- |
| `WTCLAUDE_NO_ROBOT`        | `0`     | `1` hides the robot mascot even when the [`robot`](https://github.com/egor-xyz/robot) plugin is installed. |
| `WTCLAUDE_AUTO_UPDATE`     | `0`     | `1` fetches tags and checks out the latest GitHub Release in the background, once per launch. New version visible on next invocation. |

```zsh
# example: silent robot, auto-update
export WTCLAUDE_NO_ROBOT=1
export WTCLAUDE_AUTO_UPDATE=1
```

## 📦 Versioning

Versions follow [Semantic Versioning](https://semver.org/) and are derived
from the closest annotated tag at plugin load (shown dim-grey on the picker's
separator).

Both the installer and the in-shell updater pin to the **latest published
[GitHub Release](https://github.com/egor-xyz/wtclaude/releases)** — never the
tip of `main`. Pre-releases are skipped (the `/releases/latest` endpoint
filters them out).

Releases are cut automatically: PRs use [Conventional
Commits](https://www.conventionalcommits.org/) titles (`feat:`, `fix:`,
`feat!:`), and on push to `main`
[`semantic-release`](https://github.com/semantic-release/semantic-release)
analyzes the squash-merge subject, cuts a tag, and publishes a GitHub
Release with grouped notes. A PR-title lint workflow rejects non-conforming
titles before merge.

---

<div align="center">

Made with 🤖 by [@egor-xyz](https://github.com/egor-xyz) · MIT

</div>
