extends Node2D

@onready var board_manager = $BoardManager
@onready var score_label: Label = $CanvasLayer/ScoreHBox/ScoreLabel
@onready var high_score_label: Label = $CanvasLayer/ScoreHBox/HighScoreLabel
@onready var pause_button: Button = $CanvasLayer/UI/PauseButton
@onready var game_over_panel: Control = $CanvasLayer/UI/GameOverPanel
@onready var game_over_score_label: Label = $CanvasLayer/UI/GameOverPanel/VBox/FinalScoreLabel
@onready var restart_button: Button = $CanvasLayer/UI/GameOverPanel/VBox/RestartButton
@onready var main_menu_button: Button = $CanvasLayer/UI/GameOverPanel/VBox/MainMenuButton

var is_paused: bool = false
var is_processing_move: bool = false
var chain_animation_tween: Tween

const TOP_BAR_HEIGHT: float = 60.0
const TOP_BAR_SHADOW_HEIGHT: float = 5.0

func _ready():
	GameManager.reset_game()
	_setup_signals()
	_initialize_game()
	_update_layout()
	_update_ui()

func _setup_signals():
	board_manager.capture_made.connect(_on_capture_made)
	board_manager.piece_moved.connect(_on_piece_moved)
	GameManager.score_updated.connect(_on_score_updated)
	GameManager.game_over.connect(_on_game_over)
	restart_button.pressed.connect(_on_restart_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	pause_button.pressed.connect(_on_pause_pressed)
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
		_toggle_pause()

func _toggle_pause():
	if game_over_panel.visible:
		return
	is_paused = not is_paused
	get_tree().paused = is_paused
	pause_button.text = ">" if is_paused else "II"

func _on_pause_pressed():
	_toggle_pause()

func _initialize_game():
	board_manager.board_size = GameManager.board_size
	board_manager.clear_board()
	
	_spawn_initial_pieces()

func _check_game_over():
	await get_tree().create_timer(1.0).timeout
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
		var piece_type = GameManager.get_random_piece_type()
		var color = GameManager.get_random_piece_color()
		board_manager.add_piece(piece_type, color, cell)

func _on_capture_made(_piece, _target):
	AudioManager.play_sound("capture")
	AudioManager.vibrate()

func _on_piece_moved(_from, _to):
	_spawn_new_pieces()
	_check_for_chain()

func _on_score_updated(_new_score: int):
	_update_ui()

func _update_ui():
	score_label.text = "Score: " + str(GameManager.current_score)
	high_score_label.text = "Best: " + str(GameManager.high_score)

func _on_game_over(final_score: int):
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

func _check_for_chain():
	await get_tree().create_timer(0.3).timeout
	
	var chains = ChainDetector.find_chains(board_manager.board)
	
	if chains.is_empty():
		_spawn_new_pieces()
		await get_tree().create_timer(0.3).timeout
		_check_game_over()
		return
	
	var selected_chain = ChainDetector.select_random_chain(chains)
	
	# For color lines, we need to determine if this is a color line or type line
	var is_color_line = true
	if selected_chain.size() >= 5:
		# Check if all pieces in the chain are the same color
		var first_color = selected_chain[0].piece_color
		for piece in selected_chain:
			if piece.piece_color != first_color:
				is_color_line = false
				break
		
		# If not all same color, check if all same type (for type line bonus)
		if not is_color_line:
			var first_type = selected_chain[0].piece_type
			for piece in selected_chain:
				if piece.piece_type != first_type:
					is_color_line = true  # It's not a type line either, so revert to color line
					break
	else:
		is_color_line = false
	
	await _animate_chain_removal(selected_chain)
	
	# Calculate score based on line type
	var base_points = selected_chain.size() * 100
	var bonus = 1.0
	
	match selected_chain.size():
		5: bonus = 1.5
		6: bonus = 2.0
		7: bonus = 3.0
	
	var points = int(base_points * bonus)
	
	# Apply bonus multipliers for line types
	if is_color_line and selected_chain.size() >= 5:
		# This is a color line - normal scoring
		GameManager.add_score(selected_chain.size(), selected_chain.size())
	elif not is_color_line and selected_chain.size() >= 5:
		# This is a type line - double scoring
		GameManager.add_score(selected_chain.size(), selected_chain.size() * 2)
		# Add combo multiplier for type lines
		GameManager.combo_multiplier = min(GameManager.combo_multiplier + 1, 5)
	else:
		# Default scoring
		GameManager.add_score(selected_chain.size(), selected_chain.size())
	
	chain_animation_tween = null
	
	_spawn_new_pieces()
	await get_tree().create_timer(0.3).timeout
	_check_game_over()

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
