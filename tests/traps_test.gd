extends SceneTree

class FakeLegalMovePiece:
	extends RefCounted

	var moves: Array
	var captures: Array

	func _init(initial_moves: Array = [], initial_captures: Array = []):
		moves = initial_moves
		captures = initial_captures

	func get_legal_moves(_board: Dictionary) -> Array:
		return moves

	func get_legal_captures(_board: Dictionary) -> Array:
		return captures

func _initialize():
	var failures: Array[String] = []

	_run_test("uses configured trap count by level", _test_trap_count_by_level, failures)
	_run_test("uses configured trap rotation limits by level", _test_trap_rotation_limits_by_level, failures)
	_run_test("uses independent trap rotation frequency", _test_trap_rotation_frequency, failures)
	_run_test("uses kingdom trap profile values", _test_kingdom_trap_profile_values, failures)
	_run_test("rotates every trap to a new empty cell", _test_trap_rotation_selects_new_empty_cells, failures)
	_run_test("uses common trap library definition", _test_common_trap_library, failures)
	_run_test("board stores trap type references", _test_board_trap_type_reference, failures)
	_run_test("board selects trap details", _test_board_selects_trap_details, failures)
	_run_test("traps are excluded from empty spawn cells", _test_traps_excluded_from_empty_cells, failures)
	_run_test("moving onto a trap sacrifices the piece", _test_trap_sacrifices_piece, failures)
	_run_test("trap-only moves do not keep game alive", _test_trap_only_moves_do_not_keep_game_alive, failures)
	_run_test("trap detector rejects trap as fifth line cell", _test_trap_detector_rejects_trap_as_fifth_line_cell, failures)
	_run_test("trap detector finds attackable wrong-cell completion", _test_trap_detector_finds_attackable_wrong_cell, failures)
	_run_test("trap detector finds attackable empty-cell completion", _test_trap_detector_finds_attackable_empty_cell, failures)
	_run_test("trap detector requires adjacent piece to match", _test_trap_detector_requires_adjacent_match, failures)
	_run_test("trap detector excludes king attackers", _test_trap_detector_excludes_king_attackers, failures)
	_run_test("trap detector uses reference pawn attack directions", _test_trap_detector_uses_reference_pawn_directions, failures)
	_run_test("trap detector finds offset knight edge completion", _test_trap_detector_finds_offset_knight_edge_completion, failures)
	_run_test("trap detector finds diagonal knight blocker capture", _test_trap_detector_finds_diagonal_knight_blocker_capture, failures)
	_run_test("trap detector prioritizes diagonal knight blocker capture with board noise", _test_trap_detector_prioritizes_diagonal_knight_blocker_capture_with_board_noise, failures)
	_run_test("trap detector finds diagonal queen gap completion", _test_trap_detector_finds_diagonal_queen_gap_completion, failures)
	_run_test("trap detector finds vertical pawn blocker capture from endpoint trap", _test_trap_detector_finds_vertical_pawn_blocker_capture_from_endpoint_trap, failures)
	_run_test("trap detector may target any candidate line piece", _test_trap_detector_may_target_any_candidate_line_piece, failures)
	_run_test("trap detector rejects edge run with trap before first cell", _test_trap_detector_rejects_edge_run_with_trap_before_first_cell, failures)
	_run_test("trap detector rejects trap inside candidate line", _test_trap_detector_rejects_trap_inside_candidate_line, failures)
	_run_test("trap detector rejects backward blue pawn attack", Callable(self, "_test_trap_detector_rejects_backward_blue_pawn_attack"), failures)
	_run_test("trap detector rejects mixed king diagonal bait", Callable(self, "_test_trap_detector_rejects_mixed_king_diagonal_bait"), failures)
	_run_test("trap detector rejects full-board king diagonal bait", Callable(self, "_test_trap_detector_rejects_full_board_king_diagonal_bait"), failures)
	_run_test("Big Swamp pulse rejects non-completing vertical gap with blocker", Callable(self, "_test_big_swamp_pulse_rejects_non_completing_vertical_gap_with_blocker"), failures)
	_run_test("Big Swamp pulse rejects king-led candidate lines", Callable(self, "_test_big_swamp_pulse_rejects_king_led_candidate_line"), failures)
	_run_test("Big Swamp pulse uses trap detector target", _test_big_swamp_pulse_uses_trap_detector_target, failures)
	_run_test("Big Swamp pulse rejects changed target identity", _test_big_swamp_pulse_rejects_changed_target_identity, failures)

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

func _test_kingdom_trap_profile_values() -> String:
	var game_board_script = load("res://scripts/board/GameBoard.gd")
	if game_board_script._get_trap_count_for_level(0, "default") != 10:
		return "expected default kingdom trap count profile"
	if game_board_script._get_trap_count_for_level(0, "neon") != 10:
		return "expected neon kingdom trap count profile"
	if game_board_script._get_trap_count_for_level(0, "missing") != 10:
		return "expected missing kingdom to use default trap profile"
	if not is_equal_approx(game_board_script._get_big_swamp_pulse_probability_for_level(1, "default"), 0.20):
		return "expected default Big Swamp pulse profile"
	if game_board_script._is_trap_rotation_enabled_for_kingdom("default"):
		return "expected default trap rotation profile to be disabled"
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

func _test_trap_only_moves_do_not_keep_game_alive() -> String:
	var BoardManagerScript = load("res://scripts/board/BoardManager.gd")
	var board_manager = BoardManagerScript.new()
	board_manager.board_size = 8
	board_manager.set_traps([Vector2i(0, 1), Vector2i(1, 0), Vector2i(1, 1)])
	board_manager.board[Vector2i(0, 0)] = FakeLegalMovePiece.new([
		Vector2i(0, 1),
		Vector2i(1, 0),
		Vector2i(1, 1),
	])

	var has_moves: bool = board_manager.has_legal_moves()
	board_manager.free()
	if has_moves:
		return "trap-only destinations were counted as eligible game-preserving moves"
	return ""

func _test_trap_detector_rejects_trap_as_fifth_line_cell() -> String:
	var Detector = load("res://scripts/traps/TrapLineDetector.gd")
	var board: Dictionary = {}
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(1, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(2, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(3, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(4, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(0, 2))

	var candidates: Array = Detector.detect_trap_lines(board, [Vector2i(0, 0)])
	var error_message := ""
	for candidate in candidates:
		if candidate.get("completion_target_cell") == Vector2i(0, 0):
			error_message = "trap cell was accepted as the missing fifth line cell"
			break
	_free_test_board(board)
	return error_message

func _test_trap_detector_finds_attackable_wrong_cell() -> String:
	var Detector = load("res://scripts/traps/TrapLineDetector.gd")
	var board: Dictionary = {}
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.BLUE, Vector2i(1, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.BLUE, Vector2i(2, 0))
	_add_test_piece(board, GameManager.PieceType.BISHOP, GameManager.PieceColor.RED, Vector2i(3, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.BLUE, Vector2i(4, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.BLUE, Vector2i(5, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.BLUE, Vector2i(3, 3))

	var candidate: Dictionary = Detector.find_first_trap_candidate(board, [Vector2i(2, 1)])
	var error_message := ""
	if candidate.is_empty():
		error_message = "expected four-of-five wrong-cell candidate"
	elif candidate.get("completion_target_cell") != Vector2i(3, 0):
		error_message = "wrong completion target"
	elif candidate.get("attacker_cell") != Vector2i(3, 3):
		error_message = "expected external matching rook to attack wrong cell"
	elif candidate.get("target_piece_cell") != Vector2i(2, 0):
		error_message = "trap animation target should be edge piece bordering the blocker"
	_free_test_board(board)
	return error_message

func _test_trap_detector_finds_attackable_empty_cell() -> String:
	var Detector = load("res://scripts/traps/TrapLineDetector.gd")
	var board: Dictionary = {}
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.GREEN, Vector2i(1, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.GREEN, Vector2i(2, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.GREEN, Vector2i(4, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.GREEN, Vector2i(5, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.GREEN, Vector2i(3, 3))

	var candidate: Dictionary = Detector.find_first_trap_candidate(board, [Vector2i(2, 1)])
	var error_message := ""
	if candidate.is_empty():
		error_message = "expected four-of-five empty-cell candidate"
	elif candidate.get("completion_target_cell") != Vector2i(3, 0):
		error_message = "wrong empty completion target"
	elif candidate.get("attacker_cell") != Vector2i(3, 3):
		error_message = "expected external rook to attack empty target"
	_free_test_board(board)
	return error_message

func _test_trap_detector_requires_adjacent_match() -> String:
	var Detector = load("res://scripts/traps/TrapLineDetector.gd")
	var board: Dictionary = {}
	_add_test_piece(board, GameManager.PieceType.BISHOP, GameManager.PieceColor.ORANGE, Vector2i(1, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(2, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(3, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(4, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(5, 0))

	var candidates: Array = Detector.detect_trap_lines(board, [Vector2i(0, 0)])
	_free_test_board(board)
	if not candidates.is_empty():
		return "adjacent non-matching piece produced a candidate"
	return ""

func _test_trap_detector_excludes_king_attackers() -> String:
	var Detector = load("res://scripts/traps/TrapLineDetector.gd")
	var board: Dictionary = {}
	_add_test_piece(board, GameManager.PieceType.KING, GameManager.PieceColor.RED, Vector2i(1, 0))
	_add_test_piece(board, GameManager.PieceType.KING, GameManager.PieceColor.RED, Vector2i(2, 0))
	_add_test_piece(board, GameManager.PieceType.KING, GameManager.PieceColor.RED, Vector2i(3, 0))
	_add_test_piece(board, GameManager.PieceType.KING, GameManager.PieceColor.RED, Vector2i(4, 0))

	var candidates: Array = Detector.detect_trap_lines(board, [Vector2i(0, 0)])
	_free_test_board(board)
	if not candidates.is_empty():
		return "king attackers produced a candidate"
	return ""

func _test_trap_detector_uses_reference_pawn_directions() -> String:
	var Detector = load("res://scripts/traps/TrapLineDetector.gd")
	var board: Dictionary = {}
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.RED, Vector2i(1, 1))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.BLUE, Vector2i(4, 1))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.GREEN, Vector2i(6, 3))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.ORANGE, Vector2i(6, 6))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.BLUE, Vector2i(2, 2))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.RED, Vector2i(3, 2))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.RED, Vector2i(5, 4))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.RED, Vector2i(5, 5))

	var red_moves_right: bool = Detector.can_move_to(board, Vector2i(1, 1), Vector2i(2, 1))
	var red_attacks_right: bool = Detector.can_move_to(board, Vector2i(1, 1), Vector2i(2, 2))
	var blue_attacks_down: bool = Detector.can_move_to(board, Vector2i(4, 1), Vector2i(3, 2))
	var blue_moves_down: bool = Detector.can_move_to(board, Vector2i(4, 1), Vector2i(4, 2))
	var blue_attacks_empty_diagonal: bool = Detector.can_move_to(board, Vector2i(4, 1), Vector2i(5, 2))
	var blue_attacks_up: bool = Detector.can_move_to(board, Vector2i(4, 1), Vector2i(3, 0))
	var green_attacks_left: bool = Detector.can_move_to(board, Vector2i(6, 3), Vector2i(5, 4))
	var orange_attacks_up: bool = Detector.can_move_to(board, Vector2i(6, 6), Vector2i(5, 5))
	_free_test_board(board)
	if not red_moves_right:
		return "expected red pawn to move right into an empty cell"
	if not red_attacks_right:
		return "expected red pawn to capture on right diagonals"
	if not blue_attacks_down:
		return "expected blue pawn to capture downward diagonals"
	if not blue_moves_down:
		return "expected blue pawn to move down into an empty cell"
	if blue_attacks_empty_diagonal:
		return "blue pawn treated an empty diagonal as a legal move"
	if blue_attacks_up:
		return "blue pawn attacked backward"
	if not green_attacks_left:
		return "expected green pawn to capture left diagonals"
	if not orange_attacks_up:
		return "expected orange pawn to capture upward diagonals"
	return ""

func _test_trap_detector_finds_offset_knight_edge_completion() -> String:
	var Detector = load("res://scripts/traps/TrapLineDetector.gd")
	var board: Dictionary = {}
	# User case, converted from 1-based row,col notation:
	# line 3,4-7,8; traps at 6,8 / 4,7 / 3,5; knight at 5,7 attacks the 4,5 gap.
	_add_test_piece(board, GameManager.PieceType.KNIGHT, GameManager.PieceColor.BLUE, _pos1(3, 4))
	_add_test_piece(board, GameManager.PieceType.KNIGHT, GameManager.PieceColor.BLUE, _pos1(5, 6))
	_add_test_piece(board, GameManager.PieceType.KNIGHT, GameManager.PieceColor.BLUE, _pos1(6, 7))
	_add_test_piece(board, GameManager.PieceType.KNIGHT, GameManager.PieceColor.BLUE, _pos1(7, 8))
	_add_test_piece(board, GameManager.PieceType.KNIGHT, GameManager.PieceColor.BLUE, _pos1(5, 7))

	var traps: Array[Vector2i] = [_pos1(6, 8), _pos1(4, 7), _pos1(3, 5)]
	var candidates: Array = Detector.detect_trap_lines(board, traps)
	var error_message := "expected trap detector to find offset knight completion"
	for candidate in candidates:
		if candidate.get("completion_target_cell") != _pos1(4, 5):
			continue
		if candidate.get("attacker_cell") != _pos1(5, 7):
			error_message = "expected knight at 5,7 as attacker, got %s" % str(candidate.get("attacker_cell"))
		elif not (candidate.get("target_piece_cell") in [_pos1(3, 4), _pos1(5, 6), _pos1(6, 7), _pos1(7, 8)]):
			error_message = "expected trap capture target to be a candidate line edge, got %s" % str(candidate.get("target_piece_cell"))
		elif not (candidate.get("trap_cell") in traps):
			error_message = "expected one configured trap, got %s" % str(candidate.get("trap_cell"))
		else:
			error_message = ""
		break
	_free_test_board(board)
	return error_message

func _test_trap_detector_finds_diagonal_knight_blocker_capture() -> String:
	var Detector = load("res://scripts/traps/TrapLineDetector.gd")
	var board: Dictionary = {}
	# User case, converted from 1-based column,row board notation:
	# blue knight at 7,5 attacks red knight at 5,6 to complete blue color line 7,4-3,8.
	_add_test_piece(board, GameManager.PieceType.QUEEN, GameManager.PieceColor.BLUE, _colrow(7, 4))
	_add_test_piece(board, GameManager.PieceType.BISHOP, GameManager.PieceColor.BLUE, _colrow(6, 5))
	_add_test_piece(board, GameManager.PieceType.KNIGHT, GameManager.PieceColor.RED, _colrow(5, 6))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.BLUE, _colrow(4, 7))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.BLUE, _colrow(3, 8))
	_add_test_piece(board, GameManager.PieceType.KNIGHT, GameManager.PieceColor.BLUE, _colrow(7, 5))

	var traps: Array[Vector2i] = [_colrow(7, 6), _colrow(5, 8)]
	var candidates: Array = Detector.detect_trap_lines(board, traps)
	var error_message := "expected trap detector to find diagonal knight blocker capture"
	for candidate in candidates:
		if candidate.get("completion_target_cell") != _colrow(5, 6):
			continue
		if candidate.get("attacker_cell") != _colrow(7, 5):
			error_message = "expected knight at 7,5 as attacker, got %s" % str(candidate.get("attacker_cell"))
		elif candidate.get("target_piece_cell") != _colrow(6, 5):
			error_message = "expected trap capture target to be line edge at 6,5"
		elif candidate.get("trap_cell") != _colrow(7, 6):
			error_message = "expected nearest trap at 7,6, got %s" % str(candidate.get("trap_cell"))
		else:
			error_message = ""
		break
	_free_test_board(board)
	return error_message

func _test_trap_detector_prioritizes_diagonal_knight_blocker_capture_with_board_noise() -> String:
	var Detector = load("res://scripts/traps/TrapLineDetector.gd")
	var board: Dictionary = {}
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.GREEN, _colrow(2, 1))
	_add_test_piece(board, GameManager.PieceType.BISHOP, GameManager.PieceColor.ORANGE, _colrow(4, 1))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, _colrow(6, 1))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.ORANGE, _colrow(8, 1))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.ORANGE, _colrow(1, 2))
	_add_test_piece(board, GameManager.PieceType.BISHOP, GameManager.PieceColor.ORANGE, _colrow(2, 2))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.ORANGE, _colrow(3, 2))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.BLUE, _colrow(3, 3))
	_add_test_piece(board, GameManager.PieceType.QUEEN, GameManager.PieceColor.RED, _colrow(4, 3))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.GREEN, _colrow(5, 3))
	_add_test_piece(board, GameManager.PieceType.BISHOP, GameManager.PieceColor.GREEN, _colrow(6, 3))
	_add_test_piece(board, GameManager.PieceType.BISHOP, GameManager.PieceColor.GREEN, _colrow(7, 3))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.ORANGE, _colrow(1, 4))
	_add_test_piece(board, GameManager.PieceType.QUEEN, GameManager.PieceColor.BLUE, _colrow(7, 4))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.BLUE, _colrow(2, 5))
	_add_test_piece(board, GameManager.PieceType.BISHOP, GameManager.PieceColor.BLUE, _colrow(6, 5))
	_add_test_piece(board, GameManager.PieceType.KNIGHT, GameManager.PieceColor.BLUE, _colrow(7, 5))
	_add_test_piece(board, GameManager.PieceType.BISHOP, GameManager.PieceColor.BLUE, _colrow(2, 6))
	_add_test_piece(board, GameManager.PieceType.KNIGHT, GameManager.PieceColor.RED, _colrow(5, 6))
	_add_test_piece(board, GameManager.PieceType.BISHOP, GameManager.PieceColor.RED, _colrow(3, 7))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.BLUE, _colrow(4, 7))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.ORANGE, _colrow(7, 7))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.ORANGE, _colrow(2, 8))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.BLUE, _colrow(3, 8))
	_add_test_piece(board, GameManager.PieceType.KING, GameManager.PieceColor.GREEN, _colrow(6, 8))

	var traps: Array[Vector2i] = [_colrow(7, 6), _colrow(5, 8)]
	var candidates: Array = Detector.detect_trap_lines(board, traps)
	candidates.sort_custom(func(a: Dictionary, b: Dictionary): return int(a.get("score", 0)) > int(b.get("score", 0)))
	var error_message := "expected board-noise candidate list to include diagonal knight blocker capture"
	for candidate in candidates:
		if candidate.get("completion_target_cell") != _colrow(5, 6):
			continue
		if candidate.get("attacker_cell") != _colrow(7, 5):
			error_message = "expected knight at 7,5 as attacker, got %s" % str(candidate.get("attacker_cell"))
		elif candidate.get("trap_cell") != _colrow(7, 6):
			error_message = "expected nearest trap at 7,6, got %s" % str(candidate.get("trap_cell"))
		elif candidates[0] != candidate:
			error_message = "expected diagonal knight blocker capture to be top scored candidate, got %s" % str(candidates[0])
		else:
			error_message = ""
		break
	_free_test_board(board)
	return error_message

func _test_trap_detector_finds_diagonal_queen_gap_completion() -> String:
	var Detector = load("res://scripts/traps/TrapLineDetector.gd")
	var board: Dictionary = {}
	# User case, converted from 1-based column,row board notation:
	# red queen at 6,5 attacks 7,4 to complete red color line 4,1-8,5.
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.RED, _colrow(4, 1))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, _colrow(5, 2))
	_add_test_piece(board, GameManager.PieceType.KNIGHT, GameManager.PieceColor.RED, _colrow(6, 3))
	_add_test_piece(board, GameManager.PieceType.KNIGHT, GameManager.PieceColor.RED, _colrow(8, 5))
	_add_test_piece(board, GameManager.PieceType.QUEEN, GameManager.PieceColor.RED, _colrow(6, 5))

	var candidates: Array = Detector.detect_trap_lines(board, [_colrow(7, 5)])
	var error_message := "expected trap detector to find diagonal queen gap completion"
	for candidate in candidates:
		if candidate.get("completion_target_cell") != _colrow(7, 4):
			continue
		if candidate.get("attacker_cell") != _colrow(6, 5):
			error_message = "expected queen at 6,5 as attacker, got %s" % str(candidate.get("attacker_cell"))
		elif candidate.get("target_piece_cell") != _colrow(8, 5):
			error_message = "expected trap capture target to be line edge at 8,5"
		elif candidate.get("trap_cell") != _colrow(7, 5):
			error_message = "expected trap at 7,5, got %s" % str(candidate.get("trap_cell"))
		else:
			error_message = ""
		break
	_free_test_board(board)
	return error_message

func _test_trap_detector_finds_vertical_pawn_blocker_capture_from_endpoint_trap() -> String:
	var Detector = load("res://scripts/traps/TrapLineDetector.gd")
	var board: Dictionary = {}
	# User case, converted from 1-based column,row board notation:
	# red pawns at 1,3 and 1,5 attack blocker 2,4 in red line 2,2-2,6.
	_add_test_piece(board, GameManager.PieceType.KNIGHT, GameManager.PieceColor.RED, _colrow(2, 2))
	_add_test_piece(board, GameManager.PieceType.BISHOP, GameManager.PieceColor.RED, _colrow(2, 3))
	_add_test_piece(board, GameManager.PieceType.QUEEN, GameManager.PieceColor.BLUE, _colrow(2, 4))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.RED, _colrow(2, 5))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, _colrow(2, 6))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.RED, _colrow(1, 3))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.RED, _colrow(1, 5))

	var traps: Array[Vector2i] = [_colrow(2, 1), _colrow(2, 7)]
	var candidates: Array = Detector.detect_trap_lines(board, traps)
	var error_message := "expected endpoint trap to react to vertical pawn blocker capture"
	for candidate in candidates:
		if candidate.get("completion_target_cell") != _colrow(2, 4):
			continue
		if candidate.get("attacker_cell") != _colrow(1, 3) and candidate.get("attacker_cell") != _colrow(1, 5):
			error_message = "expected one red pawn attacker, got %s" % str(candidate.get("attacker_cell"))
		elif candidate.get("trap_cell") != _colrow(2, 1) and candidate.get("trap_cell") != _colrow(2, 7):
			error_message = "expected trap adjacent to a candidate endpoint, got %s" % str(candidate.get("trap_cell"))
		elif candidate.get("target_piece_cell") != _colrow(2, 2) and candidate.get("target_piece_cell") != _colrow(2, 6):
			error_message = "expected trap target to be a candidate endpoint, got %s" % str(candidate.get("target_piece_cell"))
		else:
			error_message = ""
		break
	_free_test_board(board)
	return error_message

func _test_trap_detector_may_target_any_candidate_line_piece() -> String:
	var Detector = load("res://scripts/traps/TrapLineDetector.gd")
	var matching_cells: Array[Vector2i] = [
		_colrow(1, 1),
		_colrow(2, 2),
		_colrow(3, 3),
		_colrow(4, 4),
	]
	var trap_target: Dictionary = Detector._select_trap_adjacent_to_candidate_piece(
		[_colrow(3, 4)],
		matching_cells,
		1
	)
	if trap_target.is_empty():
		return "expected trap near an interior candidate piece to be selected"
	if trap_target.get("target_piece_cell") != _colrow(3, 3):
		return "expected interior candidate line piece target, got %s" % str(trap_target.get("target_piece_cell"))
	if trap_target.get("trap_cell") != _colrow(3, 4):
		return "expected configured trap cell"
	return ""

func _test_trap_detector_rejects_edge_run_with_trap_before_first_cell() -> String:
	var Detector = load("res://scripts/traps/TrapLineDetector.gd")
	var board: Dictionary = {}
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.GREEN, _colrow(5, 4))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.GREEN, _colrow(6, 4))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.GREEN, _colrow(7, 4))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.GREEN, _colrow(8, 4))
	_add_test_piece(board, GameManager.PieceType.QUEEN, GameManager.PieceColor.GREEN, _colrow(4, 6))

	var trap_cell := _colrow(4, 4)
	var candidates: Array = Detector.detect_trap_lines(board, [trap_cell])
	var error_message := ""
	for candidate in candidates:
		if candidate.get("completion_target_cell") == trap_cell:
			error_message = "trap before edge run was accepted as a playable fifth cell"
			break
	_free_test_board(board)
	return error_message

func _test_trap_detector_rejects_trap_inside_candidate_line() -> String:
	var Detector = load("res://scripts/traps/TrapLineDetector.gd")
	var board: Dictionary = {}
	var trap_cell := _colrow(6, 3)
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.GREEN, _colrow(7, 2))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.GREEN, trap_cell)
	_add_test_piece(board, GameManager.PieceType.KNIGHT, GameManager.PieceColor.ORANGE, _colrow(5, 4))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.GREEN, _colrow(4, 5))
	_add_test_piece(board, GameManager.PieceType.QUEEN, GameManager.PieceColor.GREEN, _colrow(3, 6))
	_add_test_piece(board, GameManager.PieceType.QUEEN, GameManager.PieceColor.GREEN, _colrow(5, 6))

	var candidates: Array = Detector.detect_trap_lines(board, [trap_cell])
	var error_message := ""
	for candidate in candidates:
		if trap_cell in candidate.get("candidate_line_cells", []):
			error_message = "trap cell was counted inside the candidate line"
			break
		if candidate.get("completion_target_cell") == _colrow(5, 4):
			error_message = "trap-split diagonal accepted blocker at 5,4"
			break
	_free_test_board(board)
	return error_message

func _test_trap_detector_rejects_backward_blue_pawn_attack() -> String:
	var Detector = load("res://scripts/traps/TrapLineDetector.gd")
	var board: Dictionary = {}
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.BLUE, _colrow(5, 2))
	_add_test_piece(board, GameManager.PieceType.BISHOP, GameManager.PieceColor.BLUE, _colrow(4, 3))
	_add_test_piece(board, GameManager.PieceType.KNIGHT, GameManager.PieceColor.BLUE, _colrow(3, 4))
	_add_test_piece(board, GameManager.PieceType.QUEEN, GameManager.PieceColor.BLUE, _colrow(2, 5))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.BLUE, _colrow(2, 7))

	var trap_cell := _colrow(4, 2)
	var backward_target := _colrow(1, 6)
	var candidates: Array = Detector.detect_trap_lines(board, [trap_cell])
	var error_message := ""
	for candidate in candidates:
		if candidate.get("completion_target_cell") == backward_target:
			error_message = "blue pawn at 2,7 was allowed to attack backward to 1,6"
			break
	_free_test_board(board)
	return error_message

func _test_trap_detector_rejects_mixed_king_diagonal_bait() -> String:
	var Detector = load("res://scripts/traps/TrapLineDetector.gd")
	var board: Dictionary = {}
	var trap_cell := _colrow(4, 8)
	var suspected_target := _colrow(5, 8)
	_add_test_piece(board, GameManager.PieceType.KING, GameManager.PieceColor.GREEN, _colrow(4, 7))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.BLUE, _colrow(5, 6))
	_add_test_piece(board, GameManager.PieceType.BISHOP, GameManager.PieceColor.BLUE, _colrow(6, 5))
	_add_test_piece(board, GameManager.PieceType.KNIGHT, GameManager.PieceColor.GREEN, _colrow(7, 4))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.BLUE, _colrow(8, 3))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.GREEN, suspected_target)

	var candidates: Array = Detector.detect_trap_lines(board, [trap_cell])
	var error_message := ""
	for candidate in candidates:
		if candidate.get("target_piece_cell") == suspected_target:
			error_message = "mixed king diagonal bait selected off-line target at 5,8"
			break
		if _same_cells(candidate.get("candidate_line_cells", []), [
			_colrow(4, 7),
			_colrow(5, 6),
			_colrow(6, 5),
			_colrow(7, 4),
			_colrow(8, 3),
		]):
			error_message = "mixed king diagonal was accepted as a candidate line"
			break
	_free_test_board(board)
	return error_message

func _test_trap_detector_rejects_full_board_king_diagonal_bait() -> String:
	var Detector = load("res://scripts/traps/TrapLineDetector.gd")
	var GameBoardScript = load("res://scripts/board/GameBoard.gd")
	var board: Dictionary = {}
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.GREEN, _colrow(1, 1))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, _colrow(2, 1))
	_add_test_piece(board, GameManager.PieceType.KNIGHT, GameManager.PieceColor.ORANGE, _colrow(3, 1))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.GREEN, _colrow(5, 1))
	_add_test_piece(board, GameManager.PieceType.KNIGHT, GameManager.PieceColor.BLUE, _colrow(6, 1))
	_add_test_piece(board, GameManager.PieceType.BISHOP, GameManager.PieceColor.GREEN, _colrow(7, 1))
	_add_test_piece(board, GameManager.PieceType.BISHOP, GameManager.PieceColor.ORANGE, _colrow(8, 1))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.GREEN, _colrow(1, 2))
	_add_test_piece(board, GameManager.PieceType.KNIGHT, GameManager.PieceColor.RED, _colrow(2, 2))
	_add_test_piece(board, GameManager.PieceType.KNIGHT, GameManager.PieceColor.GREEN, _colrow(4, 2))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.BLUE, _colrow(6, 2))
	_add_test_piece(board, GameManager.PieceType.KNIGHT, GameManager.PieceColor.RED, _colrow(7, 2))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.ORANGE, _colrow(8, 2))
	_add_test_piece(board, GameManager.PieceType.BISHOP, GameManager.PieceColor.ORANGE, _colrow(1, 3))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.GREEN, _colrow(2, 3))
	_add_test_piece(board, GameManager.PieceType.BISHOP, GameManager.PieceColor.RED, _colrow(3, 3))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.RED, _colrow(4, 3))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.RED, _colrow(5, 3))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.BLUE, _colrow(6, 3))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.BLUE, _colrow(8, 3))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.GREEN, _colrow(1, 4))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.ORANGE, _colrow(2, 4))
	_add_test_piece(board, GameManager.PieceType.KNIGHT, GameManager.PieceColor.ORANGE, _colrow(5, 4))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.ORANGE, _colrow(6, 4))
	_add_test_piece(board, GameManager.PieceType.KNIGHT, GameManager.PieceColor.GREEN, _colrow(7, 4))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.GREEN, _colrow(1, 5))
	_add_test_piece(board, GameManager.PieceType.KNIGHT, GameManager.PieceColor.BLUE, _colrow(2, 5))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.BLUE, _colrow(3, 5))
	_add_test_piece(board, GameManager.PieceType.BISHOP, GameManager.PieceColor.GREEN, _colrow(4, 5))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.RED, _colrow(5, 5))
	_add_test_piece(board, GameManager.PieceType.BISHOP, GameManager.PieceColor.BLUE, _colrow(6, 5))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.RED, _colrow(7, 5))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.ORANGE, _colrow(8, 5))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, _colrow(4, 6))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.BLUE, _colrow(5, 6))
	_add_test_piece(board, GameManager.PieceType.QUEEN, GameManager.PieceColor.BLUE, _colrow(6, 6))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.BLUE, _colrow(7, 6))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.GREEN, _colrow(8, 6))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.ORANGE, _colrow(1, 7))
	_add_test_piece(board, GameManager.PieceType.QUEEN, GameManager.PieceColor.GREEN, _colrow(2, 7))
	_add_test_piece(board, GameManager.PieceType.KING, GameManager.PieceColor.GREEN, _colrow(4, 7))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.BLUE, _colrow(5, 7))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.ORANGE, _colrow(6, 7))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.ORANGE, _colrow(7, 7))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.ORANGE, _colrow(8, 7))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.RED, _colrow(1, 8))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.BLUE, _colrow(2, 8))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.GREEN, _colrow(3, 8))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.GREEN, _colrow(5, 8))
	_add_test_piece(board, GameManager.PieceType.BISHOP, GameManager.PieceColor.BLUE, _colrow(6, 8))
	_add_test_piece(board, GameManager.PieceType.QUEEN, GameManager.PieceColor.RED, _colrow(7, 8))
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.BLUE, _colrow(8, 8))

	var traps: Array[Vector2i] = [
		_colrow(4, 1),
		_colrow(3, 2),
		_colrow(5, 2),
		_colrow(7, 3),
		_colrow(3, 4),
		_colrow(4, 4),
		_colrow(1, 6),
		_colrow(2, 6),
		_colrow(3, 6),
		_colrow(4, 8),
	]
	var candidates: Array = Detector.detect_trap_lines(board, traps)
	var suspected_trap := _colrow(4, 8)
	var suspected_target := _colrow(5, 8)
	var error_message := ""
	for candidate in candidates:
		if candidate.get("trap_cell") != suspected_trap:
			continue
		if candidate.get("target_piece_cell") == suspected_target:
			error_message = "trap 4,8 targeted suspected off-line piece at 5,8"
			break
	var wrapper_candidates: Array = GameBoardScript._find_big_swamp_pulse_candidates(board, [suspected_trap], false, traps)
	for candidate in wrapper_candidates:
		if candidate.get("target_piece_cell") == suspected_target:
			error_message = "GameBoard wrapper ignored blocked traps and targeted 5,8"
			break
	_free_test_board(board)
	return error_message

func _test_big_swamp_pulse_uses_trap_detector_target() -> String:
	var GameBoardScript = load("res://scripts/board/GameBoard.gd")
	var board: Dictionary = {}
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(1, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(2, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(4, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(5, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(3, 3))

	var candidates: Array = GameBoardScript._find_big_swamp_pulse_candidates(board, [Vector2i(2, 1)], false)
	var error_message := ""
	if candidates.is_empty():
		error_message = "expected GameBoard wrapper to return detector candidates"
	else:
		var candidate: Dictionary = candidates[0]
		if candidate.get("target_piece_cell") != Vector2i(2, 0):
			error_message = "expected line edge as capture animation target"
		elif candidate.get("completion_target_cell") != Vector2i(3, 0):
			error_message = "expected detector completion target"
	_free_test_board(board)
	return error_message

func _test_big_swamp_pulse_rejects_changed_target_identity() -> String:
	var Detector = load("res://scripts/traps/TrapLineDetector.gd")
	var board: Dictionary = {}
	var target_cell := Vector2i(2, 0)
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(1, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, target_cell)
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(4, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(5, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(3, 3))

	var candidate: Dictionary = Detector.find_first_trap_candidate(board, [Vector2i(2, 1)])
	if candidate.is_empty():
		_free_test_board(board)
		return "expected starting pulse candidate"

	var old_piece = board[target_cell]
	if is_instance_valid(old_piece):
		old_piece.free()
	board.erase(target_cell)
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.RED, target_cell)

	var error_message := ""
	if Detector.is_candidate_still_present(board, [Vector2i(2, 1)], candidate):
		error_message = "candidate survived after target piece identity changed"
	_free_test_board(board)
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

func _test_big_swamp_pulse_rejects_non_completing_vertical_gap_with_blocker() -> String:
	var GameBoardScript = load("res://scripts/board/GameBoard.gd")
	var board: Dictionary = {}
	# User case in 1-based column,row notation:
	# trap 4,7; vertical run 4,2-4,6 has an empty 4,5 and a queen at 4,6.
	# A blue pawn at 3,4 only attacks 4,5 diagonally; because 4,5 is empty, it cannot complete this line.
	var trap_cell := _colrow(4, 7)
	var blocker_cell := _colrow(4, 6)
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.BLUE, _colrow(4, 2))
	_add_test_piece(board, GameManager.PieceType.BISHOP, GameManager.PieceColor.BLUE, _colrow(4, 3))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.BLUE, _colrow(4, 4))
	_add_test_piece(board, GameManager.PieceType.QUEEN, GameManager.PieceColor.BLUE, blocker_cell)
	_add_test_piece(board, GameManager.PieceType.PAWN, GameManager.PieceColor.BLUE, _colrow(3, 4))
	_add_test_piece(board, GameManager.PieceType.KNIGHT, GameManager.PieceColor.BLUE, _colrow(1, 8))

	var candidates: Array = GameBoardScript._find_big_swamp_pulse_candidates(board, [trap_cell], false)
	var error_message := ""
	for candidate in candidates:
		if candidate.get("trap_cell") == trap_cell and candidate.get("target_piece_cell") == blocker_cell:
			error_message = "trap counted a pawn diagonal into an empty gap as a line completion"
			break
	_free_test_board(board)
	return error_message

func _test_big_swamp_pulse_rejects_king_led_candidate_line() -> String:
	var GameBoardScript = load("res://scripts/board/GameBoard.gd")
	var board: Dictionary = {}
	_add_test_piece(board, GameManager.PieceType.KING, GameManager.PieceColor.RED, Vector2i(0, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(1, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(2, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(4, 0))
	_add_test_piece(board, GameManager.PieceType.ROOK, GameManager.PieceColor.RED, Vector2i(3, 3))

	var candidates: Array = GameBoardScript._find_big_swamp_pulse_candidates(board, [Vector2i(1, 1)], false)
	_free_test_board(board)
	if not candidates.is_empty():
		return "king-led candidate line was accepted"
	return ""

func _add_test_piece(board: Dictionary, piece_type: int, piece_color: int, cell: Vector2i):
	var PieceScript = load("res://scripts/piece/Piece.gd")
	var piece = PieceScript.new()
	piece.piece_type = piece_type
	piece.piece_color = piece_color
	piece.grid_position = cell
	board[cell] = piece

func _pos1(row: int, col: int) -> Vector2i:
	return Vector2i(row - 1, col - 1)

func _colrow(col: int, row: int) -> Vector2i:
	return Vector2i(col - 1, row - 1)

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
