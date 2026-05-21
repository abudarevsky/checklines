extends SceneTree

func _initialize():
	var failures: Array[String] = []

	_run_test("uses configured trap count by level", _test_trap_count_by_level, failures)
	_run_test("uses configured trap rotation limits by level", _test_trap_rotation_limits_by_level, failures)
	_run_test("uses independent trap rotation frequency", _test_trap_rotation_frequency, failures)
	_run_test("rotates every trap to a new empty cell", _test_trap_rotation_selects_new_empty_cells, failures)
	_run_test("uses common trap library definition", _test_common_trap_library, failures)
	_run_test("board stores trap type references", _test_board_trap_type_reference, failures)
	_run_test("board selects trap details", _test_board_selects_trap_details, failures)
	_run_test("traps are excluded from empty spawn cells", _test_traps_excluded_from_empty_cells, failures)
	_run_test("moving onto a trap sacrifices the piece", _test_trap_sacrifices_piece, failures)

	if failures.is_empty():
		print("All trap tests passed")
		quit(0)
		return

	for failure in failures:
		push_error(failure)
	quit(1)

func _run_test(name: String, test_callable: Callable, failures: Array[String]):
	var error_message: String = test_callable.call()
	if error_message != "":
		failures.append(name + ": " + error_message)

func _test_trap_count_by_level() -> String:
	var game_board_script = load("res://scripts/board/GameBoard.gd")
	if game_board_script._get_trap_count_for_level(-1) != 0:
		return "expected negative levels to have no traps"
	for level_index in range(4):
		if game_board_script._get_trap_count_for_level(level_index) < 0:
			return "expected configured trap counts to stay non-negative"
	if game_board_script._get_trap_count_for_level(6) != game_board_script._get_trap_count_for_level(3):
		return "expected later levels to reuse the last configured trap count"
	return ""

func _test_trap_rotation_limits_by_level() -> String:
	var game_board_script = load("res://scripts/board/GameBoard.gd")
	if game_board_script._get_trap_rotation_limit_for_level(-1) != 0:
		return "expected negative levels to have no trap rotations"
	for level_index in range(4):
		if game_board_script._get_trap_rotation_limit_for_level(level_index) < -1:
			return "expected trap rotation limits to be -1 or greater"
	if game_board_script._get_trap_rotation_limit_for_level(6) != game_board_script._get_trap_rotation_limit_for_level(3):
		return "expected later levels to reuse the last configured trap rotation limit"
	return ""

func _test_trap_rotation_frequency() -> String:
	var game_board_script = load("res://scripts/board/GameBoard.gd")
	if game_board_script._get_trap_rotation_chance_for_level(-1) != 0.0:
		return "expected negative levels to have no trap rotation chance"
	for level_index in range(4):
		var chance: float = game_board_script._get_trap_rotation_chance_for_level(level_index)
		if chance < 0.0 or chance > 1.0:
			return "expected trap rotation chances to stay in probability range"
	if game_board_script._get_trap_rotation_chance_for_level(6) != game_board_script._get_trap_rotation_chance_for_level(3):
		return "expected later levels to reuse the last configured trap rotation chance"
	return ""

func _test_trap_rotation_selects_new_empty_cells() -> String:
	var game_board_script = load("res://scripts/board/GameBoard.gd")
	var current_traps: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 1), Vector2i(2, 2)]
	var candidate_cells: Array[Vector2i] = [Vector2i(3, 3), Vector2i(4, 4), Vector2i(5, 5), Vector2i(6, 6)]
	var selected_cells: Array[Vector2i] = game_board_script._select_rotated_trap_cells(current_traps, candidate_cells)
	if selected_cells.size() != current_traps.size():
		return "expected one new cell per trap"
	for cell in selected_cells:
		if cell in current_traps:
			return "rotation reused an old trap cell"
		if not (cell in candidate_cells):
			return "rotation selected a non-empty cell"
	return ""

func _test_common_trap_library() -> String:
	var TrapLibraryScript = load("res://scripts/traps/TrapLibrary.gd")
	var trap = TrapLibraryScript.get_trap("swallow")
	if trap == null:
		return "expected swallow trap definition"
	if trap.id != "swallow":
		return "wrong trap id"
	if trap.display_name != "Big Swamp":
		return "wrong trap display name"
	if trap.description != "I'll chew you up and spit you out.":
		return "wrong trap description"
	if trap.display_name_key != "trap_swallow_name":
		return "wrong trap display name key"
	if trap.description_key != "trap_swallow_description":
		return "wrong trap description key"
	if trap.get_spawn_count(0) != 2:
		return "expected level 0 swallow trap to emit 2 pieces"
	if trap.get_spawn_count(1) != 2:
		return "expected level 1 swallow trap to emit 2 pieces"
	if trap.get_spawn_count(2) != 3:
		return "expected level 2 swallow trap to emit 3 pieces"
	if trap.get_spawn_count(6) != 3:
		return "expected later swallow traps to keep emitting 3 pieces"
	return ""

func _test_board_trap_type_reference() -> String:
	var BoardManagerScript = load("res://scripts/board/BoardManager.gd")
	var board_manager = BoardManagerScript.new()
	board_manager.board_size = 2
	board_manager.set_traps([Vector2i(0, 0)], "swallow")

	var error_message := ""
	if board_manager.get_trap_type_id(Vector2i(0, 0)) != "swallow":
		error_message = "board did not store trap type id"
	elif board_manager.get_trap_data(Vector2i(0, 0)).id != "swallow":
		error_message = "board did not resolve trap data from library"

	board_manager.free()
	return error_message

func _test_board_selects_trap_details() -> String:
	var BoardManagerScript = load("res://scripts/board/BoardManager.gd")
	var board_manager = BoardManagerScript.new()
	board_manager.board_size = 2
	board_manager.set_traps([Vector2i(0, 0)], "swallow")

	var selected: Array = []
	board_manager.trap_selected.connect(func(trap_data: Resource):
		selected.append(trap_data)
	)
	board_manager.handle_trap_cell_click(Vector2i(0, 0))

	var error_message := ""
	if selected.size() != 1:
		error_message = "expected trap selection signal"
	elif selected[0].display_name != "Big Swamp":
		error_message = "selected trap carried wrong name"
	elif selected[0].description != "I'll chew you up and spit you out.":
		error_message = "selected trap carried wrong description"

	board_manager.free()
	return error_message

func _test_traps_excluded_from_empty_cells() -> String:
	var BoardManagerScript = load("res://scripts/board/BoardManager.gd")
	var board_manager = BoardManagerScript.new()
	board_manager.board_size = 2
	board_manager.set_traps([Vector2i(0, 0), Vector2i(1, 1)])

	var empty_cells: Array = board_manager.get_empty_cells()
	board_manager.free()

	if Vector2i(0, 0) in empty_cells or Vector2i(1, 1) in empty_cells:
		return "traps were reported as empty"
	if empty_cells.size() != 2:
		return "expected two playable empty cells, got %d" % empty_cells.size()
	return ""

func _test_trap_sacrifices_piece() -> String:
	var BoardManagerScript = load("res://scripts/board/BoardManager.gd")
	var PieceScript = load("res://scripts/piece/Piece.gd")
	var board_manager = BoardManagerScript.new()
	board_manager.board_size = 2
	var piece = PieceScript.new()
	piece.piece_type = GameManager.PieceType.ROOK
	piece.piece_color = GameManager.PieceColor.RED
	piece.grid_position = Vector2i(0, 0)
	board_manager.board[piece.grid_position] = piece
	board_manager.set_traps([Vector2i(1, 0)])

	var sacrificed: Array = []
	board_manager.piece_sacrificed.connect(func(from: Vector2i, to: Vector2i, piece_type: int):
		sacrificed.append({"from": from, "to": to, "piece_type": piece_type})
	)
	board_manager.move_piece(piece, Vector2i(1, 0))

	var error_message := ""
	if board_manager.board.has(Vector2i(0, 0)) or board_manager.board.has(Vector2i(1, 0)):
		error_message = "piece remained on the board after trap move"
	elif sacrificed.size() != 1:
		error_message = "expected one piece_sacrificed signal"
	elif sacrificed[0]["from"] != Vector2i(0, 0) or sacrificed[0]["to"] != Vector2i(1, 0):
		error_message = "sacrifice signal carried wrong cells"
	elif sacrificed[0]["piece_type"] != GameManager.PieceType.ROOK:
		error_message = "sacrifice signal carried wrong piece type"

	board_manager.free()
	return error_message
