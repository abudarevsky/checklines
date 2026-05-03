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
	var safe_cells: Array = []
	for cell in shuffled_cells:
		if not would_spawn_create_chain(board, piece_type, color, cell):
			safe_cells.append(cell)

	if not safe_cells.is_empty():
		return safe_cells[0]

	return shuffled_cells[0]

static func has_spawn_capacity(board: Dictionary) -> bool:
	var has_king := false
	var counts_by_key: Dictionary = {}

	for piece in board.values():
		if piece.piece_type == KING_TYPE:
			has_king = true

		var key: String = "%d:%d" % [piece.piece_color, piece.piece_type]
		counts_by_key[key] = int(counts_by_key.get(key, 0)) + 1

	for color in range(PIECE_COLOR_COUNT):
		for piece_type in range(PIECE_TYPE_COUNT):
			if piece_type == KING_TYPE and has_king:
				continue

			var key: String = "%d:%d" % [color, piece_type]
			var limit: int = int(PIECE_LIMITS.get(piece_type, 0))
			var current_count: int = int(counts_by_key.get(key, 0))
			if current_count < limit:
				return true

	return false
