extends Node2D

@onready var board_manager = $BoardManager
@onready var screen_background: ColorRect = $ScreenBackground
@onready var score_frame: PanelContainer = $CanvasLayer/ScoreFrame
@onready var board_tint_overlay: ColorRect = $BoardTintOverlay
@onready var score_panel: ColorRect = $CanvasLayer/ScorePanel
@onready var score_shadow: ColorRect = $CanvasLayer/ScoreShadow
@onready var puzzle_panel: ColorRect = $CanvasLayer/PuzzlePanel
@onready var puzzle_frame: PanelContainer = $CanvasLayer/PuzzlePanel/PuzzleFrame
@onready var puzzle_image: TextureRect = $CanvasLayer/PuzzlePanel/PuzzleImage
@onready var puzzle_tiles: Control = $CanvasLayer/PuzzlePanel/PuzzleTiles
@onready var puzzle_badge: TextureRect = $CanvasLayer/PuzzleBadge
@onready var message_label: Label = $CanvasLayer/MessageLabel
@onready var score_label: Label = $CanvasLayer/ScoreHBox/ScoreLabel
@onready var high_score_label: Label = $CanvasLayer/ScoreHBox/HighScoreLabel
@onready var score_hbox: HBoxContainer = $CanvasLayer/ScoreHBox
@onready var color_lines_badge: LineMetricBadge = $CanvasLayer/ScoreHBox/StatsPanel/StatsHBox/ColorLinesStat/Badge
@onready var color_lines_value_label: Label = $CanvasLayer/ScoreHBox/StatsPanel/StatsHBox/ColorLinesStat/ValueLabel
@onready var type_lines_badge: LineMetricBadge = $CanvasLayer/ScoreHBox/StatsPanel/StatsHBox/TypeLinesStat/Badge
@onready var type_lines_value_label: Label = $CanvasLayer/ScoreHBox/StatsPanel/StatsHBox/TypeLinesStat/ValueLabel
@onready var action_buttons: HBoxContainer = $CanvasLayer/ActionButtons
@onready var reset_button: Button = $CanvasLayer/ActionButtons/ResetButton
@onready var action_main_menu_button: Button = $CanvasLayer/ActionButtons/MainMenuButton
@onready var game_over_overlay: Control = $CanvasLayer/UI/GameOverOverlay
@onready var game_over_backdrop: ColorRect = $CanvasLayer/UI/GameOverOverlay/Backdrop
@onready var game_over_panel: PanelContainer = $CanvasLayer/UI/GameOverOverlay/CenterContainer/GameOverPanel
@onready var game_over_title_label: Label = $CanvasLayer/UI/GameOverOverlay/CenterContainer/GameOverPanel/VBox/TitleLabel
@onready var game_over_summary_label: Label = $CanvasLayer/UI/GameOverOverlay/CenterContainer/GameOverPanel/VBox/SummaryLabel
@onready var game_over_score_label: Label = $CanvasLayer/UI/GameOverOverlay/CenterContainer/GameOverPanel/VBox/FinalScoreLabel
@onready var restart_button: Button = $CanvasLayer/UI/GameOverOverlay/CenterContainer/GameOverPanel/VBox/ButtonsRow/RestartButton
@onready var main_menu_button: Button = $CanvasLayer/UI/GameOverOverlay/CenterContainer/GameOverPanel/VBox/ButtonsRow/MainMenuButton

var is_processing_move: bool = false
var chain_animation_tween: Tween
var current_puzzle_level: int = 0
var revealed_puzzle_tiles: int = 0
var puzzle_tile_order: Array[int] = []
var message_queue: Array[String] = []
var is_message_queue_running: bool = false
var message_tween: Tween
var base_message_position: Vector2 = Vector2.ZERO
var default_theme_cache: ThemeData = null

const TOP_BAR_SHADOW_HEIGHT: float = 5.0
const HUD_MARGIN_LEFT: float = 3.0
const HUD_MARGIN_TOP: float = 3.0
const HUD_MARGIN_GAP: float = 3.0
const HUD_MESSAGE_HEIGHT_PADDING: float = 14.0
const PUZZLE_FRAME_INSET: float = 5.0
const PUZZLE_BADGE_WIDTH_RATIO: float = 0.66
const PUZZLE_BADGE_BORDER_OVERLAP: float = 8.0
const SCORE_FRAME_INSET_X: float = 5.0
const SCORE_FRAME_INSET_Y: float = 10.0
const SCORE_ROW_HEIGHT: float = 66.0
const ACTION_BUTTON_HEIGHT: float = 72.0
const ACTION_BUTTON_GAP: float = 8.0
const ACTION_BUTTON_PANEL_MARGIN: float = 8.0
const PUZZLE_COLUMNS: int = 5
const PUZZLE_ROWS: int = 5
const PUZZLE_TILE_MARGIN: float = 1.5
const MESSAGE_SLIDE_DISTANCE: float = 120.0
const MESSAGE_SLIDE_IN_DURATION: float = 0.42
const MESSAGE_HOLD_DURATION: float = 3.0
const MESSAGE_SLIDE_OUT_DURATION: float = 0.38
const DEBUG_HUD_LAYOUT: bool = false

func _ready():
	GameManager.reset_game()
	_lock_mobile_orientation()
	base_message_position = message_label.position
	apply_theme(_get_theme())
	_setup_signals()
	_initialize_game()
	_update_layout()
	_update_ui()

func _lock_mobile_orientation():
	if OS.has_feature("android"):
		DisplayServer.screen_set_orientation(DisplayServer.SCREEN_PORTRAIT)

func _get_theme() -> ThemeData:
	var main_loop: MainLoop = Engine.get_main_loop()
	if main_loop is SceneTree:
		var root: Window = main_loop.root
		var theme_manager: Node = root.get_node_or_null("ThemeManager")
		if theme_manager != null:
			return theme_manager.get_active_theme()
	return null

func apply_theme(theme: ThemeData):
	if theme == null:
		return

	screen_background.color = Color(0.02, 0.02, 0.02, 1.0)
	board_tint_overlay.color = Color(0.02, 0.02, 0.02, 0.24)
	score_panel.color = Color(0.03, 0.07, 0.12, 0.0)
	score_shadow.color = theme.hud_shadow_color
	puzzle_panel.color = Color(0.06, 0.09, 0.13, 1.0)
	message_label.add_theme_color_override("font_color", theme.puzzle_message_text_color)
	message_label.add_theme_color_override("font_outline_color", theme.puzzle_message_outline_color)
	message_label.add_theme_font_override("font", _build_dialog_font(theme.dialog_font_names, theme.puzzle_message_font_weight))
	message_label.add_theme_font_size_override("font_size", theme.puzzle_message_font_size)
	score_frame.add_theme_stylebox_override("panel", _build_puzzle_frame_style())
	puzzle_frame.add_theme_stylebox_override("panel", _build_puzzle_frame_style())

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
	_apply_dialog_theme(theme)
	if _has_puzzle_levels():
		puzzle_image.texture = _get_puzzle_level_texture(current_puzzle_level)
		if puzzle_tile_order.size() == _get_total_puzzle_tiles():
			_refresh_puzzle_tiles()
	_update_layout()

func _apply_dialog_theme(theme):
	game_over_backdrop.color = theme.dialog_overlay_color
	game_over_panel.add_theme_stylebox_override(
		"panel",
		_build_dialog_panel_style(theme.dialog_panel_background_color, theme.dialog_panel_border_color)
	)

	var title_font: SystemFont = _build_dialog_font(theme.dialog_font_names, theme.dialog_title_font_weight)
	var body_font: SystemFont = _build_dialog_font(theme.dialog_font_names, theme.dialog_body_font_weight)
	var button_font: SystemFont = _build_dialog_font(theme.dialog_font_names, theme.dialog_button_font_weight)

	_apply_dialog_label_style(
		game_over_title_label,
		title_font,
		theme.dialog_title_font_size,
		theme.dialog_title_color
	)
	_apply_dialog_label_style(
		game_over_summary_label,
		body_font,
		theme.dialog_body_font_size,
		theme.dialog_body_color
	)
	_apply_dialog_label_style(
		game_over_score_label,
		body_font,
		theme.dialog_score_font_size,
		theme.dialog_title_color
	)

	_apply_dialog_button_style(
		restart_button,
		button_font,
		theme.dialog_button_font_size,
		theme.dialog_button_primary_color,
		theme.dialog_button_primary_hover_color,
		theme.dialog_button_text_color
	)
	_apply_dialog_button_style(
		main_menu_button,
		button_font,
		theme.dialog_button_font_size,
		theme.dialog_button_secondary_color,
		theme.dialog_button_secondary_hover_color,
		theme.dialog_button_text_color,
		theme.dialog_button_secondary_border_color,
		theme.dialog_button_secondary_border_hover_color
	)
	_apply_dialog_button_style(
		reset_button,
		button_font,
		theme.dialog_button_font_size,
		theme.dialog_button_secondary_color,
		theme.dialog_button_secondary_hover_color,
		theme.dialog_button_text_color,
		theme.dialog_button_secondary_border_color,
		theme.dialog_button_secondary_border_hover_color
	)
	_apply_link_button_style(
		action_main_menu_button,
		button_font,
		theme.dialog_button_font_size,
		theme.dialog_button_link_color,
		theme.dialog_button_link_hover_color
	)

func _build_dialog_font(font_names: PackedStringArray, font_weight: int) -> SystemFont:
	var font := SystemFont.new()
	font.font_names = font_names
	font.font_weight = font_weight
	return font

func _apply_dialog_label_style(label: Label, font: Font, font_size: int, font_color: Color):
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", font_color)

func _apply_dialog_button_style(
	button: Button,
	font: Font,
	font_size: int,
	normal_color: Color,
	hover_color: Color,
	text_color: Color,
	normal_border_color: Color = Color.TRANSPARENT,
	hover_border_color: Color = Color.TRANSPARENT
):
	button.add_theme_font_override("font", font)
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", text_color)
	button.add_theme_stylebox_override("normal", _build_dialog_button_style(normal_color, normal_border_color))
	button.add_theme_stylebox_override("hover", _build_dialog_button_style(hover_color, hover_border_color))

func _apply_link_button_style(
	button: Button,
	font: Font,
	font_size: int,
	normal_color: Color,
	hover_color: Color
):
	button.add_theme_font_override("font", font)
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", normal_color)
	button.add_theme_color_override("font_hover_color", hover_color)
	button.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	button.add_theme_stylebox_override("hover", StyleBoxEmpty.new())

func _build_dialog_panel_style(background_color: Color, border_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background_color
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = border_color
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_left = 18
	style.corner_radius_bottom_right = 18
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.35)
	style.shadow_size = 16
	style.shadow_offset = Vector2(0.0, 10.0)
	style.content_margin_left = 34.0
	style.content_margin_top = 34.0
	style.content_margin_right = 34.0
	style.content_margin_bottom = 34.0
	return style

func _build_dialog_button_style(background_color: Color, border_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background_color
	style.border_width_left = 2 if border_color.a > 0.0 else 0
	style.border_width_top = 2 if border_color.a > 0.0 else 0
	style.border_width_right = 2 if border_color.a > 0.0 else 0
	style.border_width_bottom = 2 if border_color.a > 0.0 else 0
	style.border_color = border_color
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.content_margin_left = 18.0
	style.content_margin_top = 14.0
	style.content_margin_right = 18.0
	style.content_margin_bottom = 14.0
	return style

func _setup_signals():
	board_manager.capture_made.connect(_on_capture_made)
	board_manager.piece_moved.connect(_on_piece_moved)
	GameManager.score_updated.connect(_on_score_updated)
	GameManager.line_metrics_updated.connect(_on_line_metrics_updated)
	GameManager.game_over.connect(_on_game_over)
	restart_button.pressed.connect(_on_restart_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	reset_button.pressed.connect(_on_restart_pressed)
	action_main_menu_button.pressed.connect(_on_main_menu_pressed)
	get_viewport().size_changed.connect(_on_viewport_size_changed)

func _on_viewport_size_changed():
	_update_layout()

func _update_layout():
	var viewport_size := get_viewport_rect().size
	_update_screen_backdrop(viewport_size)
	var top_bar_height: float = _update_top_hud_layout(viewport_size)
	var board_render_size: float = board_manager.get_rendered_pixel_size()
	var bottom_actions_height: float = ACTION_BUTTON_GAP + ACTION_BUTTON_HEIGHT + HUD_MARGIN_TOP
	var available_height: float = maxf(viewport_size.y - top_bar_height - TOP_BAR_SHADOW_HEIGHT - bottom_actions_height, 120.0)
	var width_scale: float = viewport_size.x / board_render_size
	var height_scale: float = available_height / board_render_size
	var scale_factor: float = maxf(minf(width_scale, height_scale), 0.1)
	var scaled_board_height: float = board_render_size * scale_factor
	var required_height: float = top_bar_height + TOP_BAR_SHADOW_HEIGHT + scaled_board_height + bottom_actions_height

	_ensure_window_height(required_height, viewport_size)

	viewport_size = get_viewport_rect().size
	board_render_size = board_manager.get_rendered_pixel_size()
	available_height = maxf(viewport_size.y - top_bar_height - TOP_BAR_SHADOW_HEIGHT - bottom_actions_height, 120.0)
	width_scale = viewport_size.x / board_render_size
	height_scale = available_height / board_render_size
	scale_factor = maxf(minf(width_scale, height_scale), 0.1)

	board_manager.scale = Vector2(scale_factor, scale_factor)

	var scaled_board_width: float = board_render_size * scale_factor
	scaled_board_height = board_render_size * scale_factor
	var board_x: float = (viewport_size.x - scaled_board_width) * 0.5
	var board_y: float = top_bar_height + TOP_BAR_SHADOW_HEIGHT
	board_manager.position = Vector2(board_x, board_y)
	_update_action_buttons_layout(board_x, board_y + scaled_board_height + ACTION_BUTTON_GAP, scaled_board_width)

func _update_action_buttons_layout(board_x: float, buttons_y: float, board_width: float):
	action_buttons.offset_left = board_x + ACTION_BUTTON_PANEL_MARGIN
	action_buttons.offset_top = buttons_y
	action_buttons.offset_right = board_x + board_width - ACTION_BUTTON_PANEL_MARGIN
	action_buttons.offset_bottom = buttons_y + ACTION_BUTTON_HEIGHT

func _update_screen_backdrop(viewport_size: Vector2):
	screen_background.position = Vector2.ZERO
	screen_background.size = viewport_size
	screen_background.z_index = -100

	board_tint_overlay.position = Vector2.ZERO
	board_tint_overlay.size = viewport_size
	board_tint_overlay.z_index = 100

func _update_top_hud_layout(viewport_size: Vector2) -> float:
	var panel_width: float = maxf(viewport_size.x - HUD_MARGIN_LEFT * 2.0, 0.0)
	var puzzle_texture: Texture2D = _get_puzzle_level_texture(current_puzzle_level)
	var puzzle_height: float = 160.0
	if puzzle_texture != null and puzzle_texture.get_width() > 0:
		puzzle_height = panel_width * float(puzzle_texture.get_height()) / float(puzzle_texture.get_width())
	puzzle_height = clampf(puzzle_height, 120.0, 260.0)
	var badge_height: float = 0.0
	var badge_width: float = panel_width * PUZZLE_BADGE_WIDTH_RATIO
	if puzzle_badge.texture != null and puzzle_badge.texture.get_width() > 0:
		badge_height = badge_width * float(puzzle_badge.texture.get_height()) / float(puzzle_badge.texture.get_width())
	var panel_top: float = HUD_MARGIN_TOP + maxf(badge_height - PUZZLE_BADGE_BORDER_OVERLAP, 0.0)

	puzzle_panel.offset_left = HUD_MARGIN_LEFT
	puzzle_panel.offset_top = panel_top
	puzzle_panel.offset_right = -HUD_MARGIN_LEFT
	puzzle_panel.offset_bottom = panel_top + puzzle_height

	var badge_x: float = (viewport_size.x - badge_width) * 0.5
	puzzle_badge.offset_left = badge_x
	puzzle_badge.offset_top = HUD_MARGIN_TOP
	puzzle_badge.offset_right = badge_x + badge_width
	puzzle_badge.offset_bottom = HUD_MARGIN_TOP + badge_height

	puzzle_frame.offset_left = 0.0
	puzzle_frame.offset_top = 0.0
	puzzle_frame.offset_right = 0.0
	puzzle_frame.offset_bottom = 0.0
	puzzle_image.offset_left = PUZZLE_FRAME_INSET
	puzzle_image.offset_top = PUZZLE_FRAME_INSET
	puzzle_image.offset_right = -PUZZLE_FRAME_INSET
	puzzle_image.offset_bottom = -PUZZLE_FRAME_INSET
	puzzle_tiles.offset_left = PUZZLE_FRAME_INSET
	puzzle_tiles.offset_top = PUZZLE_FRAME_INSET
	puzzle_tiles.offset_right = -PUZZLE_FRAME_INSET
	puzzle_tiles.offset_bottom = -PUZZLE_FRAME_INSET

	var message_height: float = maxf(float(_get_puzzle_theme().puzzle_message_font_size) + HUD_MESSAGE_HEIGHT_PADDING, 42.0)
	var message_top: float = puzzle_panel.offset_bottom + HUD_MARGIN_GAP
	message_label.offset_left = HUD_MARGIN_LEFT
	message_label.offset_top = message_top
	message_label.offset_right = -HUD_MARGIN_LEFT
	message_label.offset_bottom = message_label.offset_top + message_height

	var score_frame_top: float = message_label.offset_bottom + HUD_MARGIN_GAP
	score_hbox.offset_left = HUD_MARGIN_LEFT + SCORE_FRAME_INSET_X
	score_hbox.offset_top = score_frame_top + SCORE_FRAME_INSET_Y
	score_hbox.offset_right = -(HUD_MARGIN_LEFT + SCORE_FRAME_INSET_X)
	score_hbox.offset_bottom = score_hbox.offset_top + SCORE_ROW_HEIGHT

	score_panel.offset_left = HUD_MARGIN_LEFT
	score_panel.offset_top = score_frame_top
	score_panel.offset_right = -HUD_MARGIN_LEFT
	score_panel.offset_bottom = score_hbox.offset_bottom + SCORE_FRAME_INSET_Y

	score_frame.offset_left = HUD_MARGIN_LEFT
	score_frame.offset_top = score_frame_top
	score_frame.offset_right = -HUD_MARGIN_LEFT
	score_frame.offset_bottom = score_panel.offset_bottom

	score_shadow.offset_left = 0.0
	score_shadow.offset_right = 0.0
	score_shadow.offset_top = score_panel.offset_bottom
	score_shadow.offset_bottom = score_panel.offset_bottom + TOP_BAR_SHADOW_HEIGHT

	_debug_hud_layout(viewport_size, panel_width, puzzle_height, puzzle_texture)
	return score_panel.offset_bottom

func _debug_hud_layout(
	viewport_size: Vector2,
	panel_width: float,
	puzzle_height: float,
	puzzle_texture: Texture2D
):
	if not DEBUG_HUD_LAYOUT:
		return

	var theme: ThemeData = _get_theme()
	var active_theme_name := "none"
	if theme != null:
		active_theme_name = str(theme.resource_path)
	var puzzle_size := Vector2.ZERO
	if puzzle_texture != null:
		puzzle_size = Vector2(puzzle_texture.get_width(), puzzle_texture.get_height())

	print(
		"[HUD] theme=", active_theme_name,
		" viewport=", viewport_size,
		" panel_w=", panel_width,
		" puzzle_h=", puzzle_height,
		" puzzle_tex=", puzzle_size
	)
	print(
		"[HUD] puzzle_panel=", Rect2(
			Vector2(puzzle_panel.offset_left, puzzle_panel.offset_top),
			Vector2(panel_width, puzzle_panel.offset_bottom - puzzle_panel.offset_top)
		),
		" message=", Rect2(
			Vector2(message_label.offset_left, message_label.offset_top),
			Vector2(viewport_size.x - HUD_MARGIN_LEFT * 2.0, message_label.offset_bottom - message_label.offset_top)
		),
		" score_hbox=", Rect2(
			Vector2(score_hbox.offset_left, score_hbox.offset_top),
			Vector2(viewport_size.x, score_hbox.offset_bottom - score_hbox.offset_top)
		)
	)

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
	if message_tween:
		message_tween.kill()
		message_tween = null
	message_label.text = ""
	message_label.modulate.a = 0.0
	message_label.position = base_message_position + Vector2(-MESSAGE_SLIDE_DISTANCE, 0.0)
	_load_puzzle_level(current_puzzle_level)

func _has_puzzle_levels() -> bool:
	return _get_puzzle_theme().puzzle_level_images.size() > 0

func _get_puzzle_level_count() -> int:
	return _get_puzzle_theme().puzzle_level_images.size()

func _get_puzzle_level_texture(level_index: int) -> Texture2D:
	var theme: ThemeData = _get_puzzle_theme()
	if theme != null and not theme.puzzle_level_images.is_empty():
		var clamped_index := clampi(level_index, 0, theme.puzzle_level_images.size() - 1)
		var level_texture: Texture2D = theme.puzzle_level_images[clamped_index]
		if level_texture != null:
			return level_texture
	return load("res://assets/ui/themes/default/level0.png") as Texture2D

func _get_puzzle_theme() -> ThemeData:
	var theme: ThemeData = _get_theme()
	if theme != null and theme.puzzle_level_images.size() > 0:
		return theme
	return _get_default_theme()

func _get_default_theme() -> ThemeData:
	if default_theme_cache == null:
		default_theme_cache = load("res://themes/default_theme.tres") as ThemeData
	return default_theme_cache

func _build_puzzle_frame_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.07, 0.1, 1.0)
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.border_color = Color(0.79, 0.62, 0.29, 0.95)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	return style

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
	_update_layout()

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

	var theme: ThemeData = _get_puzzle_theme()
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
		message_label.position = base_message_position + Vector2(-MESSAGE_SLIDE_DISTANCE, 0.0)
		message_label.modulate.a = 0.0
		if message_tween:
			message_tween.kill()
		message_tween = create_tween()
		message_tween.set_trans(Tween.TRANS_QUAD)
		message_tween.set_ease(Tween.EASE_OUT)
		message_tween.parallel().tween_property(message_label, "position:x", base_message_position.x, MESSAGE_SLIDE_IN_DURATION)
		message_tween.parallel().tween_property(message_label, "modulate:a", 1.0, MESSAGE_SLIDE_IN_DURATION)
		await message_tween.finished
		await get_tree().create_timer(MESSAGE_HOLD_DURATION).timeout
		message_tween = create_tween()
		message_tween.set_trans(Tween.TRANS_QUAD)
		message_tween.set_ease(Tween.EASE_IN)
		message_tween.parallel().tween_property(message_label, "position:x", base_message_position.x - MESSAGE_SLIDE_DISTANCE, MESSAGE_SLIDE_OUT_DURATION)
		message_tween.parallel().tween_property(message_label, "modulate:a", 0.0, MESSAGE_SLIDE_OUT_DURATION)
		await message_tween.finished

	is_message_queue_running = false
	message_tween = null

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
	if not board_manager.has_legal_moves() or not board_manager.can_spawn_any_piece():
		GameManager.end_game()

func _spawn_initial_pieces():
	var piece_count = 3
	
	for i in range(piece_count):
		var spawn_data: Dictionary = board_manager.get_random_spawn_piece_data()
		if spawn_data.is_empty():
			break
		if not board_manager.spawn_piece_with_preferred_placement(spawn_data):
			break

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
	game_over_overlay.visible = true
	game_over_score_label.text = "Final Score: " + str(final_score)
	AudioManager.play_sound("game_over")

func _on_restart_pressed():
	game_over_overlay.visible = false
	is_processing_move = false
	GameManager.reset_game()
	_initialize_game()
	_update_layout()
	_update_ui()

func _on_main_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")

func _resolve_turn():
	is_processing_move = true
	board_manager.set_input_enabled(false)
	await get_tree().create_timer(0.3).timeout

	var cleared_from_move := await _resolve_chain_waves()
	if not cleared_from_move:
		var spawned_count: int = _spawn_new_pieces()
		if spawned_count == 0:
			board_manager.fill_empty_cells_with_kings()
			_check_game_over()
			is_processing_move = false
			return
		await get_tree().create_timer(0.3).timeout
		await _resolve_chain_waves()

	await get_tree().create_timer(0.3).timeout
	_check_game_over()

	is_processing_move = false
	if not game_over_overlay.visible:
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

func _spawn_new_pieces() -> int:
	return board_manager.spawn_random_pieces(3)
