extends Node

enum PieceType { PAWN, KNIGHT, BISHOP, ROOK, QUEEN, KING }
enum PieceColor { RED, BLUE, GREEN, ORANGE }

const BOARD_SIZE: int = 9
const CELL_SIZE: int = 100
const BOARD_PIXEL_SIZE: int = BOARD_SIZE * CELL_SIZE
const WINDOW_WIDTH: int = BOARD_PIXEL_SIZE
const WINDOW_HEIGHT: int = BOARD_PIXEL_SIZE
const BORDER_WIDTH: int = 3
const SELECTED_BORDER_WIDTH: int = 10
const BORDER_PADDING: int = 8
const BOARD_FRAME_MARGIN: int = SELECTED_BORDER_WIDTH + BORDER_PADDING

const COLOR_MAP: Dictionary = {
	PieceColor.RED: Color.RED,
	PieceColor.BLUE: Color.BLUE,
	PieceColor.GREEN: Color.GREEN,
	PieceColor.ORANGE: Color.ORANGE
}

var board_size: int = BOARD_SIZE
var cell_size: float = CELL_SIZE

var current_score: int = 0
var high_score: int = 0
var combo_multiplier: int = 1

signal score_updated(new_score: int)
signal game_over(final_score: int)
signal chain_detected(chain)

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

func add_score(pieces_removed: int, chain_length: int):
	var base_points := pieces_removed * 100
	var bonus: float = 1.0
	
	match chain_length:
		5: bonus = 1.5
		6: bonus = 2.0
		7: bonus = 3.0
	
	var points := int(base_points * bonus * combo_multiplier)
	current_score += points
	
	if current_score > high_score:
		high_score = current_score
		save_high_score()
	
	score_updated.emit(current_score)

func reset_game():
	current_score = 0
	combo_multiplier = 1
	score_updated.emit(0)

func end_game():
	game_over.emit(current_score)
	if current_score >= high_score:
		save_high_score()

func get_piece_spawn_weights() -> Array[float]:
	return [0.35, 0.22, 0.15, 0.12, 0.10, 0.06]

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
	return COLOR_MAP.get(color, Color.WHITE)