extends RefCounted
class_name TrapLineDetector

const DIRECTIONS: Array[Vector2i] = [
	Vector2i(0, 1),
	Vector2i(0, -1),
	Vector2i(1, 0),
	Vector2i(-1, 0),
	Vector2i(1, 1),
	Vector2i(1, -1),
	Vector2i(-1, 1),
	Vector2i(-1, -1),
]

const MODE_COLOR := "color"
const MODE_TYPE := "type"
const LINE_DIRECTIONS: Array[Vector2i] = [
	Vector2i(1, 0),
	Vector2i(0, 1),
	Vector2i(1, 1),
	Vector2i(1, -1),
]

static func find_first_trap_candidate(board: Dictionary, traps: Array, max_target_distance_cells: int = 1, blocked_trap_cells: Array = []) -> Dictionary:
	var candidates := detect_trap_lines(board, traps, max_target_distance_cells, blocked_trap_cells)
	if candidates.is_empty():
		return {}
	return candidates[0]

static func detect_trap_lines(board: Dictionary, traps: Array, max_target_distance_cells: int = 1, blocked_trap_cells: Array = []) -> Array[Dictionary]:
	var found: Array[Dictionary] = []
	var attack_map := _build_attack_map(board)
	var blocked_cells: Array = blocked_trap_cells if not blocked_trap_cells.is_empty() else traps
	for candidate in _detect_line_completion_traps(board, traps, attack_map, max_target_distance_cells, blocked_cells):
		if not _has_same_candidate(found, candidate):
			found.append(candidate)
	return found

static func is_candidate_still_present(board: Dictionary, traps: Array, candidate: Dictionary) -> bool:
	if candidate.is_empty():
		return false
	var expected_trap: Vector2i = candidate.get("trap_cell", Vector2i(-1, -1))
	var expected_adjacent: Vector2i = candidate.get("adjacent_piece_cell", Vector2i(-1, -1))
	var expected_completion: Vector2i = candidate.get("completion_target_cell", Vector2i(-1, -1))
	var expected_attacker: Vector2i = candidate.get("attacker_cell", Vector2i(-1, -1))
	var expected_window: Array = candidate.get("window_cells", [])
	var expected_target_type: int = int(candidate.get("target_piece_type", -1))
	var expected_target_color: int = int(candidate.get("target_piece_color", -1))
	for current in detect_trap_lines(board, traps):
		if current.get("trap_cell") != expected_trap:
			continue
		if current.get("adjacent_piece_cell") != expected_adjacent:
			continue
		if expected_target_type >= 0 and int(current.get("target_piece_type", -1)) != expected_target_type:
			continue
		if expected_target_color >= 0 and int(current.get("target_piece_color", -1)) != expected_target_color:
			continue
		if current.get("completion_target_cell") != expected_completion:
			continue
		if current.get("attacker_cell") != expected_attacker:
			continue
		if _same_cells(current.get("window_cells", []), expected_window):
			return true
	return false

static func is_candidate_line_completed(board: Dictionary, candidate_line_cells: Array) -> bool:
	var pieces: Array = []
	for cell in candidate_line_cells:
		if not board.has(cell):
			return false
		pieces.append(board[cell])
	if pieces.size() != ChainDetector.MIN_LINE_LENGTH:
		return false
	return not ChainDetector._build_line_result(pieces).is_empty()

static func _detect_line_completion_traps(board: Dictionary, traps: Array, attack_map: Dictionary, max_target_distance_cells: int, blocked_trap_cells: Array) -> Array[Dictionary]:
	var candidates: Array[Dictionary] = []
	if board.size() < 4 or traps.is_empty():
		return candidates
	for direction in LINE_DIRECTIONS:
		for window in _get_five_cell_windows(direction):
			if _contains_any_cell(window, blocked_trap_cells):
				continue
			for completion_target in window:
				var occupied_pieces: Array = []
				var occupied_cells: Array[Vector2i] = []
				for cell in window:
					if cell == completion_target:
						continue
					if not board.has(cell):
						occupied_pieces.clear()
						break
					occupied_pieces.append(board[cell])
					occupied_cells.append(cell)
				if occupied_pieces.size() != 4:
					continue
				for mode_entry in _matching_modes_for_pieces(occupied_pieces):
					var mode := str(mode_entry.get("mode"))
					var value = mode_entry.get("value")
					var attacker := _first_compatible_attacker(board, attack_map, occupied_cells, completion_target, mode, value)
					if attacker == Vector2i(-1, -1):
						continue
					if not _simulated_completion_creates_line(board, occupied_cells, completion_target, attacker, mode, value):
						continue
					var trap_target := _select_trap_adjacent_to_candidate_piece(traps, occupied_cells, max_target_distance_cells)
					if trap_target.is_empty():
						continue
					candidates.append(_build_candidate(
						trap_target.get("trap_cell"),
						trap_target.get("target_piece_cell"),
						direction,
						mode,
						value,
						_window_entries(board, window),
						occupied_cells,
						completion_target,
						attacker,
						"four-of-five board line with one empty/wrong cell that is attackable by a matching piece near a trap"
					))
	return candidates

static func _get_five_cell_windows(direction: Vector2i) -> Array[Array]:
	var windows: Array[Array] = []
	for y in range(GameManager.BOARD_SIZE):
		for x in range(GameManager.BOARD_SIZE):
			var start := Vector2i(x, y)
			var end := start + direction * 4
			if not _is_valid_pos(end):
				continue
			var cells: Array[Vector2i] = []
			for i in range(5):
				cells.append(start + direction * i)
			windows.append(cells)
	return windows

static func _window_entries(board: Dictionary, cells: Array) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for cell in cells:
		entries.append({
			"cell": cell,
			"piece": board.get(cell)
		})
	return entries

static func _matching_modes_for_pieces(pieces: Array) -> Array[Dictionary]:
	var modes: Array[Dictionary] = []
	if pieces.is_empty():
		return modes
	for piece in pieces:
		if int(piece.piece_type) == GameManager.PieceType.KING:
			return modes
	var color := int(pieces[0].piece_color)
	var same_color := true
	for piece in pieces:
		if int(piece.piece_color) != color:
			same_color = false
			break
	if same_color:
		modes.append({"mode": MODE_COLOR, "value": color})

	var piece_type := int(pieces[0].piece_type)
	var same_type := true
	for piece in pieces:
		if int(piece.piece_type) != piece_type:
			same_type = false
			break
	if same_type:
		modes.append({"mode": MODE_TYPE, "value": piece_type})
	return modes

static func _build_attack_map(board: Dictionary) -> Dictionary:
	var attack_map: Dictionary = {}
	for source in board.keys():
		var source_cell: Vector2i = source
		for y in range(GameManager.BOARD_SIZE):
			for x in range(GameManager.BOARD_SIZE):
				var target := Vector2i(x, y)
				if can_move_to(board, source_cell, target):
					if not attack_map.has(target):
						attack_map[target] = []
					attack_map[target].append(source_cell)
	return attack_map

static func _first_compatible_attacker(board: Dictionary, attack_map: Dictionary, occupied_line_cells: Array[Vector2i], target: Vector2i, mode: String, value) -> Vector2i:
	for source in attack_map.get(target, []):
		var source_cell: Vector2i = source
		if source_cell in occupied_line_cells:
			continue
		var piece = board[source_cell]
		if not _matches_mode(piece, mode, value):
			continue
		if not _can_piece_enter_target(board, source_cell, target):
			continue
		return source_cell
	return Vector2i(-1, -1)

static func _can_piece_enter_target(board: Dictionary, source: Vector2i, target: Vector2i) -> bool:
	if not board.has(source):
		return false
	if not board.has(target):
		return true
	var source_piece = board[source]
	var target_piece = board[target]
	if target_piece == null or int(target_piece.piece_type) == GameManager.PieceType.KING:
		return false
	return int(source_piece.piece_color) != int(target_piece.piece_color)

static func _simulated_completion_creates_line(
	board: Dictionary,
	occupied_line_cells: Array[Vector2i],
	completion_target: Vector2i,
	attacker: Vector2i,
	mode: String,
	value
) -> bool:
	if not board.has(attacker):
		return false
	var before_pieces: Array = []
	for cell in occupied_line_cells:
		if not board.has(cell):
			return false
		before_pieces.append(board[cell])
	if board.has(completion_target):
		before_pieces.append(board[completion_target])
		if _pieces_match_mode(before_pieces, mode, value):
			return false

	var after_pieces: Array = []
	for cell in occupied_line_cells:
		after_pieces.append(board[cell])
	after_pieces.append(board[attacker])
	return after_pieces.size() >= 5 and _pieces_match_mode(after_pieces, mode, value)

static func _select_trap_adjacent_to_candidate_piece(traps: Array, matching_cells: Array[Vector2i], max_target_distance_cells: int) -> Dictionary:
	var candidate_piece_cells := matching_cells.duplicate()
	var selected: Dictionary = {}
	var best_distance := 999999
	var max_distance := maxi(max_target_distance_cells, 0)
	for trap in traps:
		var trap_cell: Vector2i = trap
		if not _is_valid_pos(trap_cell):
			continue
		for candidate_piece_cell in candidate_piece_cells:
			if maxi(absi(candidate_piece_cell.x - trap_cell.x), absi(candidate_piece_cell.y - trap_cell.y)) > max_distance:
				continue
			var distance := int(candidate_piece_cell.distance_squared_to(trap_cell))
			if distance < best_distance:
				best_distance = distance
				selected = {
					"trap_cell": trap_cell,
					"target_piece_cell": candidate_piece_cell
				}
	return selected

static func _contains_any_cell(cells: Array, blocked_cells: Array) -> bool:
	for cell in cells:
		if cell in blocked_cells:
			return true
	return false

static func _has_same_candidate(candidates: Array[Dictionary], candidate: Dictionary) -> bool:
	for current in candidates:
		if current.get("trap_cell") != candidate.get("trap_cell"):
			continue
		if current.get("target_piece_cell") != candidate.get("target_piece_cell"):
			continue
		if current.get("completion_target_cell") != candidate.get("completion_target_cell"):
			continue
		if _same_cells(current.get("window_cells", []), candidate.get("window_cells", [])):
			return true
	return false

static func _get_ray(board: Dictionary, trap: Vector2i, direction: Vector2i, max_len: int = 7) -> Array[Dictionary]:
	var cells: Array[Dictionary] = []
	var current := trap + direction
	for _i in range(max_len):
		if not _is_valid_pos(current):
			break
		cells.append({
			"cell": current,
			"piece": board.get(current)
		})
		current += direction
	return cells

static func _evaluate_window(
	board: Dictionary,
	trap: Vector2i,
	direction: Vector2i,
	window: Array,
	mode: String,
	value
) -> Dictionary:
	var matching: Array[Vector2i] = []
	var non_matching: Array[Vector2i] = []
	for entry in window:
		var cell: Vector2i = entry.get("cell")
		var piece = entry.get("piece")
		if _matches_mode(piece, mode, value):
			matching.append(cell)
		else:
			non_matching.append(cell)

	if matching.size() < 4:
		return {}

	var adjacent_pos: Vector2i = window[0].get("cell")
	var adjacent_piece = window[0].get("piece")
	if not _matches_mode(adjacent_piece, mode, value):
		return {}

	if window.size() == 4 and matching.size() == 4:
		var attacker := _first_attacker(board, matching, trap)
		if attacker == Vector2i(-1, -1):
			return {}
		return _build_candidate(
			trap,
			adjacent_pos,
			direction,
			mode,
			value,
			window,
			matching,
			trap,
			attacker,
			"four adjacent aligned matching pieces; trap cell is attackable"
		)

	if window.size() == 5 and matching.size() == 4 and non_matching.size() == 1:
		var target: Vector2i = non_matching[0]
		var attacker := _first_attacker(board, matching, target)
		if attacker == Vector2i(-1, -1):
			return {}
		return _build_candidate(
			trap,
			adjacent_pos,
			direction,
			mode,
			value,
			window,
			matching,
			target,
			attacker,
			"four-of-five line with one empty/wrong cell that is attackable by a matching piece"
		)

	return {}

static func _build_candidate(
	trap: Vector2i,
	adjacent_piece: Vector2i,
	direction: Vector2i,
	mode: String,
	value,
	window: Array,
	matching: Array[Vector2i],
	completion_target: Vector2i,
	attacker: Vector2i,
	reason: String
) -> Dictionary:
	var window_cells: Array[Vector2i] = []
	var target_piece_type := -1
	var target_piece_color := -1
	for entry in window:
		var cell: Vector2i = entry.get("cell")
		window_cells.append(cell)
		if cell == adjacent_piece:
			var target_piece = entry.get("piece")
			if target_piece != null:
				target_piece_type = int(target_piece.piece_type)
				target_piece_color = int(target_piece.piece_color)
	return {
		"trap_cell": trap,
		"adjacent_piece_cell": adjacent_piece,
		"target_piece_cell": adjacent_piece,
		"target_piece_type": target_piece_type,
		"target_piece_color": target_piece_color,
		"direction": direction,
		"mode": mode,
		"matched_value": value,
		"window_cells": window_cells,
		"candidate_line_cells": window_cells.duplicate(),
		"matching_piece_cells": matching.duplicate(),
		"completion_target_cell": completion_target,
		"missing_line_cell": completion_target,
		"attacker_cell": attacker,
		"reason": reason,
		"score": _score_candidate(trap, adjacent_piece, completion_target, attacker, window_cells)
	}

static func _candidate_modes(piece) -> Array[Dictionary]:
	return [
		{"mode": MODE_COLOR, "value": int(piece.piece_color)},
		{"mode": MODE_TYPE, "value": int(piece.piece_type)},
	]

static func _matches_mode(piece, mode: String, value) -> bool:
	if piece == null:
		return false
	if mode == MODE_COLOR:
		return int(piece.piece_color) == int(value)
	if mode == MODE_TYPE:
		return int(piece.piece_type) == int(value)
	return false

static func _pieces_match_mode(pieces: Array, mode: String, value) -> bool:
	if pieces.size() < 5:
		return false
	for piece in pieces:
		if piece == null or int(piece.piece_type) == GameManager.PieceType.KING:
			return false
		if not _matches_mode(piece, mode, value):
			return false
	return true

static func _first_attacker(board: Dictionary, matching_positions: Array[Vector2i], target: Vector2i) -> Vector2i:
	for source in matching_positions:
		if can_move_to(board, source, target):
			return source
	return Vector2i(-1, -1)

static func can_move_to(board: Dictionary, source: Vector2i, target: Vector2i) -> bool:
	if not _is_valid_pos(source) or not _is_valid_pos(target):
		return false
	if not board.has(source):
		return false
	var piece = board[source]
	if piece == null or int(piece.piece_type) == GameManager.PieceType.KING:
		return false

	var delta := target - source
	var abs_delta := Vector2i(absi(delta.x), absi(delta.y))
	if delta == Vector2i.ZERO:
		return false

	match int(piece.piece_type):
		GameManager.PieceType.KNIGHT:
			return (abs_delta.x == 1 and abs_delta.y == 2) or (abs_delta.x == 2 and abs_delta.y == 1)
		GameManager.PieceType.PAWN:
			if board.has(target):
				return delta in _pawn_attack_directions(int(piece.piece_color))
			return delta == _pawn_forward_direction(int(piece.piece_color))
		GameManager.PieceType.ROOK:
			return (delta.x == 0 or delta.y == 0) and _is_clear_path(board, source, target)
		GameManager.PieceType.BISHOP:
			return abs_delta.x == abs_delta.y and _is_clear_path(board, source, target)
		GameManager.PieceType.QUEEN:
			return (delta.x == 0 or delta.y == 0 or abs_delta.x == abs_delta.y) and _is_clear_path(board, source, target)
	return false

static func _pawn_attack_directions(color: int) -> Array[Vector2i]:
	match color:
		GameManager.PieceColor.RED:
			return [Vector2i(1, -1), Vector2i(1, 1)]
		GameManager.PieceColor.BLUE:
			return [Vector2i(-1, 1), Vector2i(1, 1)]
		GameManager.PieceColor.GREEN:
			return [Vector2i(-1, -1), Vector2i(-1, 1)]
		GameManager.PieceColor.ORANGE:
			return [Vector2i(-1, -1), Vector2i(1, -1)]
	return []

static func _pawn_forward_direction(color: int) -> Vector2i:
	match color:
		GameManager.PieceColor.RED:
			return Vector2i(1, 0)
		GameManager.PieceColor.BLUE:
			return Vector2i(0, 1)
		GameManager.PieceColor.GREEN:
			return Vector2i(-1, 0)
		GameManager.PieceColor.ORANGE:
			return Vector2i(0, -1)
	return Vector2i.ZERO

static func _is_clear_path(board: Dictionary, source: Vector2i, target: Vector2i) -> bool:
	var direction := _direction_between(source, target)
	if direction == Vector2i.ZERO:
		return false
	var current := source + direction
	while current != target:
		if board.has(current):
			return false
		current += direction
	return true

static func _direction_between(source: Vector2i, target: Vector2i) -> Vector2i:
	var delta := target - source
	if delta == Vector2i.ZERO:
		return Vector2i.ZERO
	if delta.x == 0 or delta.y == 0 or absi(delta.x) == absi(delta.y):
		return Vector2i(signi(delta.x), signi(delta.y))
	return Vector2i.ZERO

static func _score_candidate(trap: Vector2i, adjacent_piece: Vector2i, completion_target: Vector2i, attacker: Vector2i, window_cells: Array[Vector2i]) -> int:
	var score := 100
	if completion_target == trap:
		score += 30
	if window_cells.size() == 5:
		score += 10
	score -= int(adjacent_piece.distance_squared_to(trap))
	score -= int(attacker.distance_squared_to(completion_target))
	return score

static func _is_valid_pos(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < GameManager.BOARD_SIZE and cell.y >= 0 and cell.y < GameManager.BOARD_SIZE

static func _same_cells(a: Array, b: Array) -> bool:
	if a.size() != b.size():
		return false
	for i in range(a.size()):
		if a[i] != b[i]:
			return false
	return true
