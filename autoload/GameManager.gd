extends Node

const ConfigStoreScript = preload("res://scripts/persistence/ConfigStore.gd")

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
const BOARD_INSET_X: int = 20

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
const KING_ATTACK_ATTEMPT_PENALTY: int = 2
const GAME_RESULT_LOSS: String = "loss"
const GAME_RESULT_WIN: String = "win"
const SESSION_HISTORY_DEPTH: int = 5
const PROJECT_VERSION: String = "0.9.1"

var board_size: int = BOARD_SIZE
var cell_size: float = CELL_SIZE

var current_score: int = 0
var high_score: int = 0
var color_lines_cleared: int = 0
var type_lines_cleared: int = 0

signal score_updated(new_score: int)
signal game_over(final_score: int, result: String, achieved_best_score: bool)
signal line_metrics_updated(color_lines: int, type_lines: int)

func _ready():
	load_game_state()

func load_game_state():
	var config := ConfigStoreScript.load_config()
	if config.has_section("game"):
		current_score = config.get_value("game", "current_score", 0)
		high_score = config.get_value("game", "high_score", 0)
		color_lines_cleared = config.get_value("game", "color_lines_cleared", 0)
		type_lines_cleared = config.get_value("game", "type_lines_cleared", 0)

func save_game_state():
	ConfigStoreScript.save_values("game", {
		"current_score": current_score,
		"high_score": high_score,
		"color_lines_cleared": color_lines_cleared,
		"type_lines_cleared": type_lines_cleared,
	})

func save_high_score():
	save_game_state()

func add_score(points: int):
	current_score = maxi(current_score + points, 0)
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

func _get_sacrifice_cost(piece_type: int) -> int:
	return maxi(get_piece_value(piece_type), 0)

func build_sacrifice_event(piece_type: int) -> Dictionary:
	var message := _tf("sacrifice", {"piece": get_piece_type_name(piece_type)})
	var sacrifice_cost := _get_sacrifice_cost(piece_type)
	if sacrifice_cost <= 0:
		return {}

	message = "%s -%d" % [message, sacrifice_cost]
	return {
		"message": message,
		"value": -sacrifice_cost,
		"show_value": false
	}

func build_trap_disappearance_event(piece_type: int, trap_name: String) -> Dictionary:
	var sacrifice_cost := _get_sacrifice_cost(piece_type)
	if sacrifice_cost <= 0:
		return {}

	var message := _tf("trap_disappeared", {
		"trap": trap_name,
		"cost": sacrifice_cost
	})

	return {
		"message": message,
		"value": -sacrifice_cost,
		"show_value": false
	}

func build_king_attack_attempt_event() -> Dictionary:
	return {
		"message": _t("king_untouchable"),
		"value": -KING_ATTACK_ATTEMPT_PENALTY
	}

func build_level_complete_event(level_number: int = 0) -> Dictionary:
	var message := _t("level_complete_short")
	if level_number > 0:
		message = _tf("level_complete", {"number": level_number})
	return {
		"message": message,
		"value": LEVEL_COMPLETE_SCORE
	}

func format_scoring_event(event: Dictionary) -> String:
	if not bool(event.get("show_value", true)):
		return str(event.get("message", ""))

	var value := int(event.get("value", 0))
	var value_prefix := "+" if value >= 0 else "−"
	return "%s   %s%d" % [str(event.get("message", "")), value_prefix, abs(value)]

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
			return _t("color_line")
		6:
			return _t("row_6")
		7:
			return _t("row_7")
		8:
			return _t("row_8")
	return _t("long_line")

func get_piece_type_name(piece_type: int) -> String:
	match piece_type:
		PieceType.PAWN:
			return _t("piece_pawn")
		PieceType.KNIGHT:
			return _t("piece_knight")
		PieceType.BISHOP:
			return _t("piece_bishop")
		PieceType.ROOK:
			return _t("piece_rook")
		PieceType.QUEEN:
			return _t("piece_queen")
		PieceType.KING:
			return _t("piece_king")
	return _t("piece_generic")

func _get_type_line_message(piece_type: int) -> String:
	match piece_type:
		PieceType.PAWN:
			return _t("pawn_formation")
		PieceType.KNIGHT:
			return _t("knight_line")
		PieceType.BISHOP:
			return _t("bishop_chain")
		PieceType.ROOK:
			return _t("rook_formation")
		PieceType.QUEEN:
			return _t("queen_formation")
	return _t("typed_line")

func _get_king_led_line_message(piece_type: int) -> String:
	match piece_type:
		PieceType.KNIGHT:
			return _t("united_knights")
		PieceType.BISHOP:
			return _t("united_bishops")
		PieceType.ROOK:
			return _t("united_rooks")
	return _t("united_forces")

func _t(key: String) -> String:
	var localization := _get_localization()
	if localization != null and localization.has_method("t"):
		return localization.t(key)
	return _english_text(key)

func _tf(key: String, values: Dictionary) -> String:
	var localization := _get_localization()
	if localization != null and localization.has_method("tf"):
		return localization.tf(key, values)

	var text := _english_text(key)
	for value_key in values.keys():
		text = text.replace("{" + str(value_key) + "}", str(values[value_key]))
	return text

func _get_localization() -> Node:
	var main_loop := Engine.get_main_loop()
	if main_loop is SceneTree:
		return main_loop.root.get_node_or_null("Localization")
	return null

func _english_text(key: String) -> String:
	match key:
		"level_complete":
			return "Level {number} complete!"
		"level_complete_short":
			return "Level complete"
		"trap_disappeared":
			return "Trapped by {trap} -{cost} :("
		"king_untouchable":
			return "The king is untouchable!"
		"trap_light_soul_joined":
			return "Another soul joins the Light -{cost}"
		"sacrifice":
			return "{piece} Sacrifice"
		"piece_pawn":
			return "Pawn"
		"piece_knight":
			return "Knight"
		"piece_bishop":
			return "Bishop"
		"piece_rook":
			return "Rook"
		"piece_queen":
			return "Queen"
		"piece_king":
			return "King"
		"piece_generic":
			return "Piece"
		"color_line":
			return "Color Line"
		"row_6":
			return "6 in Row"
		"row_7":
			return "7 in Row"
		"row_8":
			return "8 in Row"
		"long_line":
			return "Long Line"
		"pawn_formation":
			return "Pawn Formation"
		"knight_line":
			return "Knight Line"
		"bishop_chain":
			return "Bishop Chain"
		"rook_formation":
			return "Rook Formation"
		"queen_formation":
			return "Queen Formation"
		"typed_line":
			return "Typed Line"
		"united_knights":
			return "United Knights"
		"united_bishops":
			return "United Bishops"
		"united_rooks":
			return "United Rooks"
		"united_forces":
			return "United Forces"
	return key

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

func end_game(result: String = GAME_RESULT_LOSS):
	var achieved_best_score := current_score > high_score
	if achieved_best_score:
		high_score = current_score
		save_game_state()
	game_over.emit(current_score, result, achieved_best_score)

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
