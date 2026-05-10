# Global Constants

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