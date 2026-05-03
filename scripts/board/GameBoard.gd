extends Node2D

@onready var board_manager = $BoardManager
@onready var score_panel: ColorRect = $CanvasLayer/ScorePanel
@onready var score_shadow: ColorRect = $CanvasLayer/ScoreShadow
@onready var puzzle_panel: ColorRect = $CanvasLayer/PuzzlePanel
@onready var puzzle_image: TextureRect = $CanvasLayer/PuzzlePanel/PuzzleImage
@onready var puzzle_tiles: Control = $CanvasLayer/PuzzlePanel/PuzzleTiles
@onready var message_label: Label = $CanvasLayer/MessageLabel
@onready var score_label: Label = $CanvasLayer/ScoreHBox/ScoreLabel
@onready var high_score_label: Label = $CanvasLayer/ScoreHBox/HighScoreLabel
@onready var color_lines_badge: LineMetricBadge = $CanvasLayer/ScoreHBox/StatsPanel/StatsHBox/ColorLinesStat/Badge
@onready var color_lines_value_label: Label = $CanvasLayer/ScoreHBox/StatsPanel/StatsHBox/ColorLinesStat/ValueLabel
@onready var type_lines_badge: LineMetricBadge = $CanvasLayer/ScoreHBox/StatsPanel/StatsHBox/TypeLinesStat/Badge
@onready var type_lines_value_label: Label = $CanvasLayer/ScoreHBox/StatsPanel/StatsHBox/TypeLinesStat/ValueLabel
@onready var game_over_panel: Control = $CanvasLayer/UI/GameOverPanel
@onready var game_over_score_label: Label = $CanvasLayer/UI/GameOverPanel/VBox/FinalScoreLabel
@onready var restart_button: Button = $CanvasLayer/UI/GameOverPanel/VBox/RestartButton
@onready var main_menu_button: Button = $CanvasLayer/UI/GameOverPanel/VBox/MainMenuButton

var is_processing_move: bool = false
var chain_animation_tween: Tween
var current_puzzle_level: int = 0
var revealed_puzzle_tiles: int = 0
var puzzle_tile_order: Array[int] = []
var message_queue: Array[String] = []
var is_message_queue_running: bool = false

const TOP_BAR_HEIGHT: float = 238.0
const TOP_BAR_SHADOW_HEIGHT: float = 5.0
const PUZZLE_COLUMNS: int = 5
const PUZZLE_ROWS: int = 5
const PUZZLE_TILE_MARGIN: float = 1.5

func _ready():
	GameManager.reset_game()
	_lock_mobile_orientation()
	apply_theme(_get_theme())
	_setup_signals()
	_initialize_game()
	_update_layout()
	_update_ui()

func _lock_mobile_orientation():
	if OS.has_feature("android"):
		DisplayServer.screen_set_orientation(DisplayServer.SCREEN_PORTRAIT)

func _get_theme():
	var main_loop: MainLoop = Engine.get_main_loop()
	if main_loop is SceneTree:
		var root: Window = main_loop.root
		var theme_manager = root.get_node_or_null("ThemeManager")
		if theme_manager != null:
			return theme_manager.get_active_theme()
	return null

func apply_theme(theme):
	if theme == null:
		return

	score_panel.color = theme.hud_panel_color
	score_shadow.color = theme.hud_shadow_color
	puzzle_panel.color = theme.puzzle_board_background_color
	message_label.add_theme_color_override("font_color", theme.puzzle_message_text_color)
	message_label.add_theme_color_override("font_outline_color", theme.puzzle_message_outline_color)

	score_label.add_theme_color_override("font_color", theme.hud_primary_text_color)
	score_label.add_theme_color_override("font_outline_color", theme.hud_outline_color)
	high_score_label.add_theme_color_override("font_color", theme.hud_secondary_text_color)
	high_score_label.add_theme_color_override("font_outline_color", theme.hud_secondary_outline_color)
	color_lines_value_label.add_theme_color_override("font_color", theme.hud_primary_text_color)
	color_lines_value_label.add_theme_color_override("font_outline_color", theme.hud_secondary_outline_color)
	type_lines_value_label.add_theme_color_override("font_color", theme.hud_primary_text_color)
	type_lines_value_label.add_theme_color_override("font_outline_color", theme.hud_secondary_outline_color)

	board_manager.apply_theme(theme)
	color_lines_badge.apply_theme(theme)
	type_lines_badge.apply_theme(theme)
	if _has_puzzle_levels():
		puzzle_image.texture = _get_puzzle_level_texture(current_puzzle_level)
		if puzzle_tile_order.size() == _get_total_puzzle_tiles():
			_refresh_puzzle_tiles()

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
	var scale_factor: float = maxf(viewport_size.x / board_render_size, 0.1)
	var scaled_board_width: float = board_render_size * scale_factor
	var scaled_board_height: float = board_render_size * scale_factor
	var required_height: float = TOP_BAR_HEIGHT + TOP_BAR_SHADOW_HEIGHT + scaled_board_height

	_ensure_window_height(required_height, viewport_size)

	viewport_size = get_viewport_rect().size
	board_render_size = board_manager.get_rendered_pixel_size()
	scale_factor = maxf(viewport_size.x / board_render_size, 0.1)
	scale_factor = max(scale_factor, 0.1)

	board_manager.scale = Vector2(scale_factor, scale_factor)

	scaled_board_width = board_render_size * scale_factor
	scaled_board_height = board_render_size * scale_factor
	var board_x: float = (viewport_size.x - scaled_board_width) * 0.5
	var board_y: float = TOP_BAR_HEIGHT + TOP_BAR_SHADOW_HEIGHT
	board_manager.position = Vector2(board_x, board_y)

func _ensure_window_height(required_height: float, viewport_size: Vector2):
	if OS.has_feature("android"):
		return

	var window: Window = get_window()
	if window == null or window.mode != Window.MODE_WINDOWED:
		return

	var required_height_int: int = ceili(required_height)
	var current_width: int = ceili(viewport_size.x)
	window.min_size = Vector2i(window.min_size.x, required_height_int)
	if int(viewport_size.y) < required_height_int:
		window.size = Vector2i(current_width, required_height_int)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		return

func _initialize_game():
	board_manager.board_size = GameManager.board_size
	board_manager.clear_board()
	board_manager.set_input_enabled(true)
	_initialize_puzzle_progress()
	
	_spawn_initial_pieces()

func _initialize_puzzle_progress():
	current_puzzle_level = 0
	revealed_puzzle_tiles = 0
	puzzle_tile_order.clear()
	message_queue.clear()
	is_message_queue_running = false
	message_label.text = ""
	message_label.modulate.a = 0.0
	_load_puzzle_level(current_puzzle_level)

func _has_puzzle_levels() -> bool:
	var theme = _get_theme()
	return theme != null and theme.puzzle_level_images.size() > 0

func _get_puzzle_level_count() -> int:
	var theme = _get_theme()
	if theme == null:
		return 0
	return theme.puzzle_level_images.size()

func _get_puzzle_level_texture(level_index: int) -> Texture2D:
	var theme = _get_theme()
	if theme == null or level_index < 0 or level_index >= theme.puzzle_level_images.size():
		return null
	return theme.puzzle_level_images[level_index]

func _load_puzzle_level(level_index: int):
	if not _has_puzzle_levels():
		puzzle_panel.visible = false
		return

	puzzle_panel.visible = true
	current_puzzle_level = clampi(level_index, 0, _get_puzzle_level_count() - 1)
	revealed_puzzle_tiles = 0
	puzzle_image.texture = _get_puzzle_level_texture(current_puzzle_level)
	_build_puzzle_tile_order()
	_refresh_puzzle_tiles()

func _build_puzzle_tile_order():
	puzzle_tile_order.clear()
	for i in range(_get_total_puzzle_tiles()):
		puzzle_tile_order.append(i)
	puzzle_tile_order.shuffle()

func _get_total_puzzle_tiles() -> int:
	return PUZZLE_COLUMNS * PUZZLE_ROWS

func _refresh_puzzle_tiles():
	for child in puzzle_tiles.get_children():
		child.queue_free()

	if not _has_puzzle_levels():
		return

	var total_tiles: int = _get_total_puzzle_tiles()
	if puzzle_tile_order.size() != total_tiles:
		_build_puzzle_tile_order()

	var theme = _get_theme()
	for order_index in range(revealed_puzzle_tiles, total_tiles):
		var tile_index: int = puzzle_tile_order[order_index]
		var tile := ColorRect.new()
		var column: int = tile_index % PUZZLE_COLUMNS
		var row: int = int(floor(float(tile_index) / float(PUZZLE_COLUMNS)))
		tile.anchor_left = float(column) / float(PUZZLE_COLUMNS)
		tile.anchor_top = float(row) / float(PUZZLE_ROWS)
		tile.anchor_right = float(column + 1) / float(PUZZLE_COLUMNS)
		tile.anchor_bottom = float(row + 1) / float(PUZZLE_ROWS)
		tile.offset_left = PUZZLE_TILE_MARGIN
		tile.offset_top = PUZZLE_TILE_MARGIN
		tile.offset_right = -PUZZLE_TILE_MARGIN
		tile.offset_bottom = -PUZZLE_TILE_MARGIN
		tile.color = theme.puzzle_tile_cover_color
		puzzle_tiles.add_child(tile)

func _apply_puzzle_progress(removed_pieces: int):
	if removed_pieces <= 0 or not _has_puzzle_levels():
		return

	var remaining := removed_pieces
	while remaining > 0 and current_puzzle_level < _get_puzzle_level_count():
		var tiles_left := _get_total_puzzle_tiles() - revealed_puzzle_tiles
		if remaining < tiles_left:
			revealed_puzzle_tiles += remaining
			remaining = 0
			_refresh_puzzle_tiles()
			return

		revealed_puzzle_tiles = _get_total_puzzle_tiles()
		remaining -= tiles_left
		_refresh_puzzle_tiles()
		_queue_message("Completed the %s level!" % _get_ordinal(current_puzzle_level + 1))

		if current_puzzle_level + 1 >= _get_puzzle_level_count():
			return

		_load_puzzle_level(current_puzzle_level + 1)

func _queue_message(text: String):
	if text.is_empty():
		return

	message_queue.append(text)
	if not is_message_queue_running:
		_run_message_queue()

func _run_message_queue():
	if is_message_queue_running:
		return

	is_message_queue_running = true
	while not message_queue.is_empty():
		var next_message: String = str(message_queue.pop_front())
		message_label.text = next_message
		message_label.modulate.a = 1.0
		await get_tree().create_timer(1.35).timeout
		var fade_tween := create_tween()
		fade_tween.tween_property(message_label, "modulate:a", 0.0, 0.25)
		await fade_tween.finished

	is_message_queue_running = false

func _queue_chain_messages(chain: Dictionary):
	var pieces_removed: int = chain["pieces"].size()
	if chain.get("is_color_line", false):
		_queue_message("%d in a row" % pieces_removed)
	if chain.get("is_type_line", false):
		var piece_name := _get_piece_display_name(chain.get("matched_type", -1), pieces_removed)
		_queue_message("%d %s on the march" % [pieces_removed, piece_name])

func _get_piece_display_name(piece_type: int, count: int) -> String:
	var singular := "pieces"
	match piece_type:
		GameManager.PieceType.PAWN:
			singular = "pawn"
		GameManager.PieceType.KNIGHT:
			singular = "knight"
		GameManager.PieceType.BISHOP:
			singular = "bishop"
		GameManager.PieceType.ROOK:
			singular = "rook"
		GameManager.PieceType.QUEEN:
			singular = "queen"
		GameManager.PieceType.KING:
			singular = "king"
	if count == 1:
		return singular
	return singular + "s"

func _get_ordinal(number: int) -> String:
	var remainder_hundred := number % 100
	if remainder_hundred >= 11 and remainder_hundred <= 13:
		return str(number) + "th"

	match number % 10:
		1:
			return str(number) + "st"
		2:
			return str(number) + "nd"
		3:
			return str(number) + "rd"
	return str(number) + "th"

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
		_queue_chain_messages(chain)

	_apply_puzzle_progress(pieces_to_remove.size())

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
