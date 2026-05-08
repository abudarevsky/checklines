extends SceneTree

func _initialize():
	var failures: Array[String] = []

	_run_test("uses configured blocked-cell count by level", _test_blocked_cell_count_by_level, failures)
	_run_test("blocked cells are excluded from empty spawn cells", _test_blocked_cells_excluded_from_empty_cells, failures)
	_run_test("moving onto a blocked cell sacrifices the piece", _test_blocked_cell_sacrifices_piece, failures)

	if failures.is_empty():
		print("All blocked cell tests passed")
		quit(0)
		return

	for failure in failures:
		push_error(failure)
	quit(1)

func _run_test(name: String, test_callable: Callable, failures: Array[String]):
	var error_message: String = test_callable.call()
	if error_message != "":
		failures.append(name + ": " + error_message)

func _test_blocked_cell_count_by_level() -> String:
	var game_board_script = load("res://scripts/board/GameBoard.gd")
	if game_board_script._get_blocked_cell_count_for_level(0) != 0:
		return "expected level 0 to have no blocked cells"
	if game_board_script._get_blocked_cell_count_for_level(1) != 1:
		return "expected level 1 to have one blocked cell"
	if game_board_script._get_blocked_cell_count_for_level(2) != 2:
		return "expected level 2 to have two blocked cells"
	if game_board_script._get_blocked_cell_count_for_level(6) != 2:
		return "expected later levels to keep two blocked cells"
	return ""

func _test_blocked_cells_excluded_from_empty_cells() -> String:
	var BoardManagerScript = load("res://scripts/board/BoardManager.gd")
	var board_manager = BoardManagerScript.new()
	board_manager.board_size = 2
	board_manager.set_blocked_cells([Vector2i(0, 0), Vector2i(1, 1)])

	var empty_cells: Array = board_manager.get_empty_cells()
	board_manager.free()

	if Vector2i(0, 0) in empty_cells or Vector2i(1, 1) in empty_cells:
		return "blocked cells were reported as empty"
	if empty_cells.size() != 2:
		return "expected two playable empty cells, got %d" % empty_cells.size()
	return ""

func _test_blocked_cell_sacrifices_piece() -> String:
	var BoardManagerScript = load("res://scripts/board/BoardManager.gd")
	var PieceScript = load("res://scripts/piece/Piece.gd")
	var board_manager = BoardManagerScript.new()
	board_manager.board_size = 2
	var piece = PieceScript.new()
	piece.piece_type = GameManager.PieceType.ROOK
	piece.piece_color = GameManager.PieceColor.RED
	piece.grid_position = Vector2i(0, 0)
	board_manager.board[piece.grid_position] = piece
	board_manager.set_blocked_cells([Vector2i(1, 0)])

	var sacrificed: Array = []
	board_manager.piece_sacrificed.connect(func(from: Vector2i, to: Vector2i, piece_type: int):
		sacrificed.append({"from": from, "to": to, "piece_type": piece_type})
	)
	board_manager.move_piece(piece, Vector2i(1, 0))

	var error_message := ""
	if board_manager.board.has(Vector2i(0, 0)) or board_manager.board.has(Vector2i(1, 0)):
		error_message = "piece remained on the board after blocked-cell move"
	elif sacrificed.size() != 1:
		error_message = "expected one piece_sacrificed signal"
	elif sacrificed[0]["from"] != Vector2i(0, 0) or sacrificed[0]["to"] != Vector2i(1, 0):
		error_message = "sacrifice signal carried wrong cells"
	elif sacrificed[0]["piece_type"] != GameManager.PieceType.ROOK:
		error_message = "sacrifice signal carried wrong piece type"

	board_manager.free()
	return error_message
