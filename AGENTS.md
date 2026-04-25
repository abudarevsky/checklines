---
name: godot-check-lines-development-agent
description: Godot development guide for Check Lines using opencode with qwen3-coder:30b via Ollama
source: /Users/andreybudarevskiy/dev/games/chessline/AGENTS.md
---

# Check Lines - Agent Development Guide

## Project Context

Check Lines is a Godot 4.6 puzzle game combining classic Lines-style clearing with chess-piece movement.

The player moves chess pieces on a 9x9 board. Pieces move according to chess-inspired movement rules, but they do not capture by moving onto occupied cells. The goal is to create removable lines of 5+ pieces.

The current design direction is closer to classic Lines than chess combat.

## Current Target Game Rules

### Color Palette

Puzzle colors for pieces and borders:

- RED, BLUE, GREEN, ORANGE
- Border colors: Left=RED, Top=BLUE, Right=GREEN, Bottom=ORANGE
- Border width: 3 pixels

### Board

- Board size: 9x9
- Board cells: Light gray / Dark gray (neutral colors)
- Pieces occupy grid cells
- Pieces move only to empty cells
- Game ends when no meaningful moves remain or the board is full

### Piece Types

Supported piece types:

- Pawn
- Knight
- Bishop
- Rook
- Queen
- King

Piece type defines movement.

### Colors

Pieces have puzzle colors.

Color defines one type of removable line.

Do not use White/Black faction combat as the main rule anymore.

### Removal Rules

A line is removed when it contains 5 or more aligned pieces.

There are two valid line types:

1. Color line  
   - 5+ pieces of the same color
   - piece type does not matter
   - normal score

2. Type line  
   - 5+ pieces of the same chess type
   - color does not matter
   - double score

If a line satisfies both color and type match, apply a combo bonus.

### Spawn Rule

- Start with 3 random pieces
- After each player move, spawn 3 new random pieces
- Preview next 3 pieces if implemented
- Spawned pieces may complete normal Lines-style removals

### Movement Rule

- Player selects a piece
- Valid empty destination cells are highlighted
- Player moves selected piece to a highlighted empty cell
- Movement uses chess-inspired rules
- Movement and line-clearing are separate systems

### Pawn Rule

Pawn should not depend on White/Black sides in the multicolor version.

Target pawn rule:

- Pawn is a restricted connector piece
- Pawn can move toward a nearby same-color piece
- If there is no same-color piece within 1 cell, pawn cannot move
- Pawn behavior should support line-building, not chess faction logic

Keep pawn simple and readable.

### King Rule

King is a rare special piece.

Possible target role:

- wildcard / joker-like piece
- only limited number of kings should exist
- king should help difficult line completion
- king should not introduce separate king-attack gameplay

Do not build current features around attacking or defending kings.

## Current Architecture

### Godot Version

- Godot 4.6 stable

### Main Structure

- `autoload/`
  - global managers
  - `GameManager`
  - `AudioManager`
  - `Settings`

- `scenes/`
  - board and gameplay scenes
  - `BoardManager`
  - `GameBoard`
  - `Piece`
  - `MainMenu`

- `scripts/`
  - game logic
  - line detection
  - supporting systems

- `assets/sprites/`
  - chess piece SVG sources
  - rendered PNG sprites

## Global Constants

Use `GameManager.gd` constants.

Do not hardcode board or cell sizes.

Expected constants:

```gdscript
const BOARD_SIZE: int = 9
const CELL_SIZE: int = 100
const BOARD_PIXEL_SIZE: int = BOARD_SIZE * CELL_SIZE
const WINDOW_WIDTH: int = BOARD_PIXEL_SIZE
const WINDOW_HEIGHT: int = BOARD_PIXEL_SIZE
const BORDER_WIDTH: int = 3
```

### Color Mapping

```gdscript
enum PieceColor { RED, BLUE, GREEN, ORANGE }

const COLOR_MAP: Dictionary = {
	PieceColor.RED: Color.RED,
	PieceColor.BLUE: Color.BLUE,
	PieceColor.GREEN: Color.GREEN,
	PieceColor.ORANGE: Color.ORANGE
}
```

## Rendering Principles

Current project uses PNG sprites.

Do not replace PNG rendering with procedural drawing unless explicitly requested.

Tint white PNG sprites using `sprite.modulate` for piece color.

Use existing assets from:

```text
assets/sprites/
```

Avoid Godot SVG import dependency for runtime rendering.

## Input Handling

Keep input centralized in:

```text
BoardManager._input()
```

Do not move gameplay click logic into `Area2D.input_event` unless explicitly requested.

Expected flow:

1. Convert mouse world position to grid position
2. If clicking a piece, select it
3. Show valid move highlights
4. If clicking a highlighted empty cell, move selected piece
5. Clear highlights
6. Resolve line clearing
7. Spawn new pieces

Use:

```gdscript
world_to_grid()
```

for grid conversion.

## Move Validation

Keep movement and clearing logic separate.

### `Piece.gd`

Responsible for:

- piece type
- piece color
- movement rules
- helper methods for legal movement

Expected method:

```gdscript
get_legal_moves()
```

Returns empty destination cells only.

Do not make normal movement capture pieces.

### Attack / Capture Logic

Older logic may include:

```gdscript
get_legal_captures()
```

This can remain for experiments or future mechanics, but the current target design should prioritize Lines-style clearing, not attack-chain clearing.

Do not use alternating-color attack chains as the main mechanic unless explicitly requested again.

## Line Detection

Replace or refactor old chain detection toward Lines-style detection.

Target detector should find:

- horizontal lines
- vertical lines
- diagonal lines if desired
- 5+ same-color pieces
- 5+ same-type pieces

Recommended naming:

```text
LineDetector.gd
```

or refactor existing:

```text
ChainDetector.gd
```

into clearer Lines-style logic.

### Detection Rules

A valid line can be:

```text
same color, any type
same type, any color
```

Do not require pieces to attack each other for removal in the current target design.

## Highlighting

Highlights are part of gameplay communication.

Current working approach:

- Add `ColorRect` highlights to `PiecesContainer`
- Use highlights for valid moves
- Clear highlights on deselection or after move

Keep this approach unless there is a strong reason to change it.

Possible highlight types:

- valid move cells
- selected piece
- completed line preview
- incomplete 4-of-5 line hint, optional

## Game State Ownership

### `GameManager.gd`

Owns:

- global constants
- score
- high score persistence
- piece weights
- global gameplay parameters

### `BoardManager.gd`

Owns:

- board grid
- piece positions
- selection state
- input handling
- move execution
- move highlights
- board occupancy

### `GameBoard.gd`

Owns or coordinates:

- game loop
- spawning
- line detection call
- score updates
- UI updates
- game-over condition

### `Piece.gd`

Owns:

- piece type
- piece color
- sprite setup
- movement logic

## Scoring Rules

Suggested scoring:

- Color line: base score
- Type line: double score
- Same color + same type line: combo score
- Multiple lines in one move: combo multiplier

Keep scoring readable.

Avoid hidden bonuses that the player cannot understand.

## Piece Distribution

Use weighted random generation.

Suggested identity:

- Pawns: common
- Knights/Bishops/Rooks: medium
- Queens: rare
- Kings: very rare

Piece distribution should support board variety without making powerful pieces too common.

## Development Rules for opencode / qwen3-coder

### Before Editing

Always inspect existing files before changing them.

Check at least:

```text
autoload/GameManager.gd
scenes/BoardManager.gd
scenes/Piece.gd
scenes/GameBoard.gd
scripts/ChainDetector.gd
```

Actual paths may differ; search the repo before editing.

### When Refactoring

Prefer small safe changes.

Do not rewrite the whole game loop unless explicitly requested.

Preserve working behavior:

- click selection
- valid move highlighting
- movement to empty cells
- spawning
- score updates
- game-over flow

### When Changing Rules

Update only the relevant system:

- movement changes → `Piece.gd`
- board selection/movement → `BoardManager.gd`
- spawning/scoring/game loop → `GameBoard.gd`
- global values → `GameManager.gd`
- line detection → detector script

### Avoid

Do not:

- hardcode board size or cell size
- reintroduce capture-by-moving-onto-piece
- rely on White/Black faction attack logic for core clearing
- remove PNG rendering
- scatter input logic across piece nodes
- create hidden full-board effects that are hard to explain
- make pawn movement too chess-realistic for the multicolor puzzle version

## Testing

### Quick Syntax Check (2-3 seconds)
```bash
"/Applications/Godot.app/Contents/MacOS/Godot" --path . --script-check
```

### Headless Run with Output Capture
```bash
"/Applications/Godot.app/Contents/MacOS/Godot" --path . --script-check > /tmp/output.txt 2>&1 &
GPID=$!; sleep 10; kill $GPID; cat /tmp/output.txt
```

### Debug Output
Debug `print()` statements appear in terminal/console when running headless.

Run from command line:

```bash
GODOT="/Applications/Godot.app/Contents/MacOS/Godot"
"$GODOT" --path .
```

Open editor:

```bash
GODOT="/Applications/Godot.app/Contents/MacOS/Godot"
"$GODOT" --editor --path .
```

### Manual Test Checklist

Core functionality:
1. Game starts
2. 3 random pieces appear
3. Clicking a piece selects it
4. Valid empty moves are highlighted
5. Clicking a highlighted cell moves the piece
6. Completed color lines of 5+ are removed
7. Completed type lines of 5+ are removed
8. Type lines score more than color lines
9. 3 new pieces spawn after a move
10. Board state remains consistent
11. Game-over condition still works

Attack highlighting:
12. Attack overlays display attacker sprite on target pieces
13. Attack borders show attacker color on target cell
14. Target pieces dimmed (0.35 opacity) when selectable
15. Overlays disappear on piece deselection
16. Pawn moves in correct direction (away from home border)

UI:
17. Main menu centered with dark panel and board visible beneath
18. HowToPlay panel fully opaque

## Current Working Definition

Check Lines is a Lines-style puzzle game where colored chess pieces are moved using chess-inspired movement rules. The player clears lines of 5+ matching colors or 5+ matching piece types. Color lines are standard clears, while harder type lines give double score.
