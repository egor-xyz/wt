---
name: add-robot-animation
description: Use when adding, editing, or removing a wtclaude robot animation or state — a new pose, scene, or emoji prop for the picker mascot. Covers every wiring touchpoint so the state is reachable, correctly timed, and aligned. Symptoms it prevents: new animation never plays, is unreachable by ↑↓ stepping ("before slot I see ufo"), wraps the line, or cuts mid-loop.
---

# Adding a wtclaude robot animation

## Overview

A robot "state" (e.g. `photo`, `basketball`) is wired across **two files** and
**eight locations**. The frames live in `functions/crazy-robot`; the state must
also be registered in **two** `robot_order` lists in `functions/wtclaude` or it
plays in the random rotation but is unreachable by manual ↑↓ stepping. Missing a
touchpoint is the #1 bug — work the checklist top to bottom.

## The 8 touchpoints

All are mandatory **except #3** (`_w`), which is conditional — see below.
Reference by code anchor, not line number (numbers drift). First, pick a state
name that isn't already in `states=(…)` — collisions silently reuse frames.

### `functions/crazy-robot`
1. **Frames** — append `$'...'` frames to `idle_frames` (or `walk_frames`).
   4 lines each unless the scene needs vertical motion. Note the 1-based index
   of your first new frame.
2. **`states=(…)` array** — add your state name. This is the **random idle
   rotation** (the robot picks from here between walks). Omit and it never
   auto-plays.
3. **`_w` width-clamp `case`** — add `yourstate) _w=N ;;` **only if** the scene
   is wider than a plain robot (~10 cols incl. a side prop). `N` = total render
   width. Plain poses (no prop) need nothing. Omit when needed → the prop wraps
   at the right edge.
4. **`_robot_dur` `case`** — add a per-state duration. Make it a **whole number
   of cycles** (`(2 + RANDOM % 2) * 8` for an 8-tick cycle) so it never cuts
   mid-loop. Use `999` for scenes that end dynamically (prop leaves screen).
5. **`color` `case`** — add `yourstate) color=NNN ;;` (256-color code). The body
   stays orange; this colors the eye chars between `[...]`. There is **no `*)`
   default** — forget this and `color` is empty (broken accent escape).
6. **Render `case $_robot_state in`** — add a branch that sets `raw` to the right
   frame for `_robot_t`. Flat cycle: `raw=${idle_frames[$(( BASE + _robot_t % N ))]}`.
   New branches go **before `slot)`** (slot is the trailing easter-egg case).

### `functions/wtclaude`
7. **`robot_order` (≈ line 17)** — the `wtclaude robot` screensaver list that
   ↑↓ steps through. Add your state in the position you want.
8. **`robot_order` (≈ line 198)** — a **second, identical** list for the main
   picker's `← robot` mode. **Easy to miss.** Both must match.

> Both `robot_order` lists currently end `… ufo photo slot`. Insert new states
> before `slot` — it must stay last (Space-triggered jackpot).

## Conventions

- **`emulate -L zsh`** at top; no `set -e`/`-u`; no `print -P` (eats trailing
  `\`). Frames render via raw `printf` ANSI.
- **Body bar is `━` (U+2501)**, not `===`/`---` (ligature avoidance).
- **Emoji are 2 display cols** but 1 codepoint in the source string. Pad to
  align; the tripod/feet line under a 2-col emoji uses a 2-char glyph (`/|`).
- **Left/right variant:** roll `(( _robot_t == 0 )) && _robot_mirror=$(( RANDOM % 2 ))`
  in your branch, author a second frame set, and pick base off `_robot_mirror`
  (e.g. `${idle_frames[$(( (_robot_mirror ? 83 : 75) + _robot_t % 8 ))]}`).
- **Shared `_robot_*` vars** flow via dynamic scope from the caller. Don't make
  them globals.

## Testing (always do both)

**Sweep every tick of your cycle** and eyeball alignment in a real terminal:
```sh
for t in $(seq 0 7); do echo "--- t=$t ---"; zsh -fc "
  _robot_state=photo _robot_t=$t _robot_dur=99 _robot_pos=2 _robot_dir=1 _robot_mirror=0
  fpath=(./functions \$fpath); autoload -Uz crazy-robot; crazy-robot 40
"; done
```
Run once per orientation (`_robot_mirror=0` and `=1`). Check the prop column,
the `[eyes]`, and that nothing wraps.

**Smoke-test the picker still loads** (catches syntax errors):
```sh
zsh -fc 'fpath=(./functions $fpath); autoload -Uz wtclaude crazy-robot
  (sleep 0.6; printf "\e") | wtclaude 2>&1 | head -20'
```
Also run `zsh -n functions/crazy-robot && zsh -n functions/wtclaude`.

> The live `wtclaude robot` TUI needs a real TTY (and ideally tmux) to drive —
> piping keystrokes won't render. The per-tick sweep above exercises the same
> render path (`crazy-robot`), so it's the reliable check.

## Common mistakes

| Symptom | Cause | Fix |
|---|---|---|
| Plays randomly but ↑↓ skips it | Missed a `robot_order` list | Add to **both** (touchpoints 7 & 8) |
| Never plays at all | Not in `states=(…)` | Touchpoint 2 |
| Prop wraps / pushes off right edge | No `_w` clamp | Touchpoint 3 |
| Animation cuts mid-pose | `_robot_dur` not a whole cycle | Touchpoint 4 |
| Eyes not colored / garbled escape | Missing `color` case (no default) | Touchpoint 5 |
| Eyes not colored | Eye chars not inside `[...]` | Keep `[ … ]` around them |
| Misaligned prop | Emoji width / pad off | Sweep-test, count display cols |

## Release note

Ship via a PR whose **title** starts with `feat:` (semantic-release reads the
squash subject). See CLAUDE.md → Releases.
