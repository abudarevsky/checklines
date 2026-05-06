extends Node
class_name ChainDetector

const MIN_LINE_LENGTH: int = 5
const DIRECTIONS := [
	Vector2i(1, 0),
	Vector2i(0, 1),
	Vector2i(1, 1),
	Vector2i(1, -1)
]

static func find_chains(board: Dictionary) -> Array:
	var lines: Array = []
	var seen_keys: Dictionary = {}

	if board.size() < MIN_LINE_LENGTH:
		return lines

	for direction in DIRECTIONS:
		for start in _get_line_starts(direction):
			var segment: Array = []
			var current: Vector2i = start

			while _is_in_bounds(current):
				if board.has(current):
					segment.append(board[current])
				else:
					_collect_segment_lines(lines, seen_keys, segment)
					segment = []
				current += direction

			_collect_segment_lines(lines, seen_keys, segment)

	return lines

static func get_chain_positions(chain) -> Array:
	var positions: Array = []
	var pieces: Array = chain.get("pieces", []) if chain is Dictionary else chain
	for piece in pieces:
		positions.append(piece.grid_position)
	return positions

static func _collect_segment_lines(lines: Array, seen_keys: Dictionary, segment: Array):
	if segment.size() < MIN_LINE_LENGTH:
		return

	for run in _find_color_runs(segment):
		_append_line(lines, seen_keys, run)

	for run in _find_type_runs(segment):
		_append_line(lines, seen_keys, run)

static func _append_line(lines: Array, seen_keys: Dictionary, segment: Array):
	var result := _build_line_result(segment)
	if result.is_empty():
		return

	var key := _line_key(result["pieces"])
	if seen_keys.has(key):
		return

	seen_keys[key] = true
	lines.append(result)

static func _find_color_runs(segment: Array) -> Array:
	var runs: Array = []
	var current_run: Array = []
	var current_color := -1

	for piece in segment:
		if current_run.is_empty() or piece.piece_color == current_color:
			current_run.append(piece)
			current_color = piece.piece_color
			continue

		if current_run.size() >= MIN_LINE_LENGTH:
			runs.append(current_run.duplicate())

		current_run = [piece]
		current_color = piece.piece_color

	if current_run.size() >= MIN_LINE_LENGTH:
		runs.append(current_run.duplicate())

	return runs

static func _find_type_runs(segment: Array) -> Array:
	var runs: Array = []
	var current_run: Array = []
	var matched_type: int = -1

	for piece in segment:
		if piece.piece_type == GameManager.PieceType.KING:
			current_run.append(piece)
			continue

		if matched_type == -1 or piece.piece_type == matched_type:
			current_run.append(piece)
			matched_type = piece.piece_type
			continue

		if current_run.size() >= MIN_LINE_LENGTH and matched_type != -1:
			runs.append(current_run.duplicate())

		var trailing_kings := _get_trailing_kings(current_run)
		current_run = trailing_kings
		current_run.append(piece)
		matched_type = piece.piece_type

	if current_run.size() >= MIN_LINE_LENGTH and matched_type != -1:
		runs.append(current_run.duplicate())

	return runs

static func _get_trailing_kings(run: Array) -> Array:
	var trailing: Array = []

	for i in range(run.size() - 1, -1, -1):
		var piece = run[i]
		if piece.piece_type != GameManager.PieceType.KING:
			break
		trailing.push_front(piece)

	return trailing

static func _build_line_result(segment: Array) -> Dictionary:
	if segment.size() < MIN_LINE_LENGTH:
		return {}

	var is_color_line := _is_color_line(segment)
	var type_match: int = _get_type_line_match(segment)
	var is_type_line := type_match != -1
	var has_king := _has_king(segment)

	if not is_color_line and not is_type_line:
		return {}

	return {
		"pieces": segment.duplicate(),
		"is_color_line": is_color_line,
		"is_type_line": is_type_line,
		"is_combo": is_color_line and is_type_line,
		"has_king": has_king,
		"is_king_led_type_line": is_type_line and has_king,
		"matched_type": type_match
	}

static func _is_color_line(segment: Array) -> bool:
	var first_color = segment[0].piece_color
	for piece in segment:
		if piece.piece_color != first_color:
			return false
	return true

static func _get_type_line_match(segment: Array) -> int:
	var matched_type := -1

	for piece in segment:
		if piece.piece_type == GameManager.PieceType.KING:
			continue
		if matched_type == -1:
			matched_type = piece.piece_type
			continue
		if piece.piece_type != matched_type:
			return -1

	return matched_type

static func _has_king(segment: Array) -> bool:
	for piece in segment:
		if piece.piece_type == GameManager.PieceType.KING:
			return true
	return false

static func _line_key(pieces: Array) -> String:
	var positions: Array[String] = []
	for piece in pieces:
		positions.append(str(piece.grid_position.x) + "," + str(piece.grid_position.y))
	return "|".join(positions)

static func _get_line_starts(direction: Vector2i) -> Array:
	var starts: Array = []

	match direction:
		Vector2i(1, 0):
			for y in range(GameManager.BOARD_SIZE):
				starts.append(Vector2i(0, y))
		Vector2i(0, 1):
			for x in range(GameManager.BOARD_SIZE):
				starts.append(Vector2i(x, 0))
		Vector2i(1, 1):
			for x in range(GameManager.BOARD_SIZE):
				starts.append(Vector2i(x, 0))
			for y in range(1, GameManager.BOARD_SIZE):
				starts.append(Vector2i(0, y))
		Vector2i(1, -1):
			for x in range(GameManager.BOARD_SIZE):
				starts.append(Vector2i(x, GameManager.BOARD_SIZE - 1))
			for y in range(GameManager.BOARD_SIZE - 2, -1, -1):
				starts.append(Vector2i(0, y))

	return starts

static func _is_in_bounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < GameManager.BOARD_SIZE and pos.y >= 0 and pos.y < GameManager.BOARD_SIZE
