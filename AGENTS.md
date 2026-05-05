---
name: godot-check-lines-development-agent
description: Godot development guide for Check Lines using opencode with qwen3-coder:30b via Ollama
source: /Users/andreybudarevskiy/dev/games/chessline/AGENTS.md
---

# Check Lines - Agent Development Guide

## Project Context

Check Lines is a Godot 4.6 puzzle game combining classic Lines-style clearing with chess-piece movement.

The player moves chess pieces on a fixed 8x8 board. Pieces move according to chess-inspired movement rules, can capture eligible opposing-color pieces by moving onto occupied cells, and primarily score by creating removable lines of 5+ pieces.

The current design direction is closer to classic Lines than chess combat.

## Current Target Game Rules

### Color Palette

Puzzle colors for pieces and borders:

- RED, BLUE, GREEN, ORANGE
- Border colors: Left=RED, Top=BLUE, Right=GREEN, Bottom=ORANGE
- Border width: 3 pixels

### Board

- Board size: 8x8
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

## Removal Rules (Scoring)

The primary way to score is by forming and removing lines of 5 or more aligned pieces.

Two types of lines are supported:

1. Color Line  
   - 5 or more pieces of the same color  
   - piece type does not matter  
   - awards base score  

2. Type Line  
   - 5 or more pieces of the same chess type  
   - color does not matter  
   - awards double score  

If a line satisfies both conditions (same color and same type), apply a combo bonus.

Only line-based removals generate score.

---

## Attack Rule (Board Manipulation)

A piece may capture another piece by moving onto its cell if:

- the target piece is of a different color  
- the movement follows the attacking piece’s movement rules  

Result:
- the attacking piece replaces the target piece  
- the target piece is removed  

Restrictions:
- same-color pieces cannot be captured  
- Kings cannot be captured  

Attacks do not generate score and do not count as line completion.  
After an attack, line detection is evaluated normally.

---

## King Rule

Kings are special joker pieces with the following behavior:

- can move and capture using standard king movement  
- cannot be captured by other pieces  
- can participate in type-based lines as a wildcard (joker)  
- only one king should exist on the board at a time  

Kings are not treated as normal pieces for removal unless explicitly part of a valid line.

### Spawn Rule

- Start with 3 random pieces
- After each player move, spawn 3 new random pieces
- Preview next 3 pieces if implemented
- Spawned pieces may complete normal Lines-style removals
- King spawn is very rare
- Random spawning must respect per-color inventory limits based on normal chess counts
- Spawn placement should avoid creating removable lines when an alternative empty cell exists
- If every remaining empty cell would create a line, spawning may still use one of those cells
- If normal spawn inventory is exhausted under the current one-king-total rule, remaining empty cells should be filled with kings and the game should end immediately

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
- only one king should exist on the board at a time
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
  - `ThemeManager`

- `scenes/`
  - board and gameplay scenes
  - `BoardManager`
- `GameBoard`
- `Piece`
- `MainMenu`
- `SpawnPlanner`

- `scripts/`
  - game logic
  - line detection
  - supporting systems

- `assets/sprites/`
  - chess piece SVG sources
  - rendered PNG sprites

- `themes/`
  - theme resources
  - `default_theme.tres`

## Global Constants

Use `GameManager.gd` constants.

Do not hardcode board or cell sizes.

Expected constants:

```gdscript
const BOARD_SIZE: int = 8
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

### Theme System

The project now has a theme concept.

A theme is a collection of visual resources and presentation values only.

Current implementation uses:

```text
autoload/ThemeManager.gd
scripts/theme/ThemeData.gd
themes/default_theme.tres
```

Theme scope includes:

- piece textures
- piece tint colors
- board cell colors
- side border colors
- move and attack overlay colors
- HUD colors
- puzzle board images and reveal-cover colors
- message display colors
- dialog colors and typography
- menu colors and button styles
- settings dialog colors and theme selector popup styling
- other purely visual presentation values

Theme scope does not include:

- board size
- scoring
- movement rules
- spawn counts
- piece inventory limits
- king gameplay rules

The active theme is selected through persisted settings and loaded by `ThemeManager`.
Current available theme ids are `default` and `neon`.

Theme selection now lives in the main menu settings dialog. Keep it persisted and theme-driven, but do not add extra theme management UI unless explicitly requested.

When adding new visual elements, route their colors/resources through `ThemeData` instead of hardcoding them locally.

When refactoring themed code, preserve default-theme parity:

- the game should look the same after extraction
- `default_theme.tres` is the canonical baseline for the current look
- theme work should not alter gameplay behavior

### Main Menu Rendering

Current main menu implementation uses:

```text
scenes/ui/MainMenu.tscn
scripts/ui/MainMenu.gd
scripts/ui/MainMenuBoard.gd
```

The intended presentation is:

- full-screen dark checkerboard background
- centered dark menu panel
- primary actions in the center
- settings dialog with sound, vibration, and theme controls
- full-screen HowToPlay overlay panel

Use `MainMenuBoard.gd` for the checkerboard background layer.

Do not replace the current menu background with a stretched `TextureRect` checkerboard unless explicitly requested.

Keep the menu scene as a `Control`-based layout.

Prefer stable node paths and direct button signal wiring in `MainMenu.gd`.

Avoid duplicated scene subtrees or duplicate node names in `MainMenu.tscn`.

If you change the HowToPlay layout, update script node paths at the same time.

Main menu visuals should remain theme-driven through `ThemeManager` and `ThemeData`, even though only the default theme exists for now.
Main menu typography should use the same brisk dialog font family as the game-over screen and other modal dialogs.
The settings theme selector dropdown should use the dialog body font scale, not the smaller button scale.

### Resize / Layout Principles

The game should remain usable when the window size changes.

Current approach:

- UI overlays use `Control` anchors
- gameplay board remains a fixed logical 8x8 board
- `GameBoard.gd` scales `BoardManager` visually from fixed logical board dimensions
- mobile gameplay should make the board nearly full viewport width when height allows
- desktop gameplay should prefer a board-width window footprint and may squeeze the board to keep HUD, board, and bottom actions visible
- gameplay board is positioned directly below the HUD instead of vertically centered in leftover space
- desktop windowed mode may increase window height so the HUD, board, and bottom action row remain fully visible
- top HUD stretches horizontally with anchors instead of fixed pixel widths

Prefer viewport-aware scaling at the scene container level.

Do not rewrite board logic to use dynamic per-cell coordinates just to support window resizing.

Use `GameManager.BOARD_PIXEL_SIZE`, `GameManager.CELL_SIZE`, and `BoardManager.get_rendered_pixel_size()` as logical board dimensions, then scale the board scene visually.

The current default desktop viewport in `project.godot` should stay close to the rendered board width and tall enough for the HUD, board, and bottom actions.

### HUD / Puzzle Board

Current gameplay HUD includes:

- a top puzzle board image panel
- a message display beneath the puzzle board
- score and session line counters beneath the message display
- a bottom action row under the board with Reset and Main Menu buttons
- the Main Menu button in the action row uses a borderless link-style appearance (no background, no border, dim text that brightens on hover)

Puzzle board rules:

- one removed piece reveals one puzzle tile
- fully revealing one picture completes one level
- level images come from the active `ThemeData`
- the default puzzle image comes from `assets/ui/themes/default/level0.png`
- puzzle tile cover and puzzle board colors should remain theme-driven
- `assets/ui/checklines-screen-badge.png` is the top badge art
- the badge should sit above the puzzle frame with only its bottom edge slightly overlapping the puzzle border
- the puzzle image and score row use separate frames; do not wrap the puzzle and score row in one shared frame
- keep a small visible gap between the puzzle frame and the score row frame

Message display rules:

- color line message: `"$number in a row"`
- type line message: `"$number $piece_name on the march"`
- level complete message: `"Completed the $ordinal level!"`
- HUD messages should use the dialog font family at a larger, more prominent size
- HUD messages live inside the score row while displayed
- HUD messages should use an opaque score-row-colored backing panel, not transparent text over the scores
- HUD messages wipe in from the left and wipe out to the right
- while the message wipes in, the score and best text slide out as if pushed away, then slide back when the message exits
- the score row frame and side borders must remain fixed; only the inner score content and message wipe panel should slide

If HUD layout changes, preserve:

- near full-width board presentation on mobile and board-footprint desktop presentation
- anchored top HUD controls
- separate puzzle frame, score frame, and bottom action button row
- theme-driven puzzle visuals and message styling
- dark backdrop-colored screen background behind both HUD and board
- full-window dark vignette/gradient background that stays visible around the content edge
- default gameplay backdrop should stay close to the reference: near-black center with restrained teal-blue side glow, not a bright vertical gradient
- puzzle cover tiles drawn as puzzle-piece silhouettes with tabs and sockets

### Dialogs

Current modal/dialog presentation includes:

- a large centered game-over card
- a settings dialog in the main menu
- dark overlay backdrop
- brisk modern dialog typography
- shared font family for menu, HUD messages, and game-over text

When adding or refactoring dialogs:

- keep titles proportionally larger than body text
- keep dialog buttons large and easy to hit
- route dialog colors and font settings through `ThemeData`
- preserve the current centered card style for game over unless explicitly redesigned
- keep settings dialog popup/dropdown text readable in the neon theme

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

Gameplay scene UI caveat:

- Persistent bottom buttons live under `CanvasLayer/ActionButtons`
- Game-over UI lives under `CanvasLayer/UI/GameOverOverlay`
- Keep the full-screen `CanvasLayer/UI` control on `mouse_filter = ignore` so it does not block Reset or Main Menu button clicks
- Only visible modal/dialog controls should consume pointer input

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

`GameManager.gd` should not become the primary owner of visual styling now that themes exist.

### `BoardManager.gd`

Owns:

- board grid
- piece positions
- selection state
- input handling
- move execution
- move highlights
- board occupancy
- spawn placement over currently empty cells

### `GameBoard.gd`

Owns or coordinates:

- game loop
- spawning
- line detection call
- score updates
- UI updates
- game-over condition
- exhausted-spawn fallback to king-filled board ending

### `SpawnPlanner.gd`

Owns:

- spawn-cell preference logic
- avoiding line-making spawn placements when alternatives exist
- detecting when normal spawn inventory is exhausted

### `Piece.gd`

Owns:

- piece type
- piece color
- sprite setup
- movement logic

### `ThemeManager.gd`

Owns:

- loading the active theme resource
- exposing the current `ThemeData`
- central access point for theme-driven visuals
- reloading the active theme when persisted settings change

### `PuzzleTileCover.gd`

Owns:

- the drawn puzzle-piece cover shape used by revealed and unrevealed puzzle tiles
- the paper-like fill, outline, and simple lighting of puzzle cover tiles

Keep puzzle tile cover work here instead of reverting to flat `ColorRect` tiles.

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

Current enforced inventory limits per color:

- 8 pawns
- 2 knights
- 2 bishops
- 2 rooks
- 1 queen
- 1 king by type inventory, but current gameplay further restricts this to one king total on the whole board

Spawn logic should only generate colors and piece types that are still legal under these limits.

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
- centered main menu layout
- checkerboard menu background
- resize-safe board presentation
- default theme visual parity

### When Changing Rules

Update only the relevant system:

- movement changes → `Piece.gd`
- board selection/movement → `BoardManager.gd`
- spawning/scoring/game loop → `GameBoard.gd`
- global values → `GameManager.gd`
- visual styling/resources → `ThemeData.gd` and `ThemeManager.gd`
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
2. Board is 8x8
3. Clicking a piece selects it
4. Valid empty moves are highlighted
5. Clicking a highlighted cell moves the piece
6. Completed color lines of 5+ are removed
7. Completed type lines of 5+ are removed
8. Type lines score more than color lines
9. 3 new pieces spawn after a move
10. Board state remains consistent
11. Game-over condition still works
12. At most one king exists on the board at any time
13. No color exceeds chess-style inventory limits for any piece type
14. Spawn placement avoids immediate line clears when another empty cell exists
15. If normal spawn inventory is exhausted, remaining empty cells are filled with kings before game over

Attack highlighting:
14. Attack overlays display attacker sprite on target pieces
15. Attack borders show attacker color on target cell
16. Target pieces dimmed (0.35 opacity) when selectable
17. Overlays disappear on piece deselection
18. Pawn moves in correct direction (away from home border)

UI:
19. Main menu centered with dark panel and board visible beneath
20. Settings dialog opens with sound, vibration, and theme controls
21. Theme selector dropdown text matches the dialog body font scale
22. HowToPlay panel fully opaque
23. Main menu buttons remain centered after window resize
24. Gameplay board is nearly full-width on mobile and remains fully visible after window resize
25. Desktop gameplay window stays close to board width and fits HUD, board, and bottom actions
26. Score row is wrapped in its own frame, separate from the puzzle frame
27. Reset and Main Menu buttons under the board are clickable and perform their actions
28. The full-screen UI overlay does not block normal gameplay or bottom button input
29. Puzzle board reveals tiles as pieces are removed
30. Message display shows line-clear and level-complete messages with the expected wording
31. HUD messages use an opaque backing panel inside the score row, wipe in from the left, wipe out to the right, and temporarily push score/best text away
32. Game-over dialog uses a large centered card with brisk modern typography

## Current Working Definition

Check Lines is a Lines-style puzzle game on an 8x8 chess-sized board where colored chess pieces are moved using chess-inspired movement rules. The player clears lines of 5+ matching colors or 5+ matching piece types, can make limited color-based captures that do not score by themselves, and reveals puzzle artwork through piece removals during play. Random spawning respects chess-like per-color piece inventories, avoids immediate line-making placements when alternatives exist, and under the current one-king-total rule ends by filling remaining empty cells with kings when normal spawn inventory is exhausted.
