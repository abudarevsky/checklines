extends SceneTree

const BoardStateRulesScript = preload("res://scripts/board/BoardStateRules.gd")
const SpawnPlannerScript = preload("res://scripts/board/SpawnPlanner.gd")
const PIECE_LIMITS := {
	0: 8,
	1: 2,
	2: 2,
	3: 2,
	4: 1
}

class MockPiece:
	var piece_type: int
	var piece_color: int
	var grid_position: Vector2i
	var legal_moves: Array = []
	var legal_captures: Array = []

	func _init(type: int, color: int, pos: Vector2i):
		piece_type = type
		piece_color = color
		grid_position = pos

	func get_legal_moves(_board: Dictionary) -> Array:
		return legal_moves

	func get_legal_captures(_board: Dictionary) -> Array:
		return legal_captures

func _initialize():
	var failures: Array[String] = []

	_run_test("fills all three remaining empty cells", _test_fills_last_three_empty_cells, failures)
	_run_test("prefers non-clearing spawn cells when available", _test_prefers_non_clearing_spawn_cells, failures)
	_run_test("uses line-making cell when every empty cell would clear", _test_uses_line_cell_when_no_safe_cell_exists, failures)
	_run_test("keeps duplicate pieces on opposite board colors", _test_duplicate_piece_board_color_preference, failures)
	_run_test("blocks duplicate spawn when only exhausted board color remains", _test_duplicate_piece_board_color_capacity, failures)
	_run_test("detects lines after filling the last three cells", _test_detects_lines_after_last_three_spawns, failures)
	_run_test("full non-king inventory is not loss with four empty cells", _test_non_king_inventory_limit_is_not_loss_with_four_open_cells, failures)
	_run_test("empty board can spawn a full batch", _test_empty_board_can_spawn_full_batch, failures)
	_run_test("fewer than required spawn cells is a loss", _test_fewer_than_required_spawn_cells_is_loss, failures)
	_run_test("captured cells can be excluded from same-turn spawns", _test_captured_cells_excluded_from_same_turn_spawns, failures)

	if failures.is_empty():
		print("All spawn behavior tests passed")
		quit(0)
		return

	for failure in failures:
		push_error(failure)
	quit(1)

func _run_test(name: String, test_callable: Callable, failures: Array[String]):
	var error_message: String = test_callable.call()
	if error_message != "":
		failures.append(name + ": " + error_message)

func _test_fills_last_three_empty_cells() -> String:
	var board: Dictionary = {}
	var open_cells: Array[Vector2i] = [Vector2i(5, 7), Vector2i(6, 7), Vector2i(7, 7)]
	for y in range(GameManager.BOARD_SIZE):
		for x in range(GameManager.BOARD_SIZE):
			var pos := Vector2i(x, y)
			if pos in open_cells:
				continue
			board[pos] = _piece(GameManager.PieceType.PAWN, GameManager.PieceColor.BLUE, pos)

	var spawn_types: Array = [
		GameManager.PieceType.ROOK,
		GameManager.PieceType.BISHOP,
		GameManager.PieceType.KNIGHT
	]
	for piece_type in spawn_types:
		var chosen_cell: Vector2i = SpawnPlannerScript.get_preferred_spawn_cell(
			board,
			_get_empty_cells(board),
			piece_type,
			GameManager.PieceColor.RED
		)
		if chosen_cell == Vector2i(-1, -1):
			return "spawn planner failed to choose one of the last three cells"
		board[chosen_cell] = _piece(piece_type, GameManager.PieceColor.RED, chosen_cell)

	if _get_empty_cells(board).size() != 0:
		return "expected all three empty cells to be consumed"
	if not BoardStateRulesScript.is_loss_board_state(_get_empty_cells(board)):
		return "expected filled board after the last three spawns to be a loss"

	return ""

func _test_prefers_non_clearing_spawn_cells() -> String:
	var board: Dictionary = _make_board([
		_piece(GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(0, 0)),
		_piece(GameManager.PieceType.BISHOP, GameManager.PieceColor.RED, Vector2i(1, 0)),
		_piece(GameManager.PieceType.KNIGHT, GameManager.PieceColor.RED, Vector2i(2, 0)),
		_piece(GameManager.PieceType.QUEEN, GameManager.PieceColor.RED, Vector2i(3, 0))
	])
	var empty_cells: Array = [Vector2i(4, 0), Vector2i(7, 7)]

	var chosen_cell: Vector2i = SpawnPlannerScript.get_preferred_spawn_cell(
		board,
		empty_cells,
		GameManager.PieceType.PAWN,
		GameManager.PieceColor.RED
	)
	if chosen_cell == Vector2i(4, 0):
		return "line-clearing cell was chosen even though a safe cell existed"

	return ""

func _test_uses_line_cell_when_no_safe_cell_exists() -> String:
	var board: Dictionary = _make_board([
		_piece(GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(0, 0)),
		_piece(GameManager.PieceType.BISHOP, GameManager.PieceColor.RED, Vector2i(1, 0)),
		_piece(GameManager.PieceType.KNIGHT, GameManager.PieceColor.RED, Vector2i(2, 0)),
		_piece(GameManager.PieceType.QUEEN, GameManager.PieceColor.RED, Vector2i(3, 0))
	])
	var empty_cells: Array = [Vector2i(4, 0)]

	var chosen_cell: Vector2i = SpawnPlannerScript.get_preferred_spawn_cell(
		board,
		empty_cells,
		GameManager.PieceType.PAWN,
		GameManager.PieceColor.RED
	)
	if chosen_cell != Vector2i(4, 0):
		return "expected the only available cell to be used even though it clears a line"

	return ""

func _test_duplicate_piece_board_color_preference() -> String:
	var board: Dictionary = _make_board([
		_piece(GameManager.PieceType.KNIGHT, GameManager.PieceColor.RED, Vector2i(1, 0))
	])
	var empty_cells: Array = [Vector2i(3, 0), Vector2i(0, 0)]

	var chosen_cell: Vector2i = SpawnPlannerScript.get_preferred_spawn_cell(
		board,
		empty_cells,
		GameManager.PieceType.KNIGHT,
		GameManager.PieceColor.RED
	)
	if chosen_cell != Vector2i(0, 0):
		return "expected second red knight to spawn on the opposite board color"

	return ""

func _test_duplicate_piece_board_color_capacity() -> String:
	var board: Dictionary = _make_board([
		_piece(GameManager.PieceType.PAWN, GameManager.PieceColor.BLUE, Vector2i(1, 0)),
		_piece(GameManager.PieceType.PAWN, GameManager.PieceColor.BLUE, Vector2i(3, 0)),
		_piece(GameManager.PieceType.PAWN, GameManager.PieceColor.BLUE, Vector2i(5, 0)),
		_piece(GameManager.PieceType.PAWN, GameManager.PieceColor.BLUE, Vector2i(7, 0))
	])

	if SpawnPlannerScript.can_spawn_identity(
		board,
		GameManager.PieceType.PAWN,
		GameManager.PieceColor.BLUE,
		[Vector2i(1, 2)]
	):
		return "expected fifth blue pawn on a dark cell to be blocked"

	if not SpawnPlannerScript.can_spawn_identity(
		board,
		GameManager.PieceType.PAWN,
		GameManager.PieceColor.BLUE,
		[Vector2i(0, 0)]
	):
		return "expected fifth blue pawn on a light cell to remain legal"

	return ""

func _test_detects_lines_after_last_three_spawns() -> String:
	var board: Dictionary = {}
	var open_cells: Array[Vector2i] = [Vector2i(2, 0), Vector2i(3, 0), Vector2i(4, 0)]
	for y in range(GameManager.BOARD_SIZE):
		for x in range(GameManager.BOARD_SIZE):
			var pos := Vector2i(x, y)
			if pos in open_cells:
				continue
			var piece_color: int = GameManager.PieceColor.BLUE
			if y == 0 and x < 2:
				piece_color = GameManager.PieceColor.RED
			board[pos] = _piece(GameManager.PieceType.PAWN, piece_color, pos)

	for cell in open_cells:
		board[cell] = _piece(GameManager.PieceType.ROOK, GameManager.PieceColor.RED, cell)

	var chains: Array = ChainDetector.find_chains(board)
	if chains.is_empty():
		return "expected a removable line after filling the last three cells"

	return ""

func _test_non_king_inventory_limit_is_not_loss_with_four_open_cells() -> String:
	var board: Dictionary = _make_non_king_inventory_full_board()
	var empty_cells: Array = _get_empty_cells(board)

	if SpawnPlannerScript.can_spawn_count(board, _get_empty_cells(board), 3):
		return "expected old inventory-aware 3-piece capacity to fail"
	if empty_cells.size() != 4:
		return "expected four empty cells, got %d" % empty_cells.size()
	if BoardStateRulesScript.is_loss_board_state(empty_cells):
		return "expected four open cells to keep game active despite inventory limits"

	return ""

func _test_empty_board_can_spawn_full_batch() -> String:
	if not SpawnPlannerScript.can_spawn_count({}, _get_empty_cells({}), 3):
		return "expected empty board to support a 3-piece spawn"
	return ""

func _test_fewer_than_required_spawn_cells_is_loss() -> String:
	if not BoardStateRulesScript.is_loss_board_state([]):
		return "expected full board to be a loss"
	if not BoardStateRulesScript.is_loss_board_state([Vector2i(0, 0)]):
		return "expected one empty cell to be a loss"
	if not BoardStateRulesScript.is_loss_board_state([Vector2i(0, 0), Vector2i(1, 0)]):
		return "expected two empty cells to be a loss"
	if BoardStateRulesScript.is_loss_board_state([Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)]):
		return "expected three empty cells to keep game active"

	return ""

func _test_captured_cells_excluded_from_same_turn_spawns() -> String:
	var captured_cell := Vector2i(4, 4)
	var empty_cells: Array = SpawnPlannerScript.filter_excluded_cells(_get_empty_cells({}), [captured_cell])
	if captured_cell in empty_cells:
		return "captured cell remained available for same-turn spawn"

	var chosen_cell: Vector2i = SpawnPlannerScript.get_preferred_spawn_cell(
		{},
		empty_cells,
		GameManager.PieceType.PAWN,
		GameManager.PieceColor.RED
	)
	if chosen_cell == captured_cell:
		return "spawn planner selected the captured cell"

	return ""

func _piece(type: int, color: int, pos: Vector2i) -> MockPiece:
	return MockPiece.new(type, color, pos)

func _make_board(pieces: Array) -> Dictionary:
	var board: Dictionary = {}
	for piece in pieces:
		board[piece.grid_position] = piece
	return board

func _make_spawn_inventory_exhausted_board() -> Dictionary:
	var board: Dictionary = {}
	for color in GameManager.PieceColor.values():
		for i in range(PIECE_LIMITS[GameManager.PieceType.PAWN]):
			var pawn_pos := _next_free_cell(board)
			board[pawn_pos] = _piece(GameManager.PieceType.PAWN, color, pawn_pos)
		for i in range(PIECE_LIMITS[GameManager.PieceType.KNIGHT]):
			var knight_pos := _next_free_cell(board)
			board[knight_pos] = _piece(GameManager.PieceType.KNIGHT, color, knight_pos)
		for i in range(PIECE_LIMITS[GameManager.PieceType.BISHOP]):
			var bishop_pos := _next_free_cell(board)
			board[bishop_pos] = _piece(GameManager.PieceType.BISHOP, color, bishop_pos)
		for i in range(PIECE_LIMITS[GameManager.PieceType.ROOK]):
			var rook_pos := _next_free_cell(board)
			board[rook_pos] = _piece(GameManager.PieceType.ROOK, color, rook_pos)
		for i in range(PIECE_LIMITS[GameManager.PieceType.QUEEN]):
			var queen_pos := _next_free_cell(board)
			board[queen_pos] = _piece(GameManager.PieceType.QUEEN, color, queen_pos)

	var king_pos := _next_free_cell(board)
	board[king_pos] = _piece(GameManager.PieceType.KING, GameManager.PieceColor.RED, king_pos)
	return board

func _make_non_king_inventory_full_board() -> Dictionary:
	var board: Dictionary = {}
	for color in GameManager.PieceColor.values():
		for i in range(PIECE_LIMITS[GameManager.PieceType.PAWN]):
			var pawn_pos := _next_free_cell(board)
			board[pawn_pos] = _piece(GameManager.PieceType.PAWN, color, pawn_pos)
		for i in range(PIECE_LIMITS[GameManager.PieceType.KNIGHT]):
			var knight_pos := _next_free_cell(board)
			board[knight_pos] = _piece(GameManager.PieceType.KNIGHT, color, knight_pos)
		for i in range(PIECE_LIMITS[GameManager.PieceType.BISHOP]):
			var bishop_pos := _next_free_cell(board)
			board[bishop_pos] = _piece(GameManager.PieceType.BISHOP, color, bishop_pos)
		for i in range(PIECE_LIMITS[GameManager.PieceType.ROOK]):
			var rook_pos := _next_free_cell(board)
			board[rook_pos] = _piece(GameManager.PieceType.ROOK, color, rook_pos)
		for i in range(PIECE_LIMITS[GameManager.PieceType.QUEEN]):
			var queen_pos := _next_free_cell(board)
			board[queen_pos] = _piece(GameManager.PieceType.QUEEN, color, queen_pos)
	return board

func _get_empty_cells(board: Dictionary) -> Array:
	var empty_cells: Array = []
	for y in range(GameManager.BOARD_SIZE):
		for x in range(GameManager.BOARD_SIZE):
			var pos := Vector2i(x, y)
			if not board.has(pos):
				empty_cells.append(pos)
	return empty_cells

func _next_free_cell(board: Dictionary) -> Vector2i:
	for y in range(GameManager.BOARD_SIZE):
		for x in range(GameManager.BOARD_SIZE):
			var pos := Vector2i(x, y)
			if not board.has(pos):
				return pos
	return Vector2i(-1, -1)
