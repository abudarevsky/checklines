extends Node2D

const PuzzleTileCover = preload("res://scripts/ui/PuzzleTileCover.gd")

@onready var board_manager = $BoardManager
@onready var screen_background: ColorRect = $ScreenBackground
@onready var screen_gradient: TextureRect = $ScreenGradient
@onready var score_frame: PanelContainer = $CanvasLayer/ScoreFrame
@onready var board_tint_overlay: ColorRect = $BoardTintOverlay
@onready var score_panel: ColorRect = $CanvasLayer/ScorePanel
@onready var score_shadow: ColorRect = $CanvasLayer/ScoreShadow
@onready var puzzle_panel: ColorRect = $CanvasLayer/PuzzlePanel
@onready var puzzle_frame: PanelContainer = $CanvasLayer/PuzzlePanel/PuzzleFrame
@onready var puzzle_image: TextureRect = $CanvasLayer/PuzzlePanel/PuzzleImage
@onready var puzzle_tiles: Control = $CanvasLayer/PuzzlePanel/PuzzleTiles
@onready var puzzle_flying_banner: FlyingBanner = $CanvasLayer/PuzzlePanel/PuzzleFlyingBanner
@onready var move_hint_panel: PanelContainer = $CanvasLayer/MoveHintPanel
@onready var move_hint_icon: Control = $CanvasLayer/MoveHintPanel/MoveHintHBox/BulbIcon
@onready var move_hint_label: Label = $CanvasLayer/MoveHintPanel/MoveHintHBox/MoveHintLabel
@onready var puzzle_badge: TextureRect = $CanvasLayer/PuzzleBadge
@onready var gear_button: Button = $CanvasLayer/GearButton
@onready var score_clip: Control = $CanvasLayer/ScoreClip
@onready var message_panel: ColorRect = $CanvasLayer/ScoreClip/MessagePanel
@onready var message_label: Label = $CanvasLayer/ScoreClip/MessageLabel
@onready var score_label: Label = $CanvasLayer/ScoreClip/ScoreHBox/ScoreLabel
@onready var high_score_label: Label = $CanvasLayer/ScoreClip/ScoreHBox/HighScoreLabel
@onready var score_hbox: HBoxContainer = $CanvasLayer/ScoreClip/ScoreHBox
@onready var color_lines_badge: LineMetricBadge = $CanvasLayer/ScoreClip/ScoreHBox/StatsPanel/StatsHBox/ColorLinesStat/Badge
@onready var color_lines_value_label: Label = $CanvasLayer/ScoreClip/ScoreHBox/StatsPanel/StatsHBox/ColorLinesStat/ValueLabel
@onready var type_lines_badge: LineMetricBadge = $CanvasLayer/ScoreClip/ScoreHBox/StatsPanel/StatsHBox/TypeLinesStat/Badge
@onready var type_lines_value_label: Label = $CanvasLayer/ScoreClip/ScoreHBox/StatsPanel/StatsHBox/TypeLinesStat/ValueLabel
@onready var level_badge: LineMetricBadge = $CanvasLayer/ScoreClip/ScoreHBox/StatsPanel/StatsHBox/LevelStat/Badge
@onready var level_value_label: Label = $CanvasLayer/ScoreClip/ScoreHBox/StatsPanel/StatsHBox/LevelStat/ValueLabel
@onready var pause_overlay: Control = $CanvasLayer/UI/PauseOverlay
@onready var pause_backdrop: ColorRect = $CanvasLayer/UI/PauseOverlay/Backdrop
@onready var pause_panel: PanelContainer = $CanvasLayer/UI/PauseOverlay/CenterContainer/PausePanel
@onready var pause_title_label: Label = $CanvasLayer/UI/PauseOverlay/CenterContainer/PausePanel/VBox/TitleLabel
@onready var resume_button: Button = $CanvasLayer/UI/PauseOverlay/CenterContainer/PausePanel/VBox/ButtonColumn/ResumeButton
@onready var pause_reset_button: Button = $CanvasLayer/UI/PauseOverlay/CenterContainer/PausePanel/VBox/ButtonColumn/ResetButton
@onready var pause_main_menu_button: Button = $CanvasLayer/UI/PauseOverlay/CenterContainer/PausePanel/VBox/ButtonColumn/MainMenuButton
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
var hud_message_log: Array[Dictionary] = []
var score_message_batch: Array[String] = []
var is_message_queue_running: bool = false
var is_score_message_batch_open: bool = false
var hud_message_generation: int = 0
var message_tween: Tween
var puzzle_effect_tween: Tween
var base_score_position: Vector2 = Vector2.ZERO
var base_message_position: Vector2 = Vector2.ZERO
var puzzle_overlay_area_size: Vector2 = Vector2.ZERO
var default_theme_cache: ThemeData = null
var forced_sacrifice_spawn_count: int = 0

const TOP_BAR_SHADOW_HEIGHT: float = 5.0
const BOARD_TOP_GAP: float = 2.0
const MOVE_HINT_GAP: float = 8.0
const MOVE_HINT_HEIGHT: float = 58.0
const SCREEN_CONTENT_MARGIN: float = 6.0
const HUD_MARGIN_LEFT: float = 3.0
const HUD_MARGIN_TOP: float = 3.0
const HUD_MARGIN_GAP: float = 8.0
const PUZZLE_FRAME_INSET: float = 3.0
const PUZZLE_BADGE_WIDTH_RATIO: float = 0.66
const PUZZLE_BADGE_BORDER_OVERLAP: float = 8.0
const HUD_FRAME_HOVER_COLOR: Color = Color(0.96, 0.78, 0.38, 1.0)
const SCORE_FRAME_INSET_X: float = 5.0
const SCORE_FRAME_INSET_Y: float = 4.0
const SCORE_ROW_HEIGHT: float = 66.0
const SCORE_FRAME_EXTRA_SPACE: float = 0.0
const PUZZLE_COLUMNS: int = 5
const PUZZLE_ROWS: int = 5
const PUZZLE_LEVEL_TILE_COUNTS: Array[int] = [25, 50, 75, 100]
const PUZZLE_TILE_MARGIN: float = -1.0
const MESSAGE_SLIDE_DISTANCE: float = 120.0
const MESSAGE_SLIDE_IN_DURATION: float = 0.42
const MESSAGE_RECENT_WINDOW: float = 2.0
const MESSAGE_HOLD_DURATION: float = 2.0
const MESSAGE_SLIDE_OUT_DURATION: float = 0.38
const PUZZLE_IMAGE_PREVIEW_DURATION: float = 2.0
const PUZZLE_LEVEL_COMPLETE_HOLD: float = 3.0
const PUZZLE_IMAGE_FADE_DURATION: float = 0.5
const PUZZLE_TILE_UNROLL_DURATION: float = 0.45
const PUZZLE_TILE_UNROLL_STAGGER: float = 0.018
const PUZZLE_MESSAGE_BANNER_MIN_HEIGHT: float = 76.0
const PUZZLE_MESSAGE_BANNER_MAX_HEIGHT: float = 112.0
const PUZZLE_MESSAGE_BANNER_FLIGHT_DURATION: float = 0.96
const PUZZLE_MESSAGE_BANNER_HOLD_DURATION: float = 1.0
const TRAP_COUNTS_BY_LEVEL: Array[int] = [0, 1, 2]
const DEBUG_HUD_LAYOUT: bool = false

func _ready():
	GameManager.reset_game()
	_lock_mobile_orientation()
	apply_theme(_get_theme())
	_setup_signals()
	_apply_localized_text()
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

	screen_background.color = theme.gameplay_backdrop_base_color
	board_tint_overlay.color = Color.TRANSPARENT
	screen_gradient.texture = _build_screen_gradient_texture(theme)
	score_panel.color = Color(0.03, 0.07, 0.12, 0.0)
	score_shadow.color = theme.hud_shadow_color
	puzzle_panel.color = Color(0.06, 0.09, 0.13, 1.0)
	move_hint_panel.add_theme_stylebox_override("panel", _build_move_hint_panel_style(theme))
	move_hint_label.add_theme_color_override("font_color", theme.move_hint_text_color)
	move_hint_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.45))
	move_hint_label.add_theme_constant_override("outline_size", 2)
	move_hint_icon.set("icon_color", theme.move_hint_icon_color)
	message_panel.color = Color(0.03, 0.07, 0.12, 1.0)
	message_label.add_theme_color_override("font_color", theme.hud_primary_text_color)
	message_label.add_theme_color_override("font_outline_color", theme.hud_outline_color)
	message_label.add_theme_font_override("font", _build_dialog_font(theme.dialog_font_names, theme.puzzle_message_font_weight))
	message_label.add_theme_font_size_override("font_size", mini(theme.puzzle_message_font_size, 24))
	_apply_puzzle_banner_theme(theme)
	score_frame.add_theme_stylebox_override("panel", _build_gameplay_frame_style(theme))
	puzzle_frame.add_theme_stylebox_override("panel", _build_gameplay_frame_style(theme))
	if theme.checklines_badge_texture != null:
		puzzle_badge.texture = theme.checklines_badge_texture

	score_label.add_theme_color_override("font_color", theme.hud_primary_text_color)
	score_label.add_theme_color_override("font_outline_color", theme.hud_outline_color)
	high_score_label.add_theme_color_override("font_color", theme.hud_secondary_text_color)
	high_score_label.add_theme_color_override("font_outline_color", theme.hud_secondary_outline_color)
	color_lines_value_label.add_theme_color_override("font_color", theme.hud_primary_text_color)
	color_lines_value_label.add_theme_color_override("font_outline_color", theme.hud_secondary_outline_color)
	type_lines_value_label.add_theme_color_override("font_color", theme.hud_primary_text_color)
	type_lines_value_label.add_theme_color_override("font_outline_color", theme.hud_secondary_outline_color)
	level_value_label.add_theme_color_override("font_color", theme.hud_primary_text_color)
	level_value_label.add_theme_color_override("font_outline_color", theme.hud_secondary_outline_color)

	board_manager.apply_theme(theme)
	color_lines_badge.apply_theme(theme)
	type_lines_badge.apply_theme(theme)
	level_badge.apply_theme(theme)
	_apply_dialog_theme(theme)
	if _has_puzzle_levels():
		puzzle_image.texture = _get_puzzle_level_texture(current_puzzle_level)
		if puzzle_tile_order.size() == _get_total_puzzle_tiles():
			_refresh_puzzle_tiles()
	_update_layout()

func _apply_puzzle_banner_theme(theme: ThemeData):
	puzzle_flying_banner.banner_color = theme.puzzle_message_banner_color
	puzzle_flying_banner.banner_shadow_color = theme.puzzle_message_banner_shadow_color
	puzzle_flying_banner.banner_text_color = theme.puzzle_message_text_color
	puzzle_flying_banner.banner_text_outline_color = theme.puzzle_message_outline_color
	puzzle_flying_banner.banner_border_color = theme.gameplay_frame_color
	puzzle_flying_banner.render_scale = 2.5
	puzzle_flying_banner.font_height_ratio = 0.35
	puzzle_flying_banner.wind_strength = 15.0
	puzzle_flying_banner.wave_speed = 3.0
	puzzle_flying_banner.wave_frequency = 7.5
	puzzle_flying_banner.secondary_strength = 5.0
	puzzle_flying_banner.secondary_frequency = 18.0
	puzzle_flying_banner.edge_flutter_strength = 9.0
	puzzle_flying_banner.center_hold_duration = PUZZLE_MESSAGE_BANNER_HOLD_DURATION

func _apply_dialog_theme(theme):
	pause_backdrop.color = theme.dialog_overlay_color
	pause_panel.add_theme_stylebox_override(
		"panel",
		_build_dialog_panel_style(theme.dialog_panel_background_color, theme.dialog_panel_border_color)
	)
	game_over_backdrop.color = theme.dialog_overlay_color
	game_over_panel.add_theme_stylebox_override(
		"panel",
		_build_dialog_panel_style(theme.dialog_panel_background_color, theme.dialog_panel_border_color)
	)

	var title_font: SystemFont = _build_dialog_font(theme.dialog_font_names, theme.dialog_title_font_weight)
	var body_font: SystemFont = _build_dialog_font(theme.dialog_font_names, theme.dialog_body_font_weight)
	var button_font: SystemFont = _build_dialog_font(theme.dialog_font_names, theme.dialog_button_font_weight)

	_apply_dialog_label_style(
		pause_title_label,
		title_font,
		theme.dialog_title_font_size,
		theme.dialog_title_color
	)
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
		resume_button,
		button_font,
		theme.dialog_button_font_size,
		theme.dialog_button_primary_color,
		theme.dialog_button_primary_hover_color,
		theme.dialog_button_text_color
	)
	_apply_icon_button_style(
		gear_button,
		button_font,
		theme.dialog_button_font_size,
		theme.gameplay_frame_color,
		HUD_FRAME_HOVER_COLOR
	)
	_apply_dialog_button_style(
		pause_reset_button,
		button_font,
		theme.dialog_button_font_size,
		theme.dialog_button_secondary_color,
		theme.dialog_button_secondary_hover_color,
		theme.dialog_button_text_color,
		theme.dialog_button_secondary_border_color,
		theme.dialog_button_secondary_border_hover_color
	)
	_apply_dialog_button_style(
		pause_main_menu_button,
		button_font,
		theme.dialog_button_font_size,
		theme.dialog_button_secondary_color,
		theme.dialog_button_secondary_hover_color,
		theme.dialog_button_text_color,
		theme.dialog_button_secondary_border_color,
		theme.dialog_button_secondary_border_hover_color
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

func _build_move_hint_panel_style(theme: ThemeData) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = theme.move_hint_panel_color
	style.border_width_left = 0
	style.border_width_top = 0
	style.border_width_right = 0
	style.border_width_bottom = 0
	style.corner_radius_top_left = 0
	style.corner_radius_top_right = 0
	style.corner_radius_bottom_left = 0
	style.corner_radius_bottom_right = 0
	style.content_margin_left = 16.0
	style.content_margin_top = 10.0
	style.content_margin_right = 16.0
	style.content_margin_bottom = 10.0
	return style

func _apply_icon_button_style(
	button: Button,
	font: Font,
	font_size: int,
	normal_color: Color,
	hover_color: Color
):
	button.add_theme_font_override("font", font)
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("icon_normal_color", normal_color)
	button.add_theme_color_override("icon_hover_color", hover_color)
	button.add_theme_color_override("icon_pressed_color", hover_color)
	button.add_theme_color_override("icon_focus_color", hover_color)
	button.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	button.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	button.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

func _setup_signals():
	board_manager.piece_selected.connect(_on_piece_selected)
	board_manager.piece_deselected.connect(_on_piece_deselected)
	board_manager.capture_made.connect(_on_capture_made)
	board_manager.piece_moved.connect(_on_piece_moved)
	board_manager.piece_sacrificed.connect(_on_piece_sacrificed)
	GameManager.score_updated.connect(_on_score_updated)
	GameManager.line_metrics_updated.connect(_on_line_metrics_updated)
	GameManager.game_over.connect(_on_game_over)
	if not Settings.settings_changed.is_connected(_on_settings_changed):
		Settings.settings_changed.connect(_on_settings_changed)
	gear_button.pressed.connect(_on_gear_pressed)
	resume_button.pressed.connect(_on_resume_pressed)
	pause_reset_button.pressed.connect(_on_restart_pressed)
	pause_main_menu_button.pressed.connect(_on_main_menu_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	get_viewport().size_changed.connect(_on_viewport_size_changed)

func _on_viewport_size_changed():
	_update_layout()

func _update_layout():
	var viewport_size := get_viewport_rect().size
	_update_screen_backdrop(viewport_size)
	var top_bar_height: float = _update_top_hud_layout(viewport_size)
	var board_render_size: float = board_manager.get_rendered_pixel_size()
	var bottom_margin: float = HUD_MARGIN_TOP
	var hint_footprint := MOVE_HINT_GAP + MOVE_HINT_HEIGHT
	var available_height: float = maxf(viewport_size.y - top_bar_height - TOP_BAR_SHADOW_HEIGHT - BOARD_TOP_GAP - hint_footprint - bottom_margin, 120.0)
	var content_width: float = maxf(viewport_size.x - SCREEN_CONTENT_MARGIN * 2.0, 1.0)
	var width_scale: float = content_width / board_render_size
	var height_scale: float = available_height / board_render_size
	var scale_factor: float = maxf(minf(width_scale, height_scale), 0.1)
	var scaled_board_height: float = board_render_size * scale_factor
	var required_height: float = top_bar_height + TOP_BAR_SHADOW_HEIGHT + BOARD_TOP_GAP + scaled_board_height + hint_footprint + bottom_margin

	_ensure_window_height(required_height, viewport_size)

	viewport_size = get_viewport_rect().size
	board_render_size = board_manager.get_rendered_pixel_size()
	available_height = maxf(viewport_size.y - top_bar_height - TOP_BAR_SHADOW_HEIGHT - BOARD_TOP_GAP - hint_footprint - bottom_margin, 120.0)
	content_width = maxf(viewport_size.x - SCREEN_CONTENT_MARGIN * 2.0, 1.0)
	width_scale = content_width / board_render_size
	height_scale = available_height / board_render_size
	scale_factor = maxf(minf(width_scale, height_scale), 0.1)

	board_manager.scale = Vector2(scale_factor, scale_factor)

	var scaled_board_width: float = board_render_size * scale_factor
	scaled_board_height = board_render_size * scale_factor
	var board_x: float = (viewport_size.x - scaled_board_width) * 0.5
	var board_y: float = top_bar_height + TOP_BAR_SHADOW_HEIGHT + BOARD_TOP_GAP
	board_manager.position = Vector2(board_x, board_y)
	_update_move_hint_layout(board_x, board_y + scaled_board_height + MOVE_HINT_GAP, scaled_board_width)

func _update_move_hint_layout(board_x: float, hint_y: float, board_width: float):
	move_hint_panel.offset_left = board_x
	move_hint_panel.offset_top = hint_y
	move_hint_panel.offset_right = board_x + board_width
	move_hint_panel.offset_bottom = hint_y + MOVE_HINT_HEIGHT

func _update_screen_backdrop(viewport_size: Vector2):
	screen_background.position = Vector2.ZERO
	screen_background.size = viewport_size
	screen_background.z_index = -100

	screen_gradient.position = Vector2.ZERO
	screen_gradient.size = viewport_size
	screen_gradient.z_index = -95

	board_tint_overlay.position = Vector2.ZERO
	board_tint_overlay.size = viewport_size
	board_tint_overlay.z_index = -90

func _update_top_hud_layout(viewport_size: Vector2) -> float:
	var panel_margin: float = SCREEN_CONTENT_MARGIN + HUD_MARGIN_LEFT
	var panel_width: float = maxf(viewport_size.x - panel_margin * 2.0, 0.0)
	var puzzle_texture: Texture2D = _get_puzzle_level_texture(current_puzzle_level)
	var puzzle_height: float = 160.0
	if puzzle_texture != null and puzzle_texture.get_width() > 0:
		puzzle_height = panel_width * float(puzzle_texture.get_height()) / float(puzzle_texture.get_width())
	puzzle_height = clampf(puzzle_height, 120.0, 260.0)
	var badge_height: float = 0.0
	var badge_width: float = panel_width * PUZZLE_BADGE_WIDTH_RATIO
	if puzzle_badge.texture != null and puzzle_badge.texture.get_width() > 0:
		badge_height = badge_width * float(puzzle_badge.texture.get_height()) / float(puzzle_badge.texture.get_width())
	var gear_size: float = clampf(badge_height * 0.39, 28.0, 48.0)
	var header_height: float = maxf(badge_height, gear_size)
	var panel_top: float = HUD_MARGIN_TOP + maxf(header_height - PUZZLE_BADGE_BORDER_OVERLAP, 0.0)

	puzzle_panel.offset_left = panel_margin
	puzzle_panel.offset_top = panel_top
	puzzle_panel.offset_right = -panel_margin
	puzzle_panel.offset_bottom = panel_top + puzzle_height

	var badge_x: float = (viewport_size.x - badge_width) * 0.5
	puzzle_badge.offset_left = badge_x
	puzzle_badge.offset_top = HUD_MARGIN_TOP
	puzzle_badge.offset_right = badge_x + badge_width
	puzzle_badge.offset_bottom = HUD_MARGIN_TOP + badge_height

	var gear_center_x: float = panel_margin + maxf((badge_x - panel_margin) * 0.5, gear_size * 0.5)
	var gear_x: float = gear_center_x - gear_size * 0.5
	var gear_y: float = HUD_MARGIN_TOP + maxf((badge_height - gear_size) * 0.5, 0.0)
	gear_button.offset_left = gear_x
	gear_button.offset_top = gear_y
	gear_button.offset_right = gear_x + gear_size
	gear_button.offset_bottom = gear_y + gear_size

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
	_update_puzzle_overlay_banner_layout(panel_width, puzzle_height)

	var score_frame_top: float = puzzle_panel.offset_bottom + HUD_MARGIN_GAP
	var score_panel_height: float = SCORE_ROW_HEIGHT + SCORE_FRAME_INSET_Y * 2.0
	var score_frame_height: float = score_panel_height + SCORE_FRAME_EXTRA_SPACE
	var score_panel_top: float = score_frame_top

	var score_clip_left: float = panel_margin + SCORE_FRAME_INSET_X
	var score_clip_top: float = score_panel_top + SCORE_FRAME_INSET_Y
	var score_clip_width: float = maxf(viewport_size.x - score_clip_left * 2.0, 1.0)
	score_clip.offset_left = score_clip_left
	score_clip.offset_top = score_clip_top
	score_clip.offset_right = -score_clip_left
	score_clip.offset_bottom = score_clip_top + SCORE_ROW_HEIGHT

	score_hbox.offset_left = 0.0
	score_hbox.offset_top = 0.0
	score_hbox.offset_right = 0.0
	score_hbox.offset_bottom = SCORE_ROW_HEIGHT
	base_score_position = score_hbox.position

	score_panel.offset_left = panel_margin
	score_panel.offset_top = score_panel_top
	score_panel.offset_right = -panel_margin
	score_panel.offset_bottom = score_panel_top + score_panel_height

	score_frame.offset_left = panel_margin
	score_frame.offset_top = score_frame_top
	score_frame.offset_right = -panel_margin
	score_frame.offset_bottom = score_frame_top + score_frame_height

	score_shadow.offset_left = 0.0
	score_shadow.offset_right = 0.0
	score_shadow.offset_top = score_frame.offset_bottom
	score_shadow.offset_bottom = score_frame.offset_bottom + TOP_BAR_SHADOW_HEIGHT

	_update_message_layout(score_clip_width)
	_debug_hud_layout(viewport_size, panel_width, puzzle_height, puzzle_texture)
	return score_frame.offset_bottom

func _update_message_layout(score_clip_width: float):
	message_panel.offset_left = 0.0
	message_panel.offset_top = 0.0
	message_panel.offset_right = 0.0
	message_panel.offset_bottom = SCORE_ROW_HEIGHT
	message_panel.z_index = 19
	message_label.offset_left = 0.0
	message_label.offset_top = 0.0
	message_label.offset_right = 0.0
	message_label.offset_bottom = SCORE_ROW_HEIGHT
	message_label.z_index = 20
	base_message_position = message_label.position
	if not is_message_queue_running:
		var slide_distance := _get_message_slide_distance(score_clip_width)
		message_panel.position = base_message_position + Vector2(-slide_distance, 0.0)
		message_label.position = base_message_position + Vector2(-slide_distance, 0.0)
		score_hbox.position = base_score_position

func _update_puzzle_overlay_banner_layout(panel_width: float, puzzle_height: float):
	puzzle_overlay_area_size = Vector2(panel_width, puzzle_height)
	var banner_height := clampf(
		puzzle_height * 0.46,
		PUZZLE_MESSAGE_BANNER_MIN_HEIGHT,
		PUZZLE_MESSAGE_BANNER_MAX_HEIGHT
	)
	var banner_width := maxf(panel_width - PUZZLE_FRAME_INSET * 2.0, 1.0)
	puzzle_flying_banner.banner_size = Vector2(banner_width, banner_height)
	if not puzzle_flying_banner.visible:
		puzzle_flying_banner.position = _get_puzzle_overlay_start_position()

func _get_message_slide_distance(score_clip_width: float = 0.0) -> float:
	var measured_width := score_clip_width
	if measured_width <= 0.0:
		measured_width = score_clip.size.x
	return maxf(measured_width, MESSAGE_SLIDE_DISTANCE)

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
	_on_piece_deselected()
	board_manager.set_input_enabled(false)
	await _initialize_puzzle_progress()
	_spawn_initial_pieces()
	if not game_over_overlay.visible and not pause_overlay.visible and not is_processing_move:
		board_manager.set_input_enabled(true)

func _initialize_puzzle_progress():
	current_puzzle_level = 0
	revealed_puzzle_tiles = 0
	puzzle_tile_order.clear()
	hud_message_log.clear()
	score_message_batch.clear()
	is_message_queue_running = false
	is_score_message_batch_open = false
	hud_message_generation += 1
	if message_tween:
		message_tween.kill()
		message_tween = null
	if puzzle_effect_tween:
		puzzle_effect_tween.kill()
		puzzle_effect_tween = null
	message_label.text = ""
	message_label.modulate.a = 1.0
	puzzle_flying_banner.stop_banner()
	puzzle_image.modulate.a = 1.0
	message_panel.position = base_message_position + Vector2(-_get_message_slide_distance(), 0.0)
	message_label.position = base_message_position + Vector2(-_get_message_slide_distance(), 0.0)
	score_hbox.position = base_score_position
	await _load_puzzle_level(current_puzzle_level)

func _has_puzzle_levels() -> bool:
	return _get_puzzle_theme().puzzle_level_images.size() > 0

func _get_puzzle_level_texture(level_index: int) -> Texture2D:
	var theme: ThemeData = _get_puzzle_theme()
	if theme != null and not theme.puzzle_level_images.is_empty():
		var image_index := _get_puzzle_level_image_index(theme.puzzle_level_images, level_index)
		var level_texture: Texture2D = theme.puzzle_level_images[image_index]
		if level_texture != null:
			return level_texture
	return load("res://assets/ui/themes/default/level0.png") as Texture2D

static func _get_puzzle_level_image_index(puzzle_images: Array, level_index: int) -> int:
	if puzzle_images.is_empty():
		return 0
	if level_index >= 0 and level_index < puzzle_images.size() and puzzle_images[level_index] != null:
		return level_index
	for i in range(mini(level_index, puzzle_images.size() - 1), -1, -1):
		if puzzle_images[i] != null:
			return i
	return 0

static func _get_puzzle_level_tile_count(level_index: int) -> int:
	return PUZZLE_LEVEL_TILE_COUNTS[clampi(level_index, 0, PUZZLE_LEVEL_TILE_COUNTS.size() - 1)]

func _get_puzzle_theme() -> ThemeData:
	var theme: ThemeData = _get_theme()
	if theme != null and theme.puzzle_level_images.size() > 0:
		return theme
	return _get_default_theme()

func _get_default_theme() -> ThemeData:
	if default_theme_cache == null:
		default_theme_cache = load("res://themes/default_theme.tres") as ThemeData
	return default_theme_cache

func _build_gameplay_frame_style(theme: ThemeData) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.07, 0.1, 1.0)
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.border_color = theme.gameplay_frame_color
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.corner_detail = 1
	style.anti_aliasing = false
	if theme.gameplay_frame_glow_color.a > 0.0 and theme.gameplay_frame_glow_size > 0.0:
		style.shadow_color = theme.gameplay_frame_glow_color
		style.shadow_size = int(theme.gameplay_frame_glow_size)
		style.shadow_offset = Vector2.ZERO
	return style

func _build_screen_gradient_texture(theme: ThemeData) -> ImageTexture:
	var width := 96
	var height := 160
	var image := Image.create(width, height, false, Image.FORMAT_RGBA8)
	var base_color := theme.gameplay_backdrop_base_color
	var edge_glow_color := theme.gameplay_backdrop_edge_glow_color
	var center_glow_color := theme.gameplay_backdrop_center_glow_color

	for y in range(height):
		var v := float(y) / float(height - 1)
		var lower_focus := _smooth_peak(v, 0.68, 0.55)
		var top_focus := _smooth_peak(v, 0.08, 0.22)
		var vertical_fade := clampf(0.18 + lower_focus * 0.82 + top_focus * 0.26, 0.0, 1.0)

		for x in range(width):
			var u := float(x) / float(width - 1)
			var nearest_edge := minf(u, 1.0 - u)
			var edge_glow := pow(1.0 - smoothstep(0.0, 0.34, nearest_edge), 1.35) * vertical_fade
			var center_distance := absf(u - 0.5) * 2.0
			var center_glow := (1.0 - smoothstep(0.0, 0.95, center_distance)) * lower_focus * 0.42
			var bottom_shadow := smoothstep(0.72, 1.0, v) * 0.36
			var top_shadow := (1.0 - smoothstep(0.0, 0.18, v)) * 0.20

			var color := base_color
			color = color.lerp(edge_glow_color, clampf(edge_glow * 0.92, 0.0, 0.92))
			color = color.lerp(center_glow_color, clampf(center_glow, 0.0, 0.36))
			color = color.darkened(clampf(bottom_shadow + top_shadow, 0.0, 0.46))
			color.a = 1.0
			image.set_pixel(x, y, color)

	return ImageTexture.create_from_image(image)

func _smooth_peak(value: float, center: float, radius: float) -> float:
	return 1.0 - smoothstep(0.0, radius, absf(value - center))

func _load_puzzle_level(level_index: int):
	if not _has_puzzle_levels():
		puzzle_panel.visible = false
		return

	puzzle_panel.visible = true
	current_puzzle_level = maxi(level_index, 0)
	revealed_puzzle_tiles = 0
	puzzle_image.texture = _get_puzzle_level_texture(current_puzzle_level)
	puzzle_image.modulate.a = 1.0
	_update_line_metrics_ui()
	_generate_traps_for_level(current_puzzle_level)
	_build_puzzle_tile_order()
	_clear_puzzle_tiles()
	_update_layout()
	await _show_puzzle_overlay_message(_get_level_start_message(current_puzzle_level + 1), PUZZLE_IMAGE_PREVIEW_DURATION)
	await _refresh_puzzle_tiles(true)

func _get_level_start_message(level_number: int) -> String:
	var template: String = _get_puzzle_theme().level_start_message_template.strip_edges()
	if template.is_empty():
		return _tf("level_start_default", {"number": level_number})
	if template == "Let the fight begin!":
		return _t("level_start_default_theme")
	if template == "Let's shed some light on the dark.":
		return _t("level_start_neon_theme")
	return template.replace("{number}", str(level_number))

static func _get_trap_count_for_level(level_index: int) -> int:
	if level_index < 0:
		return 0
	if level_index < TRAP_COUNTS_BY_LEVEL.size():
		return TRAP_COUNTS_BY_LEVEL[level_index]
	return TRAP_COUNTS_BY_LEVEL[TRAP_COUNTS_BY_LEVEL.size() - 1]

func _generate_traps_for_level(level_index: int):
	board_manager.set_traps([])

	var trap_count := _get_trap_count_for_level(level_index)
	if trap_count <= 0:
		return

	var candidate_cells: Array = board_manager.get_empty_cells()
	if candidate_cells.is_empty():
		return

	candidate_cells.shuffle()
	var selected_cells: Array[Vector2i] = []
	for i in range(mini(trap_count, candidate_cells.size())):
		selected_cells.append(candidate_cells[i])
	board_manager.set_traps(selected_cells)

func _build_puzzle_tile_order():
	puzzle_tile_order.clear()
	for i in range(_get_total_puzzle_tiles()):
		puzzle_tile_order.append(i)
	puzzle_tile_order.shuffle()

func _get_total_puzzle_tiles() -> int:
	return _get_puzzle_level_tile_count(current_puzzle_level)

func _get_puzzle_columns() -> int:
	return ceili(float(_get_total_puzzle_tiles()) / float(PUZZLE_ROWS))

func _get_puzzle_rows() -> int:
	return PUZZLE_ROWS

func _clear_puzzle_tiles():
	for child in puzzle_tiles.get_children():
		child.queue_free()

func _refresh_puzzle_tiles(animate_unroll: bool = false):
	_clear_puzzle_tiles()

	if not _has_puzzle_levels():
		return

	var total_tiles: int = _get_total_puzzle_tiles()
	if puzzle_tile_order.size() != total_tiles:
		_build_puzzle_tile_order()

	var theme: ThemeData = _get_puzzle_theme()
	var puzzle_columns := _get_puzzle_columns()
	var puzzle_rows := _get_puzzle_rows()
	for order_index in range(revealed_puzzle_tiles, total_tiles):
		var tile_index: int = puzzle_tile_order[order_index]
		var tile := PuzzleTileCover.new()
		var column: int = tile_index % puzzle_columns
		var row: int = int(floor(float(tile_index) / float(puzzle_columns)))
		tile.anchor_left = float(column) / float(puzzle_columns)
		tile.anchor_top = float(row) / float(puzzle_rows)
		tile.anchor_right = float(column + 1) / float(puzzle_columns)
		tile.anchor_bottom = float(row + 1) / float(puzzle_rows)
		tile.offset_left = PUZZLE_TILE_MARGIN
		tile.offset_top = PUZZLE_TILE_MARGIN
		tile.offset_right = -PUZZLE_TILE_MARGIN
		tile.offset_bottom = -PUZZLE_TILE_MARGIN
		tile.setup(column, row, puzzle_columns, puzzle_rows, theme.puzzle_tile_cover_color)
		if animate_unroll:
			tile.scale = Vector2(1.0, 0.0)
			tile.pivot_offset = Vector2.ZERO
			tile.modulate.a = 0.0
		puzzle_tiles.add_child(tile)

	if animate_unroll:
		await _animate_puzzle_tiles_unroll()

func _show_puzzle_overlay_message(text: String, _hold_duration: float):
	if text.is_empty():
		return

	if puzzle_effect_tween:
		puzzle_effect_tween.kill()
		puzzle_effect_tween = null

	var from := _get_puzzle_overlay_start_position()
	var to := _get_puzzle_overlay_end_position()
	await puzzle_flying_banner.show_banner(text, from, to, PUZZLE_MESSAGE_BANNER_FLIGHT_DURATION)

func _get_puzzle_overlay_start_position() -> Vector2:
	var banner_size := puzzle_flying_banner.banner_size
	var center_y := puzzle_overlay_area_size.y * 0.5
	return Vector2(-banner_size.x * 0.55 - PUZZLE_FRAME_INSET, center_y)

func _get_puzzle_overlay_end_position() -> Vector2:
	var banner_size := puzzle_flying_banner.banner_size
	var center_y := puzzle_overlay_area_size.y * 0.5
	return Vector2(puzzle_overlay_area_size.x + banner_size.x * 0.55 + PUZZLE_FRAME_INSET, center_y)

func _animate_puzzle_tiles_unroll():
	var covers: Array = puzzle_tiles.get_children()
	if covers.is_empty():
		return

	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	for i in range(covers.size()):
		var cover: Control = covers[i]
		var delay := float(i) * PUZZLE_TILE_UNROLL_STAGGER
		tween.tween_property(cover, "scale:y", 1.0, PUZZLE_TILE_UNROLL_DURATION).set_delay(delay)
		tween.tween_property(cover, "modulate:a", 1.0, PUZZLE_TILE_UNROLL_DURATION * 0.7).set_delay(delay)
	await tween.finished

func _fade_puzzle_image_out():
	if puzzle_effect_tween:
		puzzle_effect_tween.kill()
		puzzle_effect_tween = null

	puzzle_effect_tween = create_tween()
	puzzle_effect_tween.tween_property(puzzle_image, "modulate:a", 0.0, PUZZLE_IMAGE_FADE_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	await puzzle_effect_tween.finished
	puzzle_effect_tween = null

func _apply_puzzle_progress(removed_pieces: int):
	if removed_pieces <= 0 or not _has_puzzle_levels():
		return

	var remaining := removed_pieces
	while remaining > 0:
		var tiles_left := _get_total_puzzle_tiles() - revealed_puzzle_tiles
		if remaining < tiles_left:
			revealed_puzzle_tiles += remaining
			remaining = 0
			_refresh_puzzle_tiles()
			return

		revealed_puzzle_tiles = _get_total_puzzle_tiles()
		remaining -= tiles_left
		_refresh_puzzle_tiles()
		var completed_level_number := current_puzzle_level + 1
		var level_complete_message := _tf("level_complete", {"number": completed_level_number})
		_queue_scoring_event(GameManager.build_level_complete_event(completed_level_number))
		await _show_puzzle_overlay_message(level_complete_message, PUZZLE_LEVEL_COMPLETE_HOLD)
		await _fade_puzzle_image_out()

		await _load_puzzle_level(current_puzzle_level + 1)

func _queue_message(text: String):
	if text.is_empty():
		return

	_append_hud_message(text)
	_show_hud_message_log()

func _append_hud_message(text: String):
	var now := Time.get_ticks_msec() / 1000.0
	var recent_messages: Array[Dictionary] = []
	for entry in hud_message_log:
		if now - float(entry.get("time", 0.0)) <= MESSAGE_RECENT_WINDOW:
			recent_messages.append(entry)
	recent_messages.append({
		"text": text,
		"time": now
	})
	while recent_messages.size() > 2:
		recent_messages.pop_front()
	hud_message_log = recent_messages

func _get_hud_message_log_text() -> String:
	var lines := PackedStringArray()
	for entry in hud_message_log:
		lines.append(str(entry.get("text", "")))
	return "\n".join(lines)

func _queue_scoring_event(event: Dictionary):
	if event.is_empty():
		return

	var value := int(event.get("value", 0))
	var display_only := bool(event.get("display_only", false))
	if value == 0 and not display_only:
		return

	if not display_only:
		GameManager.add_scoring_event(event)
	var formatted_event := GameManager.format_scoring_event(event)
	if is_score_message_batch_open:
		score_message_batch.append(formatted_event)
		_queue_message(formatted_event)
	else:
		_queue_message(formatted_event)

func _begin_score_message_batch():
	if is_score_message_batch_open:
		return

	score_message_batch.clear()
	is_score_message_batch_open = true

func _flush_score_message_batch():
	if not is_score_message_batch_open:
		return

	is_score_message_batch_open = false
	if score_message_batch.is_empty():
		return
	score_message_batch.clear()

func _show_hud_message_log():
	var text := _get_hud_message_log_text()
	if text.is_empty():
		return

	hud_message_generation += 1
	var generation := hud_message_generation
	is_message_queue_running = true
	var slide_distance := _get_message_slide_distance()
	message_label.text = text
	message_label.modulate.a = 1.0
	if message_tween:
		message_tween.kill()
		message_tween = null

	if message_label.position.x != base_message_position.x:
		message_panel.position = base_message_position + Vector2(-slide_distance, 0.0)
		message_label.position = base_message_position + Vector2(-slide_distance, 0.0)
		score_hbox.position = base_score_position
		message_tween = create_tween()
		message_tween.set_parallel(true)
		message_tween.set_trans(Tween.TRANS_QUAD)
		message_tween.set_ease(Tween.EASE_OUT)
		message_tween.tween_property(message_label, "position:x", base_message_position.x, MESSAGE_SLIDE_IN_DURATION)
		message_tween.tween_property(message_panel, "position:x", base_message_position.x, MESSAGE_SLIDE_IN_DURATION)
		message_tween.tween_property(score_hbox, "position:x", base_score_position.x + slide_distance, MESSAGE_SLIDE_IN_DURATION)
		message_tween.finished.connect(_start_hud_message_hold.bind(generation))
	else:
		message_panel.position = base_message_position
		message_label.position = base_message_position
		score_hbox.position = base_score_position + Vector2(slide_distance, 0.0)
		_start_hud_message_hold(generation)

func _start_hud_message_hold(generation: int):
	if generation != hud_message_generation:
		return
	message_tween = null
	var timer := get_tree().create_timer(MESSAGE_HOLD_DURATION)
	timer.timeout.connect(_slide_hud_message_out.bind(generation))

func _slide_hud_message_out(generation: int):
	if generation != hud_message_generation:
		return

	var slide_distance := _get_message_slide_distance()
	if message_tween:
		message_tween.kill()
	message_tween = create_tween()
	message_tween.set_parallel(true)
	message_tween.set_trans(Tween.TRANS_QUAD)
	message_tween.set_ease(Tween.EASE_IN)
	message_tween.tween_property(message_label, "position:x", base_message_position.x + slide_distance, MESSAGE_SLIDE_OUT_DURATION)
	message_tween.tween_property(message_panel, "position:x", base_message_position.x + slide_distance, MESSAGE_SLIDE_OUT_DURATION)
	message_tween.tween_property(score_hbox, "position:x", base_score_position.x, MESSAGE_SLIDE_OUT_DURATION)
	message_tween.finished.connect(_clear_hud_message_log_after_slide.bind(generation, slide_distance))

func _clear_hud_message_log_after_slide(generation: int, slide_distance: float):
	if generation != hud_message_generation:
		return

	message_label.text = ""
	message_panel.position = base_message_position + Vector2(-slide_distance, 0.0)
	message_label.position = base_message_position + Vector2(-slide_distance, 0.0)
	score_hbox.position = base_score_position
	is_message_queue_running = false
	message_tween = null

func _check_game_over():
	if not board_manager.has_legal_moves() or not board_manager.can_spawn_any_piece():
		GameManager.end_game()

func _on_piece_selected(piece):
	var moves: Array = piece.get_legal_moves(board_manager.board)
	var captures: Array = piece.get_legal_captures(board_manager.board)
	var piece_name := GameManager.get_piece_type_name(int(piece.piece_type))
	var move_count := moves.size()
	var capture_count := captures.size()
	if move_count <= 0 and capture_count <= 0:
		move_hint_label.text = _tf("move_hint_blocked", {"piece": piece_name})
	elif capture_count <= 0:
		move_hint_label.text = _tf("move_hint_move_only", {
			"piece": piece_name,
			"moves": _get_move_hint_count_text(move_count, "move_hint_move_one", "move_hint_move_many")
		})
	elif move_count <= 0:
		move_hint_label.text = _tf("move_hint_attack_only", {
			"piece": piece_name,
			"attacks": _get_move_hint_count_text(capture_count, "move_hint_attack_one", "move_hint_attack_many")
		})
	else:
		move_hint_label.text = _tf("move_hint_move_attack", {
			"piece": piece_name,
			"moves": _get_move_hint_count_text(move_count, "move_hint_move_one", "move_hint_move_many"),
			"attacks": _get_move_hint_count_text(capture_count, "move_hint_attack_one", "move_hint_attack_many")
		})
	move_hint_panel.visible = true

func _get_move_hint_count_text(count: int, one_key: String, many_key: String) -> String:
	if count == 1:
		return _t(one_key)
	return _tf(many_key, {"count": count})

func _on_piece_deselected():
	move_hint_panel.visible = false
	move_hint_label.text = ""

func _spawn_initial_pieces():
	var piece_count = 3
	
	for i in range(piece_count):
		var spawn_data: Dictionary = board_manager.get_random_spawn_piece_data()
		if spawn_data.is_empty():
			break
		if not board_manager.spawn_piece_with_preferred_placement(spawn_data):
			break

func _on_capture_made(_piece, _target, captured_piece_type: int):
	AudioManager.play_sound("capture")
	AudioManager.vibrate()
	_begin_score_message_batch()
	_queue_scoring_event(GameManager.build_sacrifice_event(captured_piece_type))

func _on_piece_sacrificed(_from: Vector2i, _to: Vector2i, piece_type: int):
	if is_processing_move:
		return

	AudioManager.play_sound("capture")
	AudioManager.vibrate()
	var theme := _get_theme()
	var message_template := ""
	if theme != null:
		message_template = theme.trap_disappearance_message_template
	if message_template == "I fell for nothing -{cost} :(":
		message_template = _t("trap_disappeared")
	elif message_template == "Dark is the new light... :( -{cost}":
		message_template = _t("trap_disappeared")
	_begin_score_message_batch()
	_queue_scoring_event(GameManager.build_trap_disappearance_event(piece_type, message_template))
	_resolve_sacrifice_turn()

func _on_piece_moved(_from, _to):
	if is_processing_move:
		return
	_resolve_turn()

func _on_score_updated(_new_score: int):
	_update_ui()

func _on_line_metrics_updated(_color_lines: int, _type_lines: int):
	_update_line_metrics_ui()

func _on_settings_changed():
	_apply_localized_text()
	_update_ui()

func _update_ui():
	score_label.text = "%s: %d" % [_t("score"), GameManager.current_score]
	high_score_label.text = "%s: %d" % [_t("best"), GameManager.high_score]
	_update_line_metrics_ui()

func _update_line_metrics_ui():
	color_lines_value_label.text = str(GameManager.color_lines_cleared)
	type_lines_value_label.text = str(GameManager.type_lines_cleared)
	level_value_label.text = str(current_puzzle_level + 1)

func _on_game_over(final_score: int):
	board_manager.set_input_enabled(false)
	pause_overlay.visible = false
	game_over_overlay.visible = true
	game_over_score_label.text = "%s: %d" % [_t("final_score"), final_score]
	AudioManager.play_sound("game_over")

func _on_gear_pressed():
	if game_over_overlay.visible:
		return

	pause_overlay.visible = true
	board_manager.set_input_enabled(false)

func _on_resume_pressed():
	pause_overlay.visible = false
	if not is_processing_move and not game_over_overlay.visible:
		board_manager.set_input_enabled(true)

func _on_restart_pressed():
	pause_overlay.visible = false
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
	_begin_score_message_batch()
	await get_tree().create_timer(0.3).timeout

	var cleared_from_move := await _resolve_chain_waves()
	if not cleared_from_move:
		var spawned_count: int = _spawn_new_pieces()
		if spawned_count == 0:
			board_manager.fill_empty_cells_with_kings()
			_check_game_over()
			_flush_score_message_batch()
			is_processing_move = false
			return
		await get_tree().create_timer(0.3).timeout
		await _resolve_chain_waves()

	await get_tree().create_timer(0.3).timeout
	_check_game_over()

	_flush_score_message_batch()
	is_processing_move = false
	if not game_over_overlay.visible and not pause_overlay.visible:
		board_manager.set_input_enabled(true)

func _resolve_sacrifice_turn():
	is_processing_move = true
	board_manager.set_input_enabled(false)
	_begin_score_message_batch()
	await get_tree().create_timer(0.3).timeout

	var spawned_count: int = _spawn_new_pieces(_get_sacrifice_spawn_count())
	if spawned_count == 0:
		board_manager.fill_empty_cells_with_kings()
		_check_game_over()
		_flush_score_message_batch()
		is_processing_move = false
		return

	await get_tree().create_timer(0.3).timeout
	await _resolve_chain_waves()
	await get_tree().create_timer(0.3).timeout
	_check_game_over()

	_flush_score_message_batch()
	is_processing_move = false
	if not game_over_overlay.visible and not pause_overlay.visible:
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
		_queue_scoring_event(GameManager.build_line_scoring_event(chain))
		GameManager.register_cleared_line(
			chain.get("is_color_line", false),
			chain.get("is_type_line", false)
		)

	await _apply_puzzle_progress(pieces_to_remove.size())

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

func _get_sacrifice_spawn_count() -> int:
	if forced_sacrifice_spawn_count > 0:
		return forced_sacrifice_spawn_count
	return 2 + randi_range(0, 1)

func _spawn_new_pieces(count: int = 3) -> int:
	return board_manager.spawn_random_pieces(count)

func _apply_localized_text():
	pause_title_label.text = _t("game_paused")
	resume_button.text = _t("resume")
	pause_reset_button.text = _t("reset")
	pause_main_menu_button.text = _t("main_menu")
	game_over_title_label.text = _t("game_over")
	game_over_summary_label.text = _t("session_complete")
	restart_button.text = _t("play_again")
	main_menu_button.text = _t("main_menu")
	if game_over_overlay.visible:
		game_over_score_label.text = "%s: %d" % [_t("final_score"), GameManager.current_score]

func _t(key: String) -> String:
	var localization := _get_localization()
	if localization != null and localization.has_method("t"):
		return localization.t(key)
	return key

func _tf(key: String, values: Dictionary) -> String:
	var localization := _get_localization()
	if localization != null and localization.has_method("tf"):
		return localization.tf(key, values)

	var text := _t(key)
	for value_key in values.keys():
		text = text.replace("{" + str(value_key) + "}", str(values[value_key]))
	return text

func _get_localization() -> Node:
	var main_loop := Engine.get_main_loop()
	if main_loop is SceneTree:
		return main_loop.root.get_node_or_null("Localization")
	return null
