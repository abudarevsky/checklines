extends Node

enum PieceType { PAWN, KNIGHT, BISHOP, ROOK, QUEEN, KING }
enum PieceColor { RED, BLUE, GREEN, ORANGE }

const BOARD_SIZE: int = 8
const CELL_SIZE: int = 100
const BOARD_PIXEL_SIZE: int = BOARD_SIZE * CELL_SIZE
const WINDOW_WIDTH: int = BOARD_PIXEL_SIZE
const WINDOW_HEIGHT: int = BOARD_PIXEL_SIZE
const BORDER_WIDTH: int = 3
const SELECTED_BORDER_WIDTH: int = 10
const BORDER_PADDING: int = 8
const BOARD_FRAME_MARGIN: int = SELECTED_BORDER_WIDTH + BORDER_PADDING

const COLOR_MAP: Dictionary = {
	PieceColor.RED: Color(1, 1, 0, 1),
	PieceColor.BLUE: Color(1, 0, 1, 1),
	PieceColor.GREEN: Color(0, 0, 0.8, 1),
	PieceColor.ORANGE: Color(0, 1, 1, 1)
}
const PIECE_TYPE_LIMITS: Dictionary = {
	PieceType.PAWN: 8,
	PieceType.KNIGHT: 2,
	PieceType.BISHOP: 2,
	PieceType.ROOK: 2,
	PieceType.QUEEN: 1,
	PieceType.KING: 1
}
const PIECE_VALUES: Dictionary = {
	PieceType.PAWN: 2,
	PieceType.KNIGHT: 4,
	PieceType.BISHOP: 4,
	PieceType.ROOK: 5,
	PieceType.QUEEN: 7,
	PieceType.KING: 10
}
const LEVEL_COMPLETE_SCORE: int = 500

var board_size: int = BOARD_SIZE
var cell_size: float = CELL_SIZE

var current_score: int = 0
var high_score: int = 0
var color_lines_cleared: int = 0
var type_lines_cleared: int = 0

signal score_updated(new_score: int)
signal game_over(final_score: int)
signal line_metrics_updated(color_lines: int, type_lines: int)

func _ready():
	load_high_score()

func load_high_score():
	var config := ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		high_score = config.get_value("game", "high_score", 0)

func save_high_score():
	var config := ConfigFile.new()
	config.load("user://settings.cfg")
	config.set_value("game", "high_score", high_score)
	config.save("user://settings.cfg")

func add_score(points: int):
	current_score = maxi(current_score + points, 0)

	if current_score > high_score:
		high_score = current_score
		save_high_score()

	score_updated.emit(current_score)

func add_scoring_event(event: Dictionary):
	if event.is_empty():
		return
	add_score(int(event.get("value", 0)))

func build_line_scoring_event(chain: Dictionary) -> Dictionary:
	var pieces: Array = chain.get("pieces", [])
	var piece_value_sum := 0

	for piece in pieces:
		piece_value_sum += get_piece_value(piece.piece_type)

	var length := pieces.size()
	var raw_score: float = float(piece_value_sum) * get_length_multiplier(length) * get_line_type_multiplier(chain)
	return {
		"message": get_line_event_message(chain),
		"value": int(round(raw_score))
	}

func build_sacrifice_event(piece_type: int) -> Dictionary:
	if current_score <= 0:
		return {}

	var sacrifice_cost: int = mini(get_piece_value(piece_type), current_score)
	if sacrifice_cost <= 0:
		return {}

	return {
		"message": get_piece_type_name(piece_type) + " Sacrifice",
		"value": -sacrifice_cost
	}

func build_level_complete_event() -> Dictionary:
	return {
		"message": "Level Complete",
		"value": LEVEL_COMPLETE_SCORE
	}

func format_scoring_event(event: Dictionary) -> String:
	var value := int(event.get("value", 0))
	var sign := "+" if value >= 0 else "−"
	return "%s   %s%d" % [str(event.get("message", "")), sign, abs(value)]

func get_piece_value(piece_type: int) -> int:
	return PIECE_VALUES.get(piece_type, 0)

func get_length_multiplier(length: int) -> float:
	match length:
		5:
			return 1.0
		6:
			return 1.25
		7:
			return 1.5
		8:
			return 1.8
	return 2.2

func get_line_type_multiplier(chain: Dictionary) -> float:
	if chain.get("is_king_led_type_line", false):
		return 2.5
	if chain.get("is_type_line", false):
		return 1.75
	return 1.0

func get_line_event_message(chain: Dictionary) -> String:
	if chain.get("is_king_led_type_line", false):
		return _get_king_led_line_message(int(chain.get("matched_type", -1)))
	if chain.get("is_type_line", false):
		return _get_type_line_message(int(chain.get("matched_type", -1)))

	var length: int = chain.get("pieces", []).size()
	match length:
		5:
			return "Color Line"
		6:
			return "6 in Row"
		7:
			return "7 in Row"
		8:
			return "8 in Row"
	return "Long Line"

func get_piece_type_name(piece_type: int) -> String:
	match piece_type:
		PieceType.PAWN:
			return "Pawn"
		PieceType.KNIGHT:
			return "Knight"
		PieceType.BISHOP:
			return "Bishop"
		PieceType.ROOK:
			return "Rook"
		PieceType.QUEEN:
			return "Queen"
		PieceType.KING:
			return "King"
	return "Piece"

func _get_type_line_message(piece_type: int) -> String:
	match piece_type:
		PieceType.PAWN:
			return "Pawn Formation"
		PieceType.KNIGHT:
			return "Knight Line"
		PieceType.BISHOP:
			return "Bishop Chain"
		PieceType.ROOK:
			return "Rook Formation"
		PieceType.QUEEN:
			return "Queen Formation"
	return "Typed Line"

func _get_king_led_line_message(piece_type: int) -> String:
	match piece_type:
		PieceType.KNIGHT:
			return "United Knights"
		PieceType.BISHOP:
			return "United Bishops"
		PieceType.ROOK:
			return "United Rooks"
	return "United Forces"

func register_cleared_line(is_color_line: bool, is_type_line: bool):
	var changed := false

	if is_color_line:
		color_lines_cleared += 1
		changed = true
	if is_type_line:
		type_lines_cleared += 1
		changed = true

	if changed:
		line_metrics_updated.emit(color_lines_cleared, type_lines_cleared)

func reset_game():
	current_score = 0
	color_lines_cleared = 0
	type_lines_cleared = 0
	score_updated.emit(0)
	line_metrics_updated.emit(color_lines_cleared, type_lines_cleared)

func end_game():
	game_over.emit(current_score)
	if current_score >= high_score:
		save_high_score()

func get_piece_spawn_weights() -> Array[float]:
	return [0.37, 0.23, 0.16, 0.12, 0.10, 0.02]

func get_random_piece_type() -> PieceType:
	var weights := get_piece_spawn_weights()
	var rand := randf()
	var cumulative := 0.0
	
	for i in range(PieceType.size()):
		cumulative += weights[i]
		if rand < cumulative:
			return PieceType.values()[i]
	
	return PieceType.PAWN

func get_random_piece_color() -> PieceColor:
	return PieceColor.values()[randi() % PieceColor.size()]

func get_color_value(color: PieceColor) -> Color:
	var main_loop: MainLoop = Engine.get_main_loop()
	if main_loop is SceneTree:
		var root: Window = main_loop.root
		var theme_manager = root.get_node_or_null("ThemeManager")
		if theme_manager != null and theme_manager.get_active_theme() != null:
			return theme_manager.get_piece_color(int(color))
	return COLOR_MAP.get(color, Color.WHITE)

func get_piece_type_limit(piece_type: PieceType) -> int:
	return PIECE_TYPE_LIMITS.get(piece_type, 0)
