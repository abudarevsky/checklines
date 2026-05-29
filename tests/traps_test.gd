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
	_run_test("Big Swamp pulse detects realistic almost-lines", _test_big_swamp_pulse_detects_almost_line, failures)
	_run_test("Big Swamp pulse detects capturable blockers", _test_big_swamp_pulse_detects_capturable_blocker, failures)
	_run_test("Big Swamp pulse detects pawn capture blockers", _test_big_swamp_pulse_detects_pawn_capture_blocker, failures)
	_run_test("Big Swamp pulse allows completion paths through traps", _test_big_swamp_pulse_allows_completion_paths_through_traps, failures)
	_run_test("Big Swamp pulse detects queen completion between traps", _test_big_swamp_pulse_detects_queen_completion_between_traps, failures)
	_run_test("Big Swamp pulse prefers adjacent formation pieces", _test_big_swamp_pulse_prefers_adjacent_target, failures)
	_run_test("Big Swamp pulse targets nearest adjacent piece to trap", _test_big_swamp_pulse_targets_nearest_adjacent_to_trap, failures)
	_run_test("Big Swamp pulse ignores trap gaps", _test_big_swamp_pulse_ignores_trap_gap, failures)
	_run_test("Big Swamp pulse rejects non-completing prediction", _test_big_swamp_pulse_rejects_non_completing_prediction, failures)
	_run_test("Big Swamp pulse rejects loose edge target on empty gap", _test_big_swamp_pulse_rejects_loose_edge_target_on_empty_gap, failures)
	_run_test("Big Swamp pulse targets predicted line piece only", _test_big_swamp_pulse_targets_predicted_line_piece_only, failures)
	_run_test("Big Swamp pulse keeps vertical line position near side helpers", _test_big_swamp_pulse_keeps_vertical_line_position_near_side_helpers, failures)
	_run_test("Big Swamp pulse keeps horizontal line position near side helpers", _test_big_swamp_pulse_keeps_horizontal_line_position_near_side_helpers, failures)
	_run_test("Big Swamp pulse detects bishop completion under nearby trap", _test_big_swamp_pulse_detects_bishop_completion_under_nearby_trap, failures)
	_run_test("Big Swamp pulse detects bishop completion with board noise", _test_big_swamp_pulse_detects_bishop_completion_with_board_noise, failures)
	_run_test("Big Swamp pulse detects diagonal capture blockers", _test_big_swamp_pulse_detects_diagonal_capture_blocker, failures)
	_run_test("Big Swamp pulse rejects empty-gap perpendicular edge target", _test_big_swamp_pulse_rejects_empty_gap_perpendicular_edge_target, failures)
	_run_test("Big Swamp pulse targets horizontal threat instead of opposite diagonal bait", _test_big_swamp_pulse_prefers_horizontal_threat_over_opposite_diagonal_bait, failures)
	_run_test("Big Swamp pulse rejects unattached bottom edge target", _test_big_swamp_pulse_rejects_unattached_bottom_edge_target, failures)
	_run_test("Big Swamp pulse keeps diagonal line position near side helpers", _test_big_swamp_pulse_keeps_diagonal_line_position_near_side_helpers, failures)
	_run_test("Big Swamp pulse ignores distant almost-lines", _test_big_swamp_pulse_ignores_distant_almost_line, failures)
	_run_test("Big Swamp pulse ignores trap-split diagonals", _test_big_swamp_pulse_ignores_trap_split_diagonal, failures)
	_run_test("Big Swamp pulse excludes king targets by default", _test_big_swamp_pulse_excludes_king_target, failures)

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

func _test_big_swamp_pulse_detects_almost_line() -> String:
	var GameBoardScript = load("res://scripts/board/GameBoard.gd")
	var board: Dictionary = {}
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(0, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(1, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(2, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(4, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(3, 3))

	var candidates: Array = GameBoardScript._find_big_swamp_pulse_candidates(board, [Vector2i(4, 1)], false)
	_free_test_board(board)
	if candidates.is_empty():
		return "expected Big Swamp to detect a completable four-piece line"
	var found_expected := false
	for candidate in candidates:
		if candidate.get("missing_line_cell") == Vector2i(3, 0):
			found_expected = true
			if candidate.get("target_piece_cell") == Vector2i(3, 3):
				return "expected target to be part of the threatened formation"
	if not found_expected:
		return "expected missing cell at (3, 0)"
	return ""

func _test_big_swamp_pulse_detects_capturable_blocker() -> String:
	var GameBoardScript = load("res://scripts/board/GameBoard.gd")
	var board: Dictionary = {}
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(0, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(1, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(2, 0))
	_add_test_piece(board, GameManager.PieceType.BISHOP, GameManager.PieceColor.BLUE, Vector2i(3, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(4, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(3, 3))

	var candidates: Array = GameBoardScript._find_big_swamp_pulse_candidates(board, [Vector2i(4, 1)], false)
	var error_message := "expected Big Swamp to detect a blocker that can be captured to complete the line"
	for candidate in candidates:
		if candidate.get("missing_line_cell") == Vector2i(3, 0):
			if candidate.get("target_piece_cell") != Vector2i(4, 0):
				error_message = "expected adjacent line-piece target at (4, 0), got %s" % str(candidate.get("target_piece_cell"))
			else:
				error_message = ""
			break
	_free_test_board(board)
	return error_message

func _test_big_swamp_pulse_detects_pawn_capture_blocker() -> String:
	var GameBoardScript = load("res://scripts/board/GameBoard.gd")
	var board: Dictionary = {}
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.RED, Vector2i(3, 6))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.RED, Vector2i(4, 6))
	_add_test_piece(board, GameManager.PieceType.KNIGHT, GameManager.PieceColor.GREEN, Vector2i(5, 6))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.RED, Vector2i(6, 6))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.RED, Vector2i(7, 6))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.RED, Vector2i(4, 7))

	var candidates: Array = GameBoardScript._find_big_swamp_pulse_candidates(board, [Vector2i(4, 5)], false)
	var error_message := "expected Big Swamp to detect pawn capture blocker"
	for candidate in candidates:
		if candidate.get("missing_line_cell") == Vector2i(5, 6):
			if candidate.get("target_piece_cell") != Vector2i(4, 6):
				error_message = "expected adjacent line-piece target at (4, 6), got %s" % str(candidate.get("target_piece_cell"))
			else:
				error_message = ""
			break
	_free_test_board(board)
	return error_message

func _test_big_swamp_pulse_allows_completion_paths_through_traps() -> String:
	var GameBoardScript = load("res://scripts/board/GameBoard.gd")
	var board: Dictionary = {}
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.BLUE, Vector2i(2, 1))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.BLUE, Vector2i(2, 2))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.BLUE, Vector2i(2, 3))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.BLUE, Vector2i(2, 4))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.BLUE, Vector2i(2, 7))

	var candidates: Array = GameBoardScript._find_big_swamp_pulse_candidates(
		board,
		[Vector2i(3, 4)],
		false,
		[Vector2i(2, 6), Vector2i(3, 4)]
	)
	var error_message := "expected rook path through trap cell to complete vertical line"
	for candidate in candidates:
		if candidate.get("missing_line_cell") == Vector2i(2, 5):
			if candidate.get("target_piece_cell") != Vector2i(2, 4):
				error_message = "expected adjacent line-piece target at (2, 4), got %s" % str(candidate.get("target_piece_cell"))
			else:
				error_message = ""
			break
	_free_test_board(board)
	return error_message

func _test_big_swamp_pulse_detects_queen_completion_between_traps() -> String:
	var GameBoardScript = load("res://scripts/board/GameBoard.gd")
	var board: Dictionary = {}
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.BLUE, Vector2i(6, 2))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.BLUE, Vector2i(6, 3))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.BLUE, Vector2i(6, 4))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.BLUE, Vector2i(6, 5))
	_add_test_piece(board, GameManager.PieceType.QUEEN, GameManager.PieceColor.BLUE, Vector2i(7, 1))

	var candidates: Array = GameBoardScript._find_big_swamp_pulse_candidates(
		board,
		[Vector2i(5, 1), Vector2i(7, 4)],
		false
	)
	var error_message := "expected queen at (7, 1) to threaten vertical line 6,1-6,5"
	for candidate in candidates:
		if candidate.get("missing_line_cell") == Vector2i(6, 1):
			var target_cell: Vector2i = candidate.get("target_piece_cell")
			if target_cell != Vector2i(6, 2) and target_cell != Vector2i(6, 4):
				error_message = "expected line-piece target adjacent to one trap, got %s" % str(target_cell)
			else:
				error_message = ""
			break
	_free_test_board(board)
	return error_message

func _test_big_swamp_pulse_prefers_adjacent_target() -> String:
	var GameBoardScript = load("res://scripts/board/GameBoard.gd")
	var board: Dictionary = {}
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(0, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(1, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(2, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(4, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(3, 3))

	var target: Vector2i = GameBoardScript._select_big_swamp_pulse_target(
		board,
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(4, 0)],
		Vector2i(3, 0),
		Vector2i(1, 0),
		[Vector2i(3, 1)],
		false
	)
	_free_test_board(board)

	if target != Vector2i(2, 0) and target != Vector2i(4, 0):
		return "expected target adjacent to missing cell, got %s" % str(target)
	return ""

func _test_big_swamp_pulse_targets_nearest_adjacent_to_trap() -> String:
	var GameBoardScript = load("res://scripts/board/GameBoard.gd")
	var board: Dictionary = {}
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(3, 1))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(3, 2))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(3, 4))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(3, 5))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(0, 3))

	var target: Vector2i = GameBoardScript._select_big_swamp_pulse_target(
		board,
		[Vector2i(3, 1), Vector2i(3, 2), Vector2i(3, 3), Vector2i(3, 4), Vector2i(3, 5)],
		Vector2i(3, 3),
		Vector2i(0, 1),
		[Vector2i(4, 4)],
		false
	)
	_free_test_board(board)

	if target != Vector2i(3, 4):
		return "expected nearest adjacent target to trap, got %s" % str(target)
	return ""

func _test_big_swamp_pulse_ignores_trap_gap() -> String:
	var GameBoardScript = load("res://scripts/board/GameBoard.gd")
	var board: Dictionary = {}
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(0, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(1, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(2, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(4, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(3, 3))

	var candidates: Array = GameBoardScript._find_big_swamp_pulse_candidates(
		board,
		[Vector2i(6, 6)],
		false,
		[Vector2i(3, 0), Vector2i(6, 6)]
	)
	var error_message := ""
	for candidate in candidates:
		if candidate.get("missing_line_cell") == Vector2i(3, 0):
			error_message = "trap cell was treated as a completable line gap"
			break
	_free_test_board(board)
	return error_message

func _test_big_swamp_pulse_rejects_non_completing_prediction() -> String:
	var GameBoardScript = load("res://scripts/board/GameBoard.gd")
	var board: Dictionary = {}
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(0, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(1, 0))
	_add_test_piece(board, GameManager.PieceType.BISHOP, GameManager.PieceColor.BLUE, Vector2i(2, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(4, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(3, 3))

	var candidates: Array = GameBoardScript._find_big_swamp_pulse_candidates(board, [Vector2i(4, 1)], false)
	var error_message := ""
	for candidate in candidates:
		if candidate.get("missing_line_cell") == Vector2i(3, 0):
			error_message = "accepted a prediction that still would not complete the line"
			break
		_free_test_board(board)
	return error_message

func _test_big_swamp_pulse_rejects_loose_edge_target_on_empty_gap() -> String:
	var GameBoardScript = load("res://scripts/board/GameBoard.gd")
	var board: Dictionary = {}
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.BLUE, Vector2i(0, 0))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.BLUE, Vector2i(1, 1))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.BLUE, Vector2i(2, 2))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.BLUE, Vector2i(4, 4))
	_add_test_piece(board, GameManager.PieceType.BISHOP, GameManager.PieceColor.BLUE, Vector2i(1, 5))

	var candidates: Array = GameBoardScript._find_big_swamp_pulse_candidates(board, [Vector2i(0, 1)], false)
	var error_message := ""
	for candidate in candidates:
		if candidate.get("target_piece_cell") == Vector2i(0, 0):
			error_message = "loose edge piece was targeted for an empty-gap line"
			break
	_free_test_board(board)
	return error_message

func _test_big_swamp_pulse_targets_predicted_line_piece_only() -> String:
	var GameBoardScript = load("res://scripts/board/GameBoard.gd")
	var board: Dictionary = {}
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(2, 1))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(2, 2))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(2, 3))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(2, 4))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.RED, Vector2i(1, 5))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.RED, Vector2i(3, 5))

	var candidates: Array = GameBoardScript._find_big_swamp_pulse_candidates(board, [Vector2i(3, 4)], false)
	var found_expected := false
	var error_message := ""
	for candidate in candidates:
		if candidate.get("target_piece_cell") == Vector2i(3, 5):
			error_message = "targeted helper piece outside predicted line"
			break
		if candidate.get("missing_line_cell") == Vector2i(2, 5):
			found_expected = true
			if candidate.get("target_piece_cell") != Vector2i(2, 4):
				error_message = "expected vertical line target at (2, 4), got %s" % str(candidate.get("target_piece_cell"))
				break
	_free_test_board(board)
	if error_message != "":
		return error_message
	if not found_expected:
		return "expected vertical pre-complete line at x=2"
	return ""

func _test_big_swamp_pulse_keeps_vertical_line_position_near_side_helpers() -> String:
	var GameBoardScript = load("res://scripts/board/GameBoard.gd")
	var board: Dictionary = {}
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(2, 1))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(2, 2))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(2, 3))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(2, 4))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.RED, Vector2i(1, 5))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.RED, Vector2i(3, 5))

	var expected_line: Array[Vector2i] = [Vector2i(2, 1), Vector2i(2, 2), Vector2i(2, 3), Vector2i(2, 4), Vector2i(2, 5)]
	var candidates: Array = GameBoardScript._find_big_swamp_pulse_candidates(board, [Vector2i(3, 4)], false)
	var error_message: String = _assert_only_expected_line_candidate(
		candidates,
		expected_line,
		Vector2i(2, 5),
		Vector2i(2, 4),
		[Vector2i(1, 5), Vector2i(3, 5)]
	)
	_free_test_board(board)
	return error_message

func _test_big_swamp_pulse_keeps_horizontal_line_position_near_side_helpers() -> String:
	var GameBoardScript = load("res://scripts/board/GameBoard.gd")
	var board: Dictionary = {}
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.BLUE, Vector2i(1, 2))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.BLUE, Vector2i(2, 2))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.BLUE, Vector2i(3, 2))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.BLUE, Vector2i(4, 2))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.BLUE, Vector2i(5, 1))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.BLUE, Vector2i(5, 3))

	var expected_line: Array[Vector2i] = [Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2), Vector2i(4, 2), Vector2i(5, 2)]
	var candidates: Array = GameBoardScript._find_big_swamp_pulse_candidates(board, [Vector2i(4, 3)], false)
	var error_message: String = _assert_only_expected_line_candidate(
		candidates,
		expected_line,
		Vector2i(5, 2),
		Vector2i(4, 2),
		[Vector2i(5, 1), Vector2i(5, 3)]
	)
	_free_test_board(board)
	return error_message

func _test_big_swamp_pulse_detects_bishop_completion_under_nearby_trap() -> String:
	var GameBoardScript = load("res://scripts/board/GameBoard.gd")
	var board: Dictionary = {}
	_add_test_piece(board, GameManager.PieceType.BISHOP, GameManager.PieceColor.BLUE, Vector2i(5, 0))
	_add_test_piece(board, GameManager.PieceType.BISHOP, GameManager.PieceColor.BLUE, Vector2i(2, 2))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.BLUE, Vector2i(4, 2))
	_add_test_piece(board, GameManager.PieceType.KNIGHT, GameManager.PieceColor.BLUE, Vector2i(5, 2))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.BLUE, Vector2i(6, 2))

	var expected_line: Array[Vector2i] = [Vector2i(2, 2), Vector2i(3, 2), Vector2i(4, 2), Vector2i(5, 2), Vector2i(6, 2)]
	var candidates: Array = GameBoardScript._find_big_swamp_pulse_candidates(board, [Vector2i(3, 1)], false)
	var error_message: String = _assert_only_expected_line_candidate(
		candidates,
		expected_line,
		Vector2i(3, 2),
		Vector2i(2, 2),
		[Vector2i(5, 0)]
	)
	_free_test_board(board)
	return error_message

func _test_big_swamp_pulse_detects_bishop_completion_with_board_noise() -> String:
	var GameBoardScript = load("res://scripts/board/GameBoard.gd")
	var board: Dictionary = {}
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.RED, Vector2i(0, 0))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.BLUE, Vector2i(2, 0))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.GREEN, Vector2i(4, 0))
	_add_test_piece(board, GameManager.PieceType.BISHOP, GameManager.PieceColor.BLUE, Vector2i(5, 0))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.BLUE, Vector2i(0, 1))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.RED, Vector2i(2, 1))
	_add_test_piece(board, GameManager.PieceType.QUEEN, GameManager.PieceColor.RED, Vector2i(5, 1))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.RED, Vector2i(6, 1))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.GREEN, Vector2i(7, 1))
	_add_test_piece(board, GameManager.PieceType.BISHOP, GameManager.PieceColor.ORANGE, Vector2i(0, 2))
	_add_test_piece(board, GameManager.PieceType.BISHOP, GameManager.PieceColor.BLUE, Vector2i(2, 2))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.BLUE, Vector2i(4, 2))
	_add_test_piece(board, GameManager.PieceType.KNIGHT, GameManager.PieceColor.BLUE, Vector2i(5, 2))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.BLUE, Vector2i(6, 2))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.GREEN, Vector2i(7, 2))
	_add_test_piece(board, GameManager.PieceType.BISHOP, GameManager.PieceColor.ORANGE, Vector2i(0, 3))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.BLUE, Vector2i(2, 4))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.RED, Vector2i(7, 4))
	_add_test_piece(board, GameManager.PieceType.KNIGHT, GameManager.PieceColor.GREEN, Vector2i(2, 5))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.BLUE, Vector2i(7, 5))
	_add_test_piece(board, GameManager.PieceType.BISHOP, GameManager.PieceColor.RED, Vector2i(0, 7))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.GREEN, Vector2i(3, 7))
	_add_test_piece(board, GameManager.PieceType.KNIGHT, GameManager.PieceColor.ORANGE, Vector2i(5, 7))
	_add_test_piece(board, GameManager.PieceType.KNIGHT, GameManager.PieceColor.ORANGE, Vector2i(7, 7))

	var expected_line: Array[Vector2i] = [Vector2i(2, 2), Vector2i(3, 2), Vector2i(4, 2), Vector2i(5, 2), Vector2i(6, 2)]
	var candidates: Array = GameBoardScript._find_big_swamp_pulse_candidates(
		board,
		[Vector2i(3, 1)],
		false,
		[Vector2i(3, 0), Vector2i(3, 1)]
	)
	var error_message: String = _assert_only_expected_line_candidate(
		candidates,
		expected_line,
		Vector2i(3, 2),
		Vector2i(2, 2),
		[Vector2i(5, 0)]
	)
	_free_test_board(board)
	return error_message

func _test_big_swamp_pulse_detects_diagonal_capture_blocker() -> String:
	var GameBoardScript = load("res://scripts/board/GameBoard.gd")
	var board: Dictionary = {}
	_add_test_piece(board, GameManager.PieceType.BISHOP, GameManager.PieceColor.RED, Vector2i(0, 2))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.RED, Vector2i(1, 3))
	_add_test_piece(board, GameManager.PieceType.KNIGHT, GameManager.PieceColor.RED, Vector2i(2, 4))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.BLUE, Vector2i(3, 5))
	_add_test_piece(board, GameManager.PieceType.QUEEN, GameManager.PieceColor.RED, Vector2i(4, 6))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(3, 4))

	var candidates: Array = GameBoardScript._find_big_swamp_pulse_candidates(board, [Vector2i(4, 5)], false)
	var error_message := "expected Big Swamp to detect diagonal capture blocker"
	for candidate in candidates:
		if candidate.get("missing_line_cell") == Vector2i(3, 5):
			if candidate.get("target_piece_cell") != Vector2i(4, 6):
				error_message = "expected adjacent line-piece target at (4, 6), got %s" % str(candidate.get("target_piece_cell"))
			else:
				error_message = ""
			break
	_free_test_board(board)
	return error_message

func _test_big_swamp_pulse_rejects_empty_gap_perpendicular_edge_target() -> String:
	var GameBoardScript = load("res://scripts/board/GameBoard.gd")
	var board: Dictionary = {}
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.RED, Vector2i(3, 4))
	_add_test_piece(board, GameManager.PieceType.BISHOP, GameManager.PieceColor.RED, Vector2i(4, 3))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.RED, Vector2i(5, 2))
	_add_test_piece(board, GameManager.PieceType.KNIGHT, GameManager.PieceColor.RED, Vector2i(7, 0))
	_add_test_piece(board, GameManager.PieceType.QUEEN, GameManager.PieceColor.RED, Vector2i(6, 3))
	_add_test_piece(board, GameManager.PieceType.KNIGHT, GameManager.PieceColor.RED, Vector2i(7, 3))

	var candidates: Array = GameBoardScript._find_big_swamp_pulse_candidates(board, [Vector2i(4, 5)], false)
	var error_message := ""
	for candidate in candidates:
		if candidate.get("target_piece_cell") == Vector2i(3, 4):
			error_message = "empty-gap edge target was accepted from the perpendicular side"
			break
		if candidate.get("missing_line_cell") == Vector2i(6, 1):
			error_message = "empty-gap diagonal threat was accepted from the perpendicular side"
			break
	_free_test_board(board)
	return error_message

func _test_big_swamp_pulse_prefers_horizontal_threat_over_opposite_diagonal_bait() -> String:
	var GameBoardScript = load("res://scripts/board/GameBoard.gd")
	var board: Dictionary = {}
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.BLUE, Vector2i(3, 6))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.BLUE, Vector2i(4, 6))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.BLUE, Vector2i(5, 6))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.BLUE, Vector2i(7, 6))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.BLUE, Vector2i(6, 5))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.RED, Vector2i(3, 4))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.RED, Vector2i(4, 3))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.RED, Vector2i(5, 2))
	_add_test_piece(board, GameManager.PieceType.KNIGHT, GameManager.PieceColor.RED, Vector2i(7, 0))
	_add_test_piece(board, GameManager.PieceType.QUEEN, GameManager.PieceColor.RED, Vector2i(6, 3))

	var expected_line: Array[Vector2i] = [Vector2i(3, 6), Vector2i(4, 6), Vector2i(5, 6), Vector2i(6, 6), Vector2i(7, 6)]
	var candidates: Array = GameBoardScript._find_big_swamp_pulse_candidates(board, [Vector2i(4, 5)], false)
	var error_message: String = _assert_only_expected_line_candidate(
		candidates,
		expected_line,
		Vector2i(6, 6),
		Vector2i(5, 6),
		[Vector2i(3, 4)]
	)
	_free_test_board(board)
	return error_message

func _test_big_swamp_pulse_rejects_unattached_bottom_edge_target() -> String:
	var GameBoardScript = load("res://scripts/board/GameBoard.gd")
	var board: Dictionary = {}
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.RED, Vector2i(0, 0))
	_add_test_piece(board, GameManager.PieceType.KNIGHT, GameManager.PieceColor.BLUE, Vector2i(2, 0))
	_add_test_piece(board, GameManager.PieceType.BISHOP, GameManager.PieceColor.GREEN, Vector2i(3, 0))
	_add_test_piece(board, GameManager.PieceType.KNIGHT, GameManager.PieceColor.ORANGE, Vector2i(4, 0))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.RED, Vector2i(6, 0))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.BLUE, Vector2i(7, 0))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.GREEN, Vector2i(0, 1))
	_add_test_piece(board, GameManager.PieceType.BISHOP, GameManager.PieceColor.BLUE, Vector2i(2, 1))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.ORANGE, Vector2i(3, 1))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.ORANGE, Vector2i(4, 1))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.GREEN, Vector2i(5, 1))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.ORANGE, Vector2i(6, 1))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.ORANGE, Vector2i(7, 1))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.GREEN, Vector2i(0, 2))
	_add_test_piece(board, GameManager.PieceType.KNIGHT, GameManager.PieceColor.GREEN, Vector2i(1, 2))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.BLUE, Vector2i(2, 2))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.BLUE, Vector2i(5, 2))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.BLUE, Vector2i(6, 2))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.BLUE, Vector2i(7, 2))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.RED, Vector2i(0, 3))
	_add_test_piece(board, GameManager.PieceType.QUEEN, GameManager.PieceColor.GREEN, Vector2i(1, 3))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.ORANGE, Vector2i(2, 3))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.GREEN, Vector2i(3, 3))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.BLUE, Vector2i(4, 3))
	_add_test_piece(board, GameManager.PieceType.KING, GameManager.PieceColor.ORANGE, Vector2i(5, 3))
	_add_test_piece(board, GameManager.PieceType.BISHOP, GameManager.PieceColor.ORANGE, Vector2i(7, 3))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.ORANGE, Vector2i(0, 4))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.RED, Vector2i(1, 4))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.GREEN, Vector2i(2, 4))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.RED, Vector2i(4, 4))
	_add_test_piece(board, GameManager.PieceType.KNIGHT, GameManager.PieceColor.BLUE, Vector2i(5, 4))
	_add_test_piece(board, GameManager.PieceType.QUEEN, GameManager.PieceColor.BLUE, Vector2i(6, 4))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.GREEN, Vector2i(0, 5))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.GREEN, Vector2i(1, 5))
	_add_test_piece(board, GameManager.PieceType.QUEEN, GameManager.PieceColor.RED, Vector2i(2, 5))
	_add_test_piece(board, GameManager.PieceType.BISHOP, GameManager.PieceColor.RED, Vector2i(3, 5))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.ORANGE, Vector2i(4, 5))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.GREEN, Vector2i(5, 5))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.RED, Vector2i(6, 5))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(7, 5))
	_add_test_piece(board, GameManager.PieceType.BISHOP, GameManager.PieceColor.BLUE, Vector2i(0, 6))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.GREEN, Vector2i(1, 6))
	_add_test_piece(board, GameManager.PieceType.BISHOP, GameManager.PieceColor.RED, Vector2i(3, 6))
	_add_test_piece(board, GameManager.PieceType.BISHOP, GameManager.PieceColor.GREEN, Vector2i(4, 6))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.RED, Vector2i(5, 6))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.BLUE, Vector2i(6, 6))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.ORANGE, Vector2i(7, 6))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.GREEN, Vector2i(0, 7))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.RED, Vector2i(1, 7))
	_add_test_piece(board, GameManager.PieceType.KNIGHT, GameManager.PieceColor.ORANGE, Vector2i(2, 7))
	_add_test_piece(board, GameManager.PieceType.QUEEN, GameManager.PieceColor.ORANGE, Vector2i(3, 7))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.BLUE, Vector2i(4, 7))
	_add_test_piece(board, GameManager.PieceType.KNIGHT, GameManager.PieceColor.GREEN, Vector2i(5, 7))
	_add_test_piece(board, GameManager.PieceType.BISHOP, GameManager.PieceColor.ORANGE, Vector2i(6, 7))

	var target_cell := Vector2i(1, 7)
	var candidates: Array = GameBoardScript._find_big_swamp_pulse_candidates(board, [Vector2i(2, 6)], false)
	var error_message := ""
	for candidate in candidates:
		if candidate.get("target_piece_cell") == target_cell:
			error_message = "unattached bottom-edge target was selected"
			break
	_free_test_board(board)
	return error_message

func _test_big_swamp_pulse_keeps_diagonal_line_position_near_side_helpers() -> String:
	var GameBoardScript = load("res://scripts/board/GameBoard.gd")
	var board: Dictionary = {}
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.GREEN, Vector2i(1, 1))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.GREEN, Vector2i(2, 2))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.GREEN, Vector2i(3, 3))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.GREEN, Vector2i(4, 4))
	_add_test_piece(board, GameManager.PieceType.QUEEN, GameManager.PieceColor.GREEN, Vector2i(6, 5))

	var expected_line: Array[Vector2i] = [Vector2i(1, 1), Vector2i(2, 2), Vector2i(3, 3), Vector2i(4, 4), Vector2i(5, 5)]
	var candidates: Array = GameBoardScript._find_big_swamp_pulse_candidates(board, [Vector2i(3, 4)], false)
	var error_message: String = _assert_only_expected_line_candidate(
		candidates,
		expected_line,
		Vector2i(5, 5),
		Vector2i(4, 4),
		[Vector2i(6, 5)]
	)
	_free_test_board(board)
	return error_message

func _test_big_swamp_pulse_ignores_distant_almost_line() -> String:
	var GameBoardScript = load("res://scripts/board/GameBoard.gd")
	var board: Dictionary = {}
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(0, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(1, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(2, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(4, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(3, 3))

	var candidates: Array = GameBoardScript._find_big_swamp_pulse_candidates(board, [Vector2i(7, 7)], false)
	_free_test_board(board)
	if not candidates.is_empty():
		return "distant trap reacted to an almost-line outside swamp reach"
	return ""

func _test_big_swamp_pulse_ignores_trap_split_diagonal() -> String:
	var GameBoardScript = load("res://scripts/board/GameBoard.gd")
	var board: Dictionary = {}
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.GREEN, Vector2i(6, 1))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.GREEN, Vector2i(4, 3))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.GREEN, Vector2i(3, 4))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.GREEN, Vector2i(2, 5))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.GREEN, Vector2i(1, 6))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.GREEN, Vector2i(7, 4))

	var trap_cell := Vector2i(5, 2)
	var candidates: Array = GameBoardScript._find_big_swamp_pulse_candidates(board, [trap_cell], false)
	var error_message := ""
	for candidate in candidates:
		if candidate.get("target_piece_cell") == Vector2i(7, 4):
			error_message = "trap-split diagonal let swamp target (7, 4)"
			break
		if trap_cell in candidate.get("candidate_line_cells", []):
			error_message = "trap cell was included in a predicted diagonal line"
			break
	_free_test_board(board)
	return error_message

func _test_big_swamp_pulse_excludes_king_target() -> String:
	var GameBoardScript = load("res://scripts/board/GameBoard.gd")
	var board: Dictionary = {}
	_add_test_piece(board, GameManager.PieceType.KING, GameManager.PieceColor.RED, Vector2i(0, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(1, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(2, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(4, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(3, 3))

	var candidates: Array = GameBoardScript._find_big_swamp_pulse_candidates(board, [Vector2i(1, 1)], false)
	var error_message := ""
	if candidates.is_empty():
		error_message = "expected a king-led almost-line candidate"
	else:
		for candidate in candidates:
			if candidate.get("target_piece_cell") == Vector2i(0, 0):
				error_message = "king was selected as a pulse target"
				break
	_free_test_board(board)
	return error_message

func _add_test_piece(board: Dictionary, piece_type: int, piece_color: int, cell: Vector2i):
	var PieceScript = load("res://scripts/piece/Piece.gd")
	var piece = PieceScript.new()
	piece.piece_type = piece_type
	piece.piece_color = piece_color
	piece.grid_position = cell
	board[cell] = piece

func _assert_only_expected_line_candidate(candidates: Array, expected_line: Array, expected_missing: Vector2i, expected_target: Vector2i, forbidden_targets: Array) -> String:
	var found_expected := false
	for candidate in candidates:
		var target_cell: Vector2i = candidate.get("target_piece_cell")
		if target_cell in forbidden_targets:
			return "targeted side helper outside predicted line: %s" % str(target_cell)
		if candidate.get("missing_line_cell") != expected_missing:
			continue
		if not _same_cells(candidate.get("candidate_line_cells", []), expected_line):
			return "shifted predicted line to %s" % str(candidate.get("candidate_line_cells", []))
		found_expected = true
		if target_cell != expected_target:
			return "expected target %s, got %s" % [str(expected_target), str(target_cell)]
	if not found_expected:
		return "expected candidate line %s" % str(expected_line)
	return ""

func _same_cells(a: Array, b: Array) -> bool:
	if a.size() != b.size():
		return false
	for i in range(a.size()):
		if a[i] != b[i]:
			return false
	return true

func _free_test_board(board: Dictionary):
	for piece in board.values():
		if is_instance_valid(piece):
			piece.free()
	board.clear()
