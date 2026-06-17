extends SceneTree

const GameManagerScript = preload("res://autoload/GameManager.gd")

class MockPiece:
	var piece_type
	var piece_color
	var grid_position: Vector2i

	func _init(type, color, pos: Vector2i):
		piece_type = type
		piece_color = color
		grid_position = pos

var game_manager = GameManagerScript.new()

func _initialize():
	var failures: Array[String] = []

	_run_test("scores color line by piece values and length", _test_color_line_score, failures)
	_run_test("scores typed line with typed multiplier", _test_typed_line_score, failures)
	_run_test("scores king-led typed line with king multiplier", _test_king_led_line_score, failures)
	_run_test("formats sacrifice event", _test_sacrifice_event, failures)
	_run_test("reports full sacrifice cost while score clamps", _test_sacrifice_event_clamps_score_but_reports_full_cost, failures)
	_run_test("reports zero-score sacrifice cost", _test_zero_score_sacrifice_event_reports_full_cost, failures)
	_run_test("formats trap disappearance event", _test_trap_disappearance_event, failures)
	_run_test("reports zero-score trap disappearance cost", _test_zero_score_trap_disappearance_event_reports_full_cost, failures)
	_run_test("formats king attack penalty event", _test_king_attack_penalty_event, failures)
	_run_test("scores level completion", _test_level_complete_event, failures)
	_run_test("defers best score until session end", _test_best_score_updates_only_on_session_end, failures)

	if failures.is_empty():
		print("All scoring event tests passed")
		game_manager.free()
		quit(0)
		return

	for failure in failures:
		push_error(failure)
	game_manager.free()
	quit(1)

func _run_test(name: String, test_callable: Callable, failures: Array[String]):
	var error_message: String = test_callable.call()
	if error_message != "":
		failures.append(name + ": " + error_message)

func _test_color_line_score() -> String:
	var line := _line([
		_piece(GameManager.PieceType.PAWN, GameManager.PieceColor.RED, 0, 0),
		_piece(GameManager.PieceType.KNIGHT, GameManager.PieceColor.RED, 1, 0),
		_piece(GameManager.PieceType.BISHOP, GameManager.PieceColor.RED, 2, 0),
		_piece(GameManager.PieceType.ROOK, GameManager.PieceColor.RED, 3, 0),
		_piece(GameManager.PieceType.QUEEN, GameManager.PieceColor.RED, 4, 0),
		_piece(GameManager.PieceType.PAWN, GameManager.PieceColor.RED, 5, 0)
	])
	var event: Dictionary = _game_manager().build_line_scoring_event(line)

	if event["message"] != "6 in Row":
		return "wrong color line message"
	if event["value"] != 30:
		return "expected 30, got %d" % event["value"]
	return ""

func _test_typed_line_score() -> String:
	var line := _line([
		_piece(GameManager.PieceType.KNIGHT, GameManager.PieceColor.RED, 0, 1),
		_piece(GameManager.PieceType.KNIGHT, GameManager.PieceColor.BLUE, 1, 1),
		_piece(GameManager.PieceType.KNIGHT, GameManager.PieceColor.GREEN, 2, 1),
		_piece(GameManager.PieceType.KNIGHT, GameManager.PieceColor.ORANGE, 3, 1),
		_piece(GameManager.PieceType.KNIGHT, GameManager.PieceColor.RED, 4, 1)
	])
	var event: Dictionary = _game_manager().build_line_scoring_event(line)

	if event["message"] != "Knight Line":
		return "wrong typed line message"
	if event["value"] != 35:
		return "expected 35, got %d" % event["value"]
	return ""

func _test_king_led_line_score() -> String:
	var line := _line([
		_piece(GameManager.PieceType.ROOK, GameManager.PieceColor.RED, 0, 2),
		_piece(GameManager.PieceType.KING, GameManager.PieceColor.BLUE, 1, 2),
		_piece(GameManager.PieceType.ROOK, GameManager.PieceColor.GREEN, 2, 2),
		_piece(GameManager.PieceType.ROOK, GameManager.PieceColor.ORANGE, 3, 2),
		_piece(GameManager.PieceType.ROOK, GameManager.PieceColor.RED, 4, 2)
	])
	var event: Dictionary = _game_manager().build_line_scoring_event(line)

	if event["message"] != "United Rooks":
		return "wrong king-led line message"
	if event["value"] != 75:
		return "expected 75, got %d" % event["value"]
	return ""

func _test_sacrifice_event() -> String:
	_game_manager().current_score = 12
	var event: Dictionary = _game_manager().build_sacrifice_event(GameManager.PieceType.QUEEN)
	if event["message"] != "Queen Sacrifice -7":
		return "wrong sacrifice message"
	if event["value"] != -7:
		return "expected -7, got %d" % event["value"]
	if _game_manager().format_scoring_event(event) != "Queen Sacrifice -7":
		return "wrong formatted sacrifice event"
	return ""

func _test_sacrifice_event_clamps_score_but_reports_full_cost() -> String:
	_game_manager().current_score = 3
	var event: Dictionary = _game_manager().build_sacrifice_event(GameManager.PieceType.QUEEN)
	if event["message"] != "Queen Sacrifice -7":
		return "wrong sacrifice message"
	if event["value"] != -7:
		return "expected -7, got %d" % event["value"]
	_game_manager().add_scoring_event(event)
	if _game_manager().current_score != 0:
		return "expected score to clamp at zero"
	return ""

func _test_zero_score_sacrifice_event_reports_full_cost() -> String:
	_game_manager().current_score = 0
	var event: Dictionary = _game_manager().build_sacrifice_event(GameManager.PieceType.PAWN)
	if event.is_empty():
		return "expected sacrifice event at zero score"
	if event["message"] != "Pawn Sacrifice -2":
		return "wrong sacrifice message"
	if event["value"] != -2:
		return "expected -2, got %d" % event["value"]
	if bool(event.get("display_only", false)):
		return "expected scoring sacrifice event"
	if _game_manager().format_scoring_event(event) != "Pawn Sacrifice -2":
		return "wrong formatted sacrifice event"
	_game_manager().add_scoring_event(event)
	if _game_manager().current_score != 0:
		return "expected score to clamp at zero"
	return ""

func _test_trap_disappearance_event() -> String:
	_game_manager().current_score = 12
	var event: Dictionary = _game_manager().build_trap_disappearance_event(
		GameManager.PieceType.QUEEN,
		"Big Swamp"
	)
	if event["message"] != "Trapped by Big Swamp -7 :(":
		return "wrong disappearance message"
	if event["value"] != -7:
		return "expected -7, got %d" % event["value"]
	if _game_manager().format_scoring_event(event) != "Trapped by Big Swamp -7 :(":
		return "wrong formatted disappearance event"
	return ""

func _test_zero_score_trap_disappearance_event_reports_full_cost() -> String:
	_game_manager().current_score = 0
	var event: Dictionary = _game_manager().build_trap_disappearance_event(
		GameManager.PieceType.PAWN,
		"Big Swamp"
	)
	if event.is_empty():
		return "expected trap disappearance event at zero score"
	if event["message"] != "Trapped by Big Swamp -2 :(":
		return "wrong disappearance message"
	if event["value"] != -2:
		return "expected -2, got %d" % event["value"]
	if _game_manager().format_scoring_event(event) != "Trapped by Big Swamp -2 :(":
		return "wrong formatted disappearance event"
	_game_manager().add_scoring_event(event)
	if _game_manager().current_score != 0:
		return "expected score to clamp at zero"
	return ""

func _test_king_attack_penalty_event() -> String:
	_game_manager().current_score = 1
	var event: Dictionary = _game_manager().build_king_attack_attempt_event()
	if event["message"] != "The king is untouchable!":
		return "wrong king attack message"
	if event["value"] != -2:
		return "expected -2, got %d" % event["value"]
	if _game_manager().format_scoring_event(event) != "The king is untouchable!   −2":
		return "wrong formatted king attack event"
	_game_manager().add_scoring_event(event)
	if _game_manager().current_score != 0:
		return "expected score to clamp at zero"
	return ""

func _test_level_complete_event() -> String:
	var event: Dictionary = _game_manager().build_level_complete_event(2)
	if event["message"] != "Level 2 complete!":
		return "wrong level complete message"
	if event["value"] != 500:
		return "expected 500, got %d" % event["value"]
	return ""

func _test_best_score_updates_only_on_session_end() -> String:
	_game_manager().current_score = 0
	_game_manager().high_score = 10
	_game_manager().add_score(25)
	if _game_manager().high_score != 10:
		return "expected best score to stay unchanged before session end"
	_game_manager().end_game(GameManager.GAME_RESULT_LOSS)
	if _game_manager().high_score != 25:
		return "expected best score to update after loss"

	_game_manager().reset_game()
	_game_manager().high_score = 30
	_game_manager().add_score(20)
	_game_manager().reset_game()
	if _game_manager().high_score != 30:
		return "expected reset to leave best score unchanged"
	return ""

func _line(pieces: Array) -> Dictionary:
	return ChainDetector.find_chains(_make_board(pieces))[0]

func _piece(type, color, x: int, y: int) -> MockPiece:
	return MockPiece.new(type, color, Vector2i(x, y))

func _make_board(pieces: Array) -> Dictionary:
	var board: Dictionary = {}
	for piece in pieces:
		board[piece.grid_position] = piece
	return board

func _game_manager():
	return game_manager
