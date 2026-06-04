extends RefCounted
class_name SpawnPlanner

const PIECE_TYPE_COUNT: int = 6
const PIECE_COLOR_COUNT: int = 4
const KING_TYPE: int = 5
const PIECE_LIMITS: Dictionary = {
	0: 8,
	1: 2,
	2: 2,
	3: 2,
	4: 1,
	5: 1
}
const BOARD_CELL_LIGHT: int = 0
const BOARD_CELL_DARK: int = 1

class PreviewPiece:
	extends RefCounted

	var piece_type: int
	var piece_color: int
	var grid_position: Vector2i

	func _init(type: int, color: int, pos: Vector2i):
		piece_type = type
		piece_color = color
		grid_position = pos

static func would_spawn_create_chain(board: Dictionary, piece_type: int, color: int, grid_pos: Vector2i) -> bool:
	var preview_board: Dictionary = board.duplicate()
	preview_board[grid_pos] = PreviewPiece.new(piece_type, color, grid_pos)
	return not ChainDetector.find_chains(preview_board).is_empty()

static func get_preferred_spawn_cell(board: Dictionary, empty_cells: Array, piece_type: int, color: int) -> Vector2i:
	if empty_cells.is_empty():
		return Vector2i(-1, -1)

	var shuffled_cells: Array = empty_cells.duplicate()
	shuffled_cells.shuffle()
	var legal_cells: Array = []

	for cell in shuffled_cells:
		if can_place_piece_on_cell(board, piece_type, color, cell):
			legal_cells.append(cell)

	if legal_cells.is_empty():
		return Vector2i(-1, -1)

	var safe_cells: Array = []
	for cell in legal_cells:
		if not would_spawn_create_chain(board, piece_type, color, cell):
			safe_cells.append(cell)

	if not safe_cells.is_empty():
		return safe_cells[0]

	return legal_cells[0]

static func can_spawn_identity(board: Dictionary, piece_type: int, color: int, empty_cells: Array = []) -> bool:
	if piece_type == KING_TYPE and _has_king(board):
		return false

	var current_count := _get_piece_count_for_color_and_type(board, color, piece_type)
	if current_count >= int(PIECE_LIMITS.get(piece_type, 0)):
		return false

	var cells: Array = empty_cells
	if cells.is_empty():
		cells = _get_empty_cells(board)

	for cell in cells:
		if can_place_piece_on_cell(board, piece_type, color, cell):
			return true

	return false

static func can_place_piece_on_cell(board: Dictionary, piece_type: int, color: int, grid_pos: Vector2i) -> bool:
	if board.has(grid_pos):
		return false
	if piece_type == KING_TYPE and _has_king(board):
		return false

	var limit: int = int(PIECE_LIMITS.get(piece_type, 0))
	if _get_piece_count_for_color_and_type(board, color, piece_type) >= limit:
		return false

	var board_color := get_board_cell_color(grid_pos)
	var same_board_color_count := _get_piece_count_for_color_type_and_board_color(board, color, piece_type, board_color)
	return same_board_color_count < _get_board_color_limit(piece_type)

static func has_spawn_capacity(board: Dictionary) -> bool:
	var empty_cells := _get_empty_cells(board)
	if empty_cells.is_empty():
		return false

	for color in range(PIECE_COLOR_COUNT):
		for piece_type in range(PIECE_TYPE_COUNT):
			if can_spawn_identity(board, piece_type, color, empty_cells):
				return true

	return false

static func can_spawn_count(board: Dictionary, empty_cells: Array, count: int) -> bool:
	if count <= 0:
		return true
	if empty_cells.size() < count:
		return false
	return _can_spawn_count_recursive(board, empty_cells, count)

static func filter_excluded_cells(cells: Array, excluded_cells: Array) -> Array:
	if excluded_cells.is_empty():
		return cells

	var filtered_cells: Array = []
	for cell in cells:
		if cell not in excluded_cells:
			filtered_cells.append(cell)
	return filtered_cells

static func get_board_cell_color(grid_pos: Vector2i) -> int:
	return BOARD_CELL_LIGHT if (grid_pos.x + grid_pos.y) % 2 == 0 else BOARD_CELL_DARK

static func _get_board_color_limit(piece_type: int) -> int:
	var limit: int = int(PIECE_LIMITS.get(piece_type, 0))
	return int(ceil(float(limit) / 2.0))

static func _get_piece_count_for_color_and_type(board: Dictionary, color: int, piece_type: int) -> int:
	var count := 0
	for piece in board.values():
		if piece.piece_color == color and piece.piece_type == piece_type:
			count += 1
	return count

static func _get_piece_count_for_color_type_and_board_color(board: Dictionary, color: int, piece_type: int, board_color: int) -> int:
	var count := 0
	for piece in board.values():
		if piece.piece_color == color and piece.piece_type == piece_type and get_board_cell_color(piece.grid_position) == board_color:
			count += 1
	return count

static func _has_king(board: Dictionary) -> bool:
	for piece in board.values():
		if piece.piece_type == KING_TYPE:
			return true
	return false

static func _can_spawn_count_recursive(board: Dictionary, empty_cells: Array, remaining_count: int) -> bool:
	if remaining_count <= 0:
		return true

	for color in range(PIECE_COLOR_COUNT):
		for piece_type in range(PIECE_TYPE_COUNT):
			for cell in empty_cells:
				if not can_place_piece_on_cell(board, piece_type, color, cell):
					continue
				var preview_board: Dictionary = board.duplicate()
				preview_board[cell] = PreviewPiece.new(piece_type, color, cell)
				var preview_empty_cells: Array = empty_cells.duplicate()
				preview_empty_cells.erase(cell)
				if _can_spawn_count_recursive(preview_board, preview_empty_cells, remaining_count - 1):
					return true

	return false

static func _get_empty_cells(board: Dictionary) -> Array:
	var empty_cells: Array = []
	for y in range(GameManager.BOARD_SIZE):
		for x in range(GameManager.BOARD_SIZE):
			var pos := Vector2i(x, y)
			if not board.has(pos):
				empty_cells.append(pos)
	return empty_cells
