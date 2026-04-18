# Godot Game Project Baseline — New Starting Point (as of April 18, 2026)

## Project Goal (final version)
A "Chess Lines" puzzle game on a 9x9 board - mix of chess pieces and line-matching mechanics. Player clicks a piece to select it (shows green highlights for valid moves to empty cells), clicks an empty highlighted cell to move, then 3 new random pieces spawn. Chains of 5+ attacking pieces (alternating colors) are cleared for bonus points.

## Global Constants (GameManager.gd)
All gameplay dimensions and sizes defined in one place:
```gdscript
const BOARD_SIZE: int = 9        # Grid dimensions (9x9)
const CELL_SIZE: int = 100     # Pixel size per cell
const BOARD_PIXEL_SIZE: int = BOARD_SIZE * CELL_SIZE  # 900
const WINDOW_WIDTH: int = BOARD_PIXEL_SIZE
const WINDOW_HEIGHT: int = BOARD_PIXEL_SIZE
```

## Current Application Design & Architecture
- **Godot Version**: 4.6.stable
- **Structure**:
  - `autoload/` - Global managers (GameManager, AudioManager, Settings)
  - `scenes/` - Game scenes (BoardManager, GameBoard, Piece, MainMenu)
  - `scripts/` - Game logic scripts, chain detection
  - `assets/sprites/` - SVG chess piece sprites, PNG renders (512x512)
- **Key Systems**:
  - `BoardManager.gd` - Board rendering (9x9 grid), piece management, move validation, highlighting
  - `Piece.gd` - Sprite-based piece rendering, move/capture logic for each piece type
  - `GameBoard.gd` - Game loop, spawn logic, chain detection, UI management
  - `GameManager.gd` - Score tracking, piece type weights, global constants
  - `ChainDetector.gd` - Finds chains of 5+ attacking pieces with alternating colors

## Core Principles & Design Decisions That Worked
- Sprite-based piece rendering via PNG images (avoids Godot 4.x SVG import issues)
- Piece input handled in `BoardManager._input()` rather than Area2D signals on pieces
- Moves and captures are separate - moves go to empty cells only, captures require opposite color piece in attack range
- Highlights drawn as ColorRects added to PiecesContainer (not separate container)
- Starting with only 3 pieces creates sparse board, making chain-building more strategic
- All sizes defined globally in GameManager - never hardcode values

## How to Run and Test the Game
```bash
# Godot path (macOS)
GODOT="/Applications/Godot.app/Contents/MacOS/Godot"

# Open in Godot Editor
"$GODOT" --editor --path .
# or open project folder in Godot

# Run from command line
"$GODOT" --path .

# Export for macOS (from Godot Editor)
# Project > Export > Add macOS > Export Project
```

Manual testing: Start game → 3 random pieces appear → click piece → green highlights on valid moves → click highlight → piece moves → 3 new pieces spawn → chains clear automatically

## Rules for All Future Work
- Always reference GameManager constants (CELL_SIZE, BOARD_SIZE, etc.)
- Never hardcode sizes - use constants throughout
- Respect current architecture: BoardManager handles input/board, Piece handles movement rules
- Never re-introduce capture-as-first-option logic - moves go to empty cells only
- Test any change by running the game in editor
- Use signals for cross-system communication (piece_moved, capture_made, chain_cleared)