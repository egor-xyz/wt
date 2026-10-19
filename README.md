<div align="center">

# wt 🤖

### One keystroke. Right Claude or Codex session. Right worktree. Done.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![zsh](https://img.shields.io/badge/shell-zsh-89e051.svg)](https://www.zsh.org/)
[![Plugin managers](https://img.shields.io/badge/plugin-antidote%20%7C%20zinit%20%7C%20sheldon%20%7C%20omz-purple.svg)](#plugin-manager)

</div>

---

You use Claude Code and Codex in five worktrees. You forget which terminal has which.
You `cd` into the wrong one. You curse.

**`wt` finds them all, groups them, and `cd`s you into the right one.**
Want a robot on the screen while you pick? Install the optional
[`robot`](https://github.com/egor-xyz/robot) plugin alongside it. 🤖

<img width="1280" height="640" alt="wt" src="https://github.com/user-attachments/assets/1d1b6066-c4e0-42bb-a2ec-eef0b24fcb99" />

---

## ✨ Why you'll like it

- 🌳 **Worktree-aware grouping.** Sessions cluster under their parent repo as a tree.
- 💀 **Dead sessions filtered.** Only live PIDs show up.
- 🗂️ **Idle worktrees too.** Every worktree under a known repo, not just the running ones.
- 🔎 **Search everything.** Type to filter by worktree, repo, branch, session name or path. Every word must match.
- 🧭 **Clear columns.** Each row shows the worktree, branch, tool (`Claude Code` or `Codex`), and session name. Live sessions use `●`. Saved sessions use `○`.
- 📌 **Pin and delete.** `→` opens a menu: go, pin to top, or delete the worktree (with confirmation).
- ⌨️ **Pure keyboard.** Arrows, `Enter`, `→` for actions, `←` for settings. Mouse works too. No config.
- 🤖 **Optional robot mascot.** Install [`robot`](https://github.com/egor-xyz/robot) to show it in the picker. The screen stays still while you wait.
- 🪶 **Zero dependencies** beyond `zsh` and `jq`. Pure zsh autoload — no daemon, no cache file.

---

## 🚀 Install

### One-liner

```sh
curl -fsSL https://raw.githubusercontent.com/egor-xyz/wt/main/install.sh | bash
```

Re-run the same line later to update — the installer pins your local
copy to the latest [GitHub Release](https://github.com/egor-xyz/wt/releases)
tag, so you always land on a published, version-tagged commit (never an
unreleased `main`).

### Plugin manager

<details>
<summary><b>antidote / antibody</b></summary>

```zsh
antidote bundle egor-xyz/wt
```
</details>

<details>
<summary><b>zinit</b></summary>

```zsh
zinit light egor-xyz/wt
```
</details>

<details>
<summary><b>sheldon</b></summary>

`~/.config/sheldon/plugins.toml`:

```toml
[plugins.wt]
github = "egor-xyz/wt"
```
</details>

<details>
<summary><b>oh-my-zsh</b> (custom plugin)</summary>

```sh
git clone https://github.com/egor-xyz/wt.git \
  ~/.oh-my-zsh/custom/plugins/wt
```

Then add `wt` to your `plugins=(...)` line.
</details>

<details>
<summary><b>Manual</b></summary>

```sh
git clone https://github.com/egor-xyz/wt.git ~/.wt
echo 'source ~/.wt/wt.plugin.zsh' >> ~/.zshrc
```
</details>

---

## 📋 Requirements

- `zsh` ≥ 5.0
- `jq` — `brew install jq`
- Claude Code or Codex with local sessions
- Git to find registered worktrees

---

## 🎮 Usage

```sh
wt
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

**Pins** are saved in `~/.config/wt/pins`, one path per line.

---

## 🧠 How it works

`wt` scans `~/.claude/sessions/*.json`, filters out dead sessions (PIDs
that no longer exist), groups worktree sessions under their parent repo, and
shows you an arrow-key picker. Pick one → your shell `cd`s straight into that
session's working directory.

Codex sessions come from `${CODEX_HOME:-~/.codex}/sessions/**/*.jsonl`.
The scan reads only each file’s first metadata line. Session names come from
`session_index.jsonl`. Child agent sessions and archived sessions are excluded.
Codex rows show `○` because saved sessions have no live process ID.

For each known repo, `git worktree list` supplies every registered worktree.
This includes `.worktrees`, `.claude/worktrees`, and worktrees outside the repo.
Missing directories are skipped.

If the optional [`robot`](https://github.com/egor-xyz/robot) plugin is
installed, its mascot appears above the list. The picker redraws only when
you press a key or click, or while it deletes a worktree.

---

## ⚙️ Settings

All optional. Set in `~/.zshrc` before sourcing the plugin.

| Variable                   | Default | Effect                                                                                                  |
| -------------------------- | ------- | ------------------------------------------------------------------------------------------------------- |
| `WT_NO_ROBOT`        | `0`     | `1` hides the robot mascot even when the [`robot`](https://github.com/egor-xyz/robot) plugin is installed. |
| `WT_AUTO_UPDATE`     | `0`     | `1` fetches tags and checks out the latest GitHub Release in the background, once per launch. New version visible on next invocation. |

```zsh
# example: silent robot, auto-update
export WT_NO_ROBOT=1
export WT_AUTO_UPDATE=1
```

## 📦 Versioning

Versions follow [Semantic Versioning](https://semver.org/) and are derived
from the closest annotated tag at plugin load (shown dim-grey on the picker's
separator).

Both the installer and the in-shell updater pin to the **latest published
[GitHub Release](https://github.com/egor-xyz/wt/releases)** — never the
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
