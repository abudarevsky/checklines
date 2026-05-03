extends Node2D

@onready var board_manager = $BoardManager
@onready var score_label: Label = $CanvasLayer/ScoreHBox/ScoreLabel
@onready var high_score_label: Label = $CanvasLayer/ScoreHBox/HighScoreLabel
@onready var color_lines_value_label: Label = $CanvasLayer/ScoreHBox/StatsPanel/StatsHBox/ColorLinesStat/ValueLabel
@onready var type_lines_value_label: Label = $CanvasLayer/ScoreHBox/StatsPanel/StatsHBox/TypeLinesStat/ValueLabel
@onready var game_over_panel: Control = $CanvasLayer/UI/GameOverPanel
@onready var game_over_score_label: Label = $CanvasLayer/UI/GameOverPanel/VBox/FinalScoreLabel
@onready var restart_button: Button = $CanvasLayer/UI/GameOverPanel/VBox/RestartButton
@onready var main_menu_button: Button = $CanvasLayer/UI/GameOverPanel/VBox/MainMenuButton

var is_processing_move: bool = false
var chain_animation_tween: Tween

const TOP_BAR_HEIGHT: float = 60.0
const TOP_BAR_SHADOW_HEIGHT: float = 5.0

func _ready():
	GameManager.reset_game()
	_lock_mobile_orientation()
	_setup_signals()
	_initialize_game()
	_update_layout()
	_update_ui()

func _lock_mobile_orientation():
	if OS.has_feature("android"):
		DisplayServer.screen_set_orientation(DisplayServer.SCREEN_PORTRAIT)

func _setup_signals():
	board_manager.capture_made.connect(_on_capture_made)
	board_manager.piece_moved.connect(_on_piece_moved)
	GameManager.score_updated.connect(_on_score_updated)
	GameManager.line_metrics_updated.connect(_on_line_metrics_updated)
	GameManager.game_over.connect(_on_game_over)
	restart_button.pressed.connect(_on_restart_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	get_viewport().size_changed.connect(_on_viewport_size_changed)

func _on_viewport_size_changed():
	_update_layout()

func _update_layout():
	var viewport_size := get_viewport_rect().size
	var board_render_size: float = board_manager.get_rendered_pixel_size()
	var available_height: float = maxf(viewport_size.y - TOP_BAR_HEIGHT - TOP_BAR_SHADOW_HEIGHT, 1.0)
	var scale_factor: float = minf(viewport_size.x / board_render_size, available_height / board_render_size)
	scale_factor = max(scale_factor, 0.1)

	board_manager.scale = Vector2(scale_factor, scale_factor)

	var scaled_board_width: float = board_render_size * scale_factor
	var scaled_board_height: float = board_render_size * scale_factor
	var board_x: float = (viewport_size.x - scaled_board_width) * 0.5
	var board_y: float = TOP_BAR_HEIGHT + TOP_BAR_SHADOW_HEIGHT + (available_height - scaled_board_height) * 0.5
	board_manager.position = Vector2(board_x, board_y)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		return

func _initialize_game():
	board_manager.board_size = GameManager.board_size
	board_manager.clear_board()
	board_manager.set_input_enabled(true)
	
	_spawn_initial_pieces()

func _check_game_over():
	if not board_manager.has_legal_moves():
		GameManager.end_game()

func _spawn_initial_pieces():
	var piece_count = 3
	
	for i in range(piece_count):
		var empty_cells = board_manager.get_empty_cells()
		if empty_cells.is_empty():
			break
		
		empty_cells.shuffle()
		var cell = empty_cells[0]
		var spawn_data: Dictionary = board_manager.get_random_spawn_piece_data()
		if spawn_data.is_empty():
			break
		board_manager.add_piece(spawn_data["piece_type"], spawn_data["color"], cell)

func _on_capture_made(_piece, _target):
	AudioManager.play_sound("capture")
	AudioManager.vibrate()

func _on_piece_moved(_from, _to):
	if is_processing_move:
		return
	_resolve_turn()

func _on_score_updated(_new_score: int):
	_update_ui()

func _on_line_metrics_updated(_color_lines: int, _type_lines: int):
	_update_line_metrics_ui()

func _update_ui():
	score_label.text = "Score: " + str(GameManager.current_score)
	high_score_label.text = "Best: " + str(GameManager.high_score)
	_update_line_metrics_ui()

func _update_line_metrics_ui():
	color_lines_value_label.text = str(GameManager.color_lines_cleared)
	type_lines_value_label.text = str(GameManager.type_lines_cleared)

func _on_game_over(final_score: int):
	board_manager.set_input_enabled(false)
	game_over_panel.visible = true
	game_over_score_label.text = "Final Score: " + str(final_score)
	AudioManager.play_sound("game_over")

func _on_restart_pressed():
	game_over_panel.visible = false
	GameManager.reset_game()
	_initialize_game()

func _on_main_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")

func _resolve_turn():
	is_processing_move = true
	board_manager.set_input_enabled(false)
	await get_tree().create_timer(0.3).timeout

	var cleared_from_move := await _resolve_chain_waves()
	if not cleared_from_move:
		_spawn_new_pieces()
		await get_tree().create_timer(0.3).timeout
		await _resolve_chain_waves()

	await get_tree().create_timer(0.3).timeout
	_check_game_over()

	is_processing_move = false
	if not game_over_panel.visible:
		board_manager.set_input_enabled(true)

func _resolve_chain_waves() -> bool:
	var cleared_any := false

	while true:
		var chains: Array = ChainDetector.find_chains(board_manager.board)
		if chains.is_empty():
			return cleared_any

		cleared_any = true
		await _clear_chain_wave(chains)

	return cleared_any

func _clear_chain_wave(chains: Array):
	var pieces_to_remove := _get_unique_chain_pieces(chains)
	await _animate_chain_removal(pieces_to_remove)

	for chain in chains:
		var pieces_removed: int = chain["pieces"].size()
		var score_multiplier := 1.0
		if chain.get("is_type_line", false):
			score_multiplier *= 2.0
		if chain.get("is_combo", false):
			score_multiplier *= 1.5
		GameManager.add_score(pieces_removed, pieces_removed, score_multiplier)
		GameManager.register_cleared_line(
			chain.get("is_color_line", false),
			chain.get("is_type_line", false)
		)

	chain_animation_tween = null

func _get_unique_chain_pieces(chains: Array) -> Array:
	var unique_by_position: Dictionary = {}

	for chain in chains:
		for piece in chain["pieces"]:
			unique_by_position[piece.grid_position] = piece

	return unique_by_position.values()

func _animate_chain_removal(chain):
	AudioManager.play_sound("chain_clear")
	AudioManager.vibrate()
	
	var tween := create_tween()
	
	for piece in chain:
		tween.parallel().tween_property(piece, "scale", Vector2(1.5, 1.5), 0.2)
		tween.parallel().tween_property(piece, "modulate:a", 0.0, 0.3)
	
	await tween.finished
	
	for piece in chain:
		board_manager.remove_piece(piece.grid_position)

func _spawn_new_pieces():
	board_manager.spawn_random_pieces(3)
