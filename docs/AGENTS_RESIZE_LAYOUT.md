# Resize / Layout Principles

The game should remain usable when the window size changes.

Current approach:

- UI overlays use `Control` anchors
- gameplay board remains a fixed logical 8x8 board
- `GameBoard.gd` scales `BoardManager` visually from fixed logical board dimensions
- mobile gameplay should make the board nearly full viewport width when height allows
- desktop gameplay should prefer a board-width window footprint and may squeeze the board to keep HUD and board visible
- gameplay board is positioned directly below the HUD instead of vertically centered in leftover space
- desktop windowed mode may increase window height so the HUD and board remain fully visible
- top HUD stretches horizontally with anchors instead of fixed pixel widths

Prefer viewport-aware scaling at the scene container level.

Do not rewrite board logic to use dynamic per-cell coordinates just to support window resizing.

Use `GameManager.BOARD_PIXEL_SIZE`, `GameManager.CELL_SIZE`, and `BoardManager.get_rendered_pixel_size()` as logical board dimensions, then scale the board scene visually.

The current default desktop viewport in `project.godot` should stay close to the rendered board width and tall enough for the HUD and board.

