extends SceneTree

class MockPiece:
	var piece_type
	var piece_color
	var grid_position: Vector2i

	func _init(type, color, pos: Vector2i):
		piece_type = type
		piece_color = color
		grid_position = pos

func _initialize():
	var failures: Array[String] = []

	_run_test("detects color line inside longer occupied row", _test_color_line_inside_longer_segment, failures)
	_run_test("detects vertical type line with mixed colors", _test_vertical_type_line, failures)
	_run_test("detects diagonal king joker type line", _test_diagonal_king_joker_type_line, failures)
	_run_test("detects combo line", _test_combo_line, failures)
	_run_test("does not detect invalid mixed type line with king", _test_invalid_mixed_type_line_with_king, failures)
	_run_test("does not treat mixed-color kings as type line", _test_all_kings_not_type_line, failures)
	_run_test("does not detect gapped color line", _test_gap_breaks_line, failures)

	if failures.is_empty():
		print("All ChainDetector tests passed")
		quit(0)
		return

	for failure in failures:
		push_error(failure)
	quit(1)

func _run_test(name: String, test_callable: Callable, failures: Array[String]):
	var error_message: String = test_callable.call()
	if error_message != "":
		failures.append(name + ": " + error_message)

func _test_color_line_inside_longer_segment() -> String:
	var board: Dictionary = _make_board([
		_piece(GameManager.PieceType.ROOK, GameManager.PieceColor.RED, 0, 0),
		_piece(GameManager.PieceType.BISHOP, GameManager.PieceColor.RED, 1, 0),
		_piece(GameManager.PieceType.KNIGHT, GameManager.PieceColor.RED, 2, 0),
		_piece(GameManager.PieceType.QUEEN, GameManager.PieceColor.RED, 3, 0),
		_piece(GameManager.PieceType.PAWN, GameManager.PieceColor.RED, 4, 0),
		_piece(GameManager.PieceType.BISHOP, GameManager.PieceColor.BLUE, 5, 0)
	])

	var line: Dictionary = _find_line_by_positions(ChainDetector.find_chains(board), _positions_from_coords([[0, 0], [1, 0], [2, 0], [3, 0], [4, 0]]))
	if line.is_empty():
		return "missing expected red color line"
	if not line["is_color_line"]:
		return "expected color line metadata"
	if line["is_type_line"]:
		return "color-only line was incorrectly marked as type line"
	return ""

func _test_vertical_type_line() -> String:
	var board: Dictionary = _make_board([
		_piece(GameManager.PieceType.ROOK, GameManager.PieceColor.RED, 2, 0),
		_piece(GameManager.PieceType.ROOK, GameManager.PieceColor.BLUE, 2, 1),
		_piece(GameManager.PieceType.ROOK, GameManager.PieceColor.GREEN, 2, 2),
		_piece(GameManager.PieceType.ROOK, GameManager.PieceColor.ORANGE, 2, 3),
		_piece(GameManager.PieceType.ROOK, GameManager.PieceColor.RED, 2, 4)
	])

	var line: Dictionary = _find_line_by_positions(ChainDetector.find_chains(board), _positions_from_coords([[2, 0], [2, 1], [2, 2], [2, 3], [2, 4]]))
	if line.is_empty():
		return "missing expected rook type line"
	if not line["is_type_line"]:
		return "expected type line metadata"
	if line["matched_type"] != GameManager.PieceType.ROOK:
		return "wrong matched type"
	if line["is_color_line"]:
		return "mixed-color type line was incorrectly marked as color line"
	return ""

func _test_diagonal_king_joker_type_line() -> String:
	var board: Dictionary = _make_board([
		_piece(GameManager.PieceType.BISHOP, GameManager.PieceColor.RED, 0, 0),
		_piece(GameManager.PieceType.KING, GameManager.PieceColor.BLUE, 1, 1),
		_piece(GameManager.PieceType.BISHOP, GameManager.PieceColor.GREEN, 2, 2),
		_piece(GameManager.PieceType.BISHOP, GameManager.PieceColor.ORANGE, 3, 3),
		_piece(GameManager.PieceType.BISHOP, GameManager.PieceColor.RED, 4, 4)
	])

	var line: Dictionary = _find_line_by_positions(ChainDetector.find_chains(board), _positions_from_coords([[0, 0], [1, 1], [2, 2], [3, 3], [4, 4]]))
	if line.is_empty():
		return "missing expected bishop line with king joker"
	if not line["is_type_line"]:
		return "king joker line was not marked as type line"
	if line["matched_type"] != GameManager.PieceType.BISHOP:
		return "wrong matched type for king joker line"
	if not line["is_king_led_type_line"]:
		return "king joker line was not marked as king-led"
	return ""

func _test_combo_line() -> String:
	var board: Dictionary = _make_board([
		_piece(GameManager.PieceType.KNIGHT, GameManager.PieceColor.GREEN, 0, 3),
		_piece(GameManager.PieceType.KNIGHT, GameManager.PieceColor.GREEN, 1, 3),
		_piece(GameManager.PieceType.KNIGHT, GameManager.PieceColor.GREEN, 2, 3),
		_piece(GameManager.PieceType.KNIGHT, GameManager.PieceColor.GREEN, 3, 3),
		_piece(GameManager.PieceType.KNIGHT, GameManager.PieceColor.GREEN, 4, 3)
	])

	var line: Dictionary = _find_line_by_positions(ChainDetector.find_chains(board), _positions_from_coords([[0, 3], [1, 3], [2, 3], [3, 3], [4, 3]]))
	if line.is_empty():
		return "missing expected combo line"
	if not line["is_combo"]:
		return "expected combo metadata"
	return ""

func _test_invalid_mixed_type_line_with_king() -> String:
	var board: Dictionary = _make_board([
		_piece(GameManager.PieceType.ROOK, GameManager.PieceColor.RED, 0, 5),
		_piece(GameManager.PieceType.KING, GameManager.PieceColor.BLUE, 1, 5),
		_piece(GameManager.PieceType.BISHOP, GameManager.PieceColor.GREEN, 2, 5),
		_piece(GameManager.PieceType.BISHOP, GameManager.PieceColor.ORANGE, 3, 5),
		_piece(GameManager.PieceType.BISHOP, GameManager.PieceColor.RED, 4, 5)
	])

	var line: Dictionary = _find_line_by_positions(ChainDetector.find_chains(board), _positions_from_coords([[0, 5], [1, 5], [2, 5], [3, 5], [4, 5]]))
	if not line.is_empty():
		return "invalid mixed-type line was incorrectly detected"
	return ""

func _test_all_kings_not_type_line() -> String:
	var board: Dictionary = _make_board([
		_piece(GameManager.PieceType.KING, GameManager.PieceColor.RED, 0, 6),
		_piece(GameManager.PieceType.KING, GameManager.PieceColor.BLUE, 1, 6),
		_piece(GameManager.PieceType.KING, GameManager.PieceColor.GREEN, 2, 6),
		_piece(GameManager.PieceType.KING, GameManager.PieceColor.ORANGE, 3, 6),
		_piece(GameManager.PieceType.KING, GameManager.PieceColor.RED, 4, 6)
	])

	var line: Dictionary = _find_line_by_positions(ChainDetector.find_chains(board), _positions_from_coords([[0, 6], [1, 6], [2, 6], [3, 6], [4, 6]]))
	if not line.is_empty():
		return "mixed-color kings were incorrectly detected as a line"
	return ""

func _test_gap_breaks_line() -> String:
	var board: Dictionary = _make_board([
		_piece(GameManager.PieceType.ROOK, GameManager.PieceColor.ORANGE, 0, 8),
		_piece(GameManager.PieceType.BISHOP, GameManager.PieceColor.ORANGE, 1, 8),
		_piece(GameManager.PieceType.KNIGHT, GameManager.PieceColor.ORANGE, 2, 8),
		_piece(GameManager.PieceType.QUEEN, GameManager.PieceColor.ORANGE, 4, 8),
		_piece(GameManager.PieceType.PAWN, GameManager.PieceColor.ORANGE, 5, 8)
	])

	var chains: Array = ChainDetector.find_chains(board)
	if not chains.is_empty():
		return "gapped pieces were incorrectly detected as a line"
	return ""

func _piece(type, color, x: int, y: int) -> MockPiece:
	return MockPiece.new(type, color, Vector2i(x, y))

func _make_board(pieces: Array) -> Dictionary:
	var board: Dictionary = {}
	for piece in pieces:
		board[piece.grid_position] = piece
	return board

func _positions_from_coords(coords: Array) -> Array:
	var positions: Array = []
	for coord in coords:
		positions.append(Vector2i(coord[0], coord[1]))
	return positions

func _find_line_by_positions(lines: Array, expected_positions: Array) -> Dictionary:
	for line in lines:
		var actual_positions: Array = ChainDetector.get_chain_positions(line)
		if _same_positions(actual_positions, expected_positions):
			return line
	return {}

func _same_positions(a: Array, b: Array) -> bool:
	if a.size() != b.size():
		return false

	for i in range(a.size()):
		if a[i] != b[i]:
			return false

	return true
