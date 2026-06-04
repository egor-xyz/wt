# CLAUDE.md

Guidance for Claude Code (and humans) working in this repo.

## What this is

`wtclaude` is a tiny zsh plugin that lists running Claude Code sessions and lets
the user pick one to `cd` into. It's session/worktree navigation, not a
framework.

The picker shows an animated robot mascot while you choose — but that mascot now
lives in a **separate, optional** plugin,
[`egor-xyz/robot`](https://github.com/egor-xyz/robot). If that plugin is
installed it provides the `crazy-robot` function and wtclaude renders the dance;
if not, the picker simply runs without it. wtclaude ships no robot code of its
own.

## Layout

```
wtclaude.plugin.zsh   plugin manager entry — sets fpath + autoloads
install.sh            curl one-liner installer (clones to ~/.wtclaude, patches .zshrc)
functions/wtclaude    main command: picker that reads ~/.claude/sessions/*.json
```

Function files use zsh autoload convention: file name = function name, no
`function foo()` wrapper, body is the function body. First line is the
`#autoload` marker comment.

## Conventions

- **zsh only.** No bash compat targeting. `emulate -L zsh` at top of every
  function — keeps options isolated from the user's shell.
- **`setopt typeset_silent`** — without it, `local var` (no value) prints the
  variable's current declaration. This burned us; keep it.
- **No `print -P`** for content that may contain `\` (eats trailing backslash
  as line continuation). Use `printf '\e[...m%s\e[39m\n'` with raw ANSI. The
  picker's colored chrome uses `print -P` only because it has no backslashes.
- **Optional robot mascot.** wtclaude calls `crazy-robot` only when it exists
  (`(( ${+functions[crazy-robot]} ))`) — i.e. when the `egor-xyz/robot` plugin
  is installed. The `_robot_*` locals declared in `wtclaude` are the
  dynamic-scope contract `crazy-robot` reads/writes; keep them local, and keep
  every robot call behind the guard so the picker works without the plugin.

## Robot animations

The robot lives in its own repo now — animations are added there, not here. See
[`egor-xyz/robot`](https://github.com/egor-xyz/robot) and its
`add-robot-animation` skill. wtclaude only *calls* `crazy-robot` (when the plugin
is present); it ships no frames.

## Testing

There is no test suite — this is a TUI plugin. To smoke-test:

```sh
zsh -fc '
  fpath=(./functions $fpath)
  autoload -Uz wtclaude
  (sleep 0.6; printf "\e") | wtclaude 2>&1 | head -20
'
```

The robot mascot can't be previewed from this repo (it lives in
[`egor-xyz/robot`](https://github.com/egor-xyz/robot)). To see the dance in the
picker, install that plugin alongside wtclaude.

## Distribution

Two install paths must keep working:

1. **`install.sh`** — `curl … | bash`. Clones to `~/.wtclaude`, appends a
   `source ...wtclaude.plugin.zsh` line to `~/.zshrc`. Idempotent.
2. **Plugin managers** — antidote, zinit, sheldon, oh-my-zsh. They source
   `*.plugin.zsh`, so `wtclaude.plugin.zsh` is the contract. Keep it minimal:
   compute its own dir, prepend `functions/` to `fpath`, `autoload -Uz` the
   public names.

Don't add a brew formula unless we cut tagged releases.

## What not to do

- Don't replace raw `printf` with `print -P` for anything containing `\`.
- Don't add `set -e` / `set -u` to the zsh functions; they break things in
  surprising ways under autoload.
- Don't pull in dependencies. The only runtime deps are `zsh` and `jq`.
- Don't re-embed the robot. It's a separate plugin now; call `crazy-robot` only
  behind the `(( ${+functions[crazy-robot]} ))` guard.

## Git

- Commits use the `i@egor.xyz` identity locally (`git config user.email`
  set per-repo).
- Default branch: `main`.

## Releases (semantic-release)

Releases are cut automatically by `.github/workflows/bump-version.yml` on
every push to `main`. The workflow runs `semantic-release` with the
`conventionalcommits` preset (config: `.releaserc.json`). The installer
and the in-shell updater both pin to the latest GitHub Release tag, so
a missing release means users do not get the change.

**Conventional commit prefixes that bump versions:**

| Prefix     | Bump  |
|------------|-------|
| `feat:`    | minor |
| `fix:`     | patch |
| `perf:`    | patch |
| `BREAKING CHANGE:` in body, or `feat!:` / `fix!:` | major |
| `chore:` / `docs:` / `refactor:` / `test:` / `ci:` / `build:` / `style:` | **no release** |

**The squash-merge subject must carry the prefix.** GitHub's default
squash setting uses the PR title as the commit subject — so the PR
*title* must be a conventional commit. A `feat:` prefix on the local
branch commit is dropped during squash if the PR title doesn't have it.

Rules when opening a PR:

1. PR title starts with `feat:` / `fix:` / `chore:` / etc. — same form
   as the commit subject would take.
2. If the change ships user-visible behavior, use `feat:` or `fix:`.
3. If the change is internal (CI, docs, refactor, deps), use a no-release
   prefix on purpose — semantic-release will skip it, which is correct.
4. After merge, check the `Release` workflow run. If it logs
   `Analysis of N commits complete: no release` when you expected one,
   the PR title was wrong. Recover by pushing an empty `feat:`/`fix:`
   commit to `main` (`git commit --allow-empty -m '…'`) or by cutting
   the release manually via `gh release create`.
