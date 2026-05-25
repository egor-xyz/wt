# CLAUDE.md

Guidance for Claude Code (and humans) working in this repo.

## What this is

`wtclaude` is a tiny zsh plugin that lists running Claude Code sessions and lets
the user pick one to `cd` into. It's session/worktree navigation, not a
framework.

The animated robot in the picker (`crazy-robot`) is a deliberate, load-bearing
part of the UX. Don't strip it out in the name of "cleanup".

## Layout

```
wtclaude.plugin.zsh   plugin manager entry — sets fpath + autoloads
install.sh            curl one-liner installer (clones to ~/.wtclaude, patches .zshrc)
functions/wtclaude    main command: picker that reads ~/.claude/sessions/*.json
functions/crazy-robot animation component, called per frame by wtclaude
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
  as line continuation). Use `printf '\e[...m%s\e[39m\n'` with raw ANSI.
- **Frame strings** are `$'...'` quoted, 4 lines unless an animation needs
  vertical motion (jump, jackpot). Width should align so leading pad applies
  uniformly.
- **Emoji are 2-column.** Slot-machine frames widen the body bars to match.
  If you add new emoji frames, re-render and eyeball alignment in a real
  terminal.
- **Shared state with the robot** flows through `_robot_*` locals declared in
  `wtclaude` and read/written by `crazy-robot` via dynamic scoping. Don't
  promote these to globals.

## Adding a new robot animation

1. Add the frame(s) to `walk_frames` or `idle_frames` in `functions/crazy-robot`.
2. Add the state name to the `states=(...)` array.
3. Add a case branch picking the frame and (optionally) a color.
4. If the state needs multi-tick choreography (spin-then-hold, fireworks,
   etc.), keep state in `_robot_*` vars and gate on `_robot_t`.

## Testing

There is no test suite — this is a TUI plugin. To smoke-test:

```sh
zsh -fc '
  fpath=(./functions $fpath)
  autoload -Uz wtclaude crazy-robot
  (sleep 0.6; printf "\e") | wtclaude 2>&1 | head -20
'
```

To preview a single robot frame:

```sh
zsh -fc '
  _robot_state=jump _robot_t=0 _robot_dur=10 _robot_pos=0 _robot_dir=1
  fpath=(./functions $fpath)
  autoload -Uz crazy-robot
  crazy-robot 30
'
```

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

- Don't reformat the ASCII robot frames — alignment is fragile.
- Don't replace `printf` with `print -P` (see above).
- Don't add `set -e` / `set -u` to the zsh functions; they break things in
  surprising ways under autoload.
- Don't pull in dependencies. The only runtime deps are `zsh` and `jq`.

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
