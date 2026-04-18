---
name: godot-achieved-state-design-principles
description: Godot game baseline design principles reached after agent development iterations
source: /Users/andreybudarevskiy/dev/games/chessline/AGENTS.md
---

# Chess Lines - Design Principles

## Project Overview
A "Chess Lines" puzzle game with:
- 9x9 chess-style board
- 6 chess piece types (Pawn, Knight, Bishop, Rook, Queen, King)
- Two piece colors (White, Black)
- Line-matching mechanic with chains of 5+ attacking pieces

## Game Loop
1. Start with 3 random pieces
2. Click piece → highlights valid moves (empty cells only)
3. Click highlighted cell → piece moves
4. Spawns 3 new random pieces
5. Chain detection runs automatically
6. Game over when no pieces can move

## Key Design Patterns

### Procedural Drawing
- Used `_draw()` in Node2D instead of SVG imports
- Avoided Godot 4.x import issues
- All 6 piece types drawn with draw_circle, draw_line, draw_polygon

### Input Handling
- BoardManager._input() handles mouse clicks globally
- Not using Area2D input_event signals on pieces
- Converting world position to grid via world_to_grid()

### Move Validation
- Piece.get_legal_moves() returns empty cell targets only
- Piece.get_legal_captures() returns opposite-color piece targets
- Separated move logic from capture logic per user requirement

### Highlighting
- ColorRects added to PiecesContainer as children
- Yellow/green highlights for valid moves
- Clear highlights on deselection

### Game State
- GameManager: global score, piece type weights, high score persistence
- BoardManager: 9x9 grid as Dictionary, piece positions
- Pieces stored by grid position (Vector2i) as key

## Insights That Worked
- 3 starting pieces = strategic gameplay
- Moves to empty cells only = puzzle-like, not chess-combat
- Spawn 3 pieces after each move = gradual board filling
- Chain detection = combo mechanic for bonus points

## Applying to Future Features
- Keep input in BoardManager._input()
- Keep piece logic in Piece.gd
- Use signals for cross-system events
- Test game after any change
- Read existing code before modifying