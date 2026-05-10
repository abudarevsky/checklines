---
name: godot-check-lines-development-agent
description: Short operating guide for agents working on Check Lines
source: /Users/andreybudarevskiy/dev/games/chessline/AGENTS.md
---

# Check Lines Agent Guide

This file is the short entrypoint for coding and reasoning agents. Detailed project rules live in `docs/AGENTS_*.md`; read only the slices relevant to the task.

## First Read

- Start with `docs/AGENTS_INDEX.md` to find the focused docs for the task.
- Read `docs/AGENTS_CURRENT_WORKING_DEFINITION.md` for the current product target.
- For gameplay changes, read the relevant rule docs before editing code.
- For UI/theme changes, read the relevant rendering, HUD, menu, layout, or dialog docs before editing scenes/scripts/resources.
- If root guidance and detailed docs disagree, treat `AGENTS.md` as the routing guide and the focused docs as the detailed rule source, then fix the drift as part of the change.

## Project Snapshot

Check Lines is a Godot 4.6 puzzle game combining classic Lines-style clearing with chess-piece movement on a fixed 8x8 board. The current design is closer to classic Lines than chess combat: players move colored chess pieces, clear lines of 5+ matching colors or 5+ matching piece types, and reveal puzzle artwork through removals.

Core constraints:

- Use `GameManager.gd` constants for board size, cell size, window size, and border width.
- Keep gameplay rules out of themes. Themes are visual presentation only.
- Use the existing PNG sprite pipeline; do not replace runtime piece rendering with procedural SVG/import logic.
- Preserve the current theme-driven HUD, main menu, dialogs, puzzle board, resize behavior, and game-over flow unless explicitly asked to redesign them.
- Keep board input centralized in `BoardManager._input()`.
- Keep movement, line detection, spawning, scoring, and visual presentation in their current ownership boundaries.

## Code Ownership

- `autoload/GameManager.gd`: constants, score, high score persistence, piece weights, global gameplay parameters.
- `scripts/board/BoardManager.gd`: board grid, selection, input handling, movement execution, highlights, occupancy.
- `scripts/board/GameBoard.gd`: game loop coordination, spawning, line detection calls, scoring updates, UI updates, game over.
- `scripts/board/SpawnPlanner.gd`: spawn-cell preference, line-avoidance placement, normal-inventory exhaustion.
- `scripts/piece/Piece.gd`: piece type, piece color, sprite setup, movement helpers.
- `scripts/chain/ChainDetector.gd`: current Lines-style detector implementation, even if the historical name says "chain".
- `autoload/ThemeManager.gd`, `scripts/theme/ThemeData.gd`, `themes/*.tres`: theme loading and visual values.
- `scripts/ui/PuzzleTileCover.gd`: puzzle-piece cover shape rendering.
- `scripts/ui/MainMenu.gd`, `scripts/ui/MainMenuBoard.gd`, `scenes/ui/MainMenu.tscn`: main menu and settings UI.

## Task Routing

- Gameplay rules: `docs/AGENTS_PROJECT_CONTEXT.md`, `docs/AGENTS_REMOVAL_RULES.md`, `docs/AGENTS_ATTACK_RULES.md`, `docs/AGENTS_KING_RULES.md`, `docs/AGENTS_MOVE_VALIDATION.md`, `docs/AGENTS_LINE_DETECTION.md`.
- Spawning and inventory: `docs/AGENTS_PIECE_DISTRIBUTION.md`, `docs/AGENTS_GAME_STATE_OWNERSHIP.md`.
- Scoring and HUD messages: `docs/AGENTS_SCORING_RULES.md`, `docs/AGENTS_HUD_PUZZLE_BOARD.md`.
- Theme or rendering changes: `docs/AGENTS_RENDERING.md`, `docs/AGENTS_CONSTANTS.md`.
- Main menu, dialogs, resize, and UI layout: `docs/AGENTS_MAIN_MENU.md`, `docs/AGENTS_DIALOGS.md`, `docs/AGENTS_RESIZE_LAYOUT.md`, `docs/AGENTS_HUD_PUZZLE_BOARD.md`.
- Input and highlighting: `docs/AGENTS_INPUT_HANDLING.md`, `docs/AGENTS_HIGHLIGHTING.md`.
- Repo workflow and validation: `docs/AGENTS_DEVELOPMENT_RULES.md`, `docs/AGENTS_TESTING.md`.

## Editing Rules

- Inspect existing files before editing; do not assume paths from memory.
- Prefer small scoped changes over broad rewrites.
- Preserve working behavior unless the user explicitly changes the product rule.
- Do not overwrite, discard, revert, or replace existing work unless the user explicitly confirms that exact action.
- Do not commit changes unless the user explicitly confirms the commit.
- Do not hardcode board dimensions, visual theme values, or gameplay constants outside their owner modules.
- Do not move click handling into piece `input_event` callbacks.
- Do not turn theme resources into gameplay configuration.
- Do not remove or bypass the PNG sprite approach.
- Do not leave root `AGENTS.md` and `docs/AGENTS_*.md` inconsistent after changing guidance.

## Validation

Use the local Godot binary if available:

```bash
GODOT_BIN=${GODOT_BIN:-/Applications/Godot.app/Contents/MacOS/Godot}
"$GODOT_BIN" --path . --script-check
```

Focused headless tests exist under `tests/`. Prefer the relevant test script for gameplay changes, for example:

```bash
GODOT_BIN=${GODOT_BIN:-/Applications/Godot.app/Contents/MacOS/Godot}
"$GODOT_BIN" --headless --path . -s tests/chain_detector_test.gd
"$GODOT_BIN" --headless --path . -s tests/scoring_events_test.gd
"$GODOT_BIN" --headless --path . -s tests/spawn_behavior_test.gd
"$GODOT_BIN" --headless --path . -s tests/puzzle_theme_test.gd
```

If a check cannot run because of local Godot, filesystem, signing, or platform tooling issues, report the blocker separately from code correctness.
