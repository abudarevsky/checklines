# Godot Game Project Baseline — New Starting Point (as of April 18, 2026)

## Project Goal (final version)
A "Chess Lines" puzzle game on a 9x9 board - mix of chess pieces and line-matching mechanics. Player clicks a piece to select it (shows green highlights for valid moves to empty cells), clicks an empty highlighted cell to move, then 3 new random pieces spawn. Chains of 5+ attacking pieces (alternating colors) are cleared for bonus points.

## Current Application Design & Architecture
- **Godot Version**: 4.6.stable
- **Structure**:
  - `autoload/` - Global managers (GameManager, AudioManager, Settings)
  - `scenes/` - Game scenes (BoardManager, GameBoard, Piece, MainMenu)
  - `scripts/` - Game logic scripts, chain detection
  - `assets/sprites/` - SVG chess piece sprites (not currently used - pieces drawn procedurally)
- **Key Systems**:
  - `BoardManager.gd` - Board rendering (9x9 grid), piece management, move validation, highlighting
  - `Piece.gd` - Procedural piece drawing (6 chess types), move/capture logic for each piece type
  - `GameBoard.gd` - Game loop, spawn logic, chain detection, UI management
  - `GameManager.gd` - Score tracking, piece type weights, game state
  - `ChainDetector.gd` - Finds chains of 5+ attacking pieces with alternating colors

## Core Principles & Design Decisions That Worked
- Procedural piece drawing via `_draw()` instead of SVG imports (avoids Godot 4.x import issues)
- Piece input handled in `BoardManager._input()` rather than Area2D signals on pieces
- Moves and captures are separate - moves go to empty cells only, captures require opposite color piece in attack range
- Highlights drawn as ColorRects added to PiecesContainer (not separate container)
- Starting with only 3 pieces creates sparse board, making chain-building more strategic

## How to Run and Test the Game
```bash
# Open in Godot Editor
godot --editor
# or open project folder in Godot

# Run from command line
godot --path .

# Export for macOS (from Godot Editor)
# Project > Export > Add macOS > Export Project
```

Manual testing: Start game → 3 random pieces appear → click piece → green highlights on valid moves → click highlight → piece moves → 3 new pieces spawn → chains clear automatically

## Rules for All Future Work
- Always respect current architecture: BoardManager handles input/board, Piece handles movement rules
- Never re-introduce capture-as-first-option logic - moves go to empty cells only
- Test any change by running the game in editor
- Use signals for cross-system communication (piece_moved, capture_made, chain_cleared)