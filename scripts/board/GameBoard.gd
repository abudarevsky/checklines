extends Node2D

const BoardStateRulesScript = preload("res://scripts/board/BoardStateRules.gd")
const TrapLineDetectorScript = preload("res://scripts/traps/TrapLineDetector.gd")
const SurvivalBloodOverlayScript = preload("res://scripts/effects/SurvivalBloodOverlay.gd")

@onready var board_manager = $BoardManager
@onready var screen_background: ColorRect = $ScreenBackground
@onready var screen_gradient: TextureRect = $ScreenGradient
@onready var board_background: TextureRect = $BoardBackground
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
@onready var current_score_digits: HBoxContainer = $CanvasLayer/ScoreClip/ScoreHBox/CurrentScoreStat/DigitCounter
@onready var high_score_badge: LineMetricBadge = $CanvasLayer/ScoreClip/ScoreHBox/BestScoreStat/Badge
@onready var high_score_label: Label = $CanvasLayer/ScoreClip/ScoreHBox/BestScoreStat/ValueLabel
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
@onready var survive_button: Button = $CanvasLayer/UI/GameOverOverlay/CenterContainer/GameOverPanel/VBox/ButtonsRow/SurviveButton
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
var session_total_turns: int = 0
var session_clean_turns: int = 0
var current_turn_had_take: bool = false
var trap_rotations_used_current_level: int = 0
var latest_game_result: String = GameManager.GAME_RESULT_LOSS
var latest_best_score_achieved: bool = false
var big_swamp_pulse_state = null
var is_big_swamp_pulse_resolving: bool = false
var is_game_state_ready: bool = false
var is_survival_mode: bool = false
var survival_round_index: int = 0
var survived_rounds: int = 0
var is_final_survival_dialog: bool = false
var survival_round_started_this_turn: bool = false
var survival_blood_overlay: Control = null
var pending_kingdom_completion_win: bool = false
var pending_survival_round_completion: bool = false

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
const SCORE_DIGIT_SLOT_SIZE: Vector2 = Vector2(24.0, 30.0)
const SCORE_DIGIT_FONT_SIZE: int = 26
const SCORE_MIN_DIGITS: int = 5
const PUZZLE_COLUMNS: int = 5
const PUZZLE_ROWS: int = 5
const PUZZLE_LEVEL_TILE_COUNTS: Array[int] = [25, 50, 75, 100]
const WIN_LEVEL_NUMBER: int = 4
const SESSION_CAMPAIGNS_PLAYED: int = 0
const SURVIVAL_LEVEL_INDEX: int = WIN_LEVEL_NUMBER - 1
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
const DEFAULT_TRAP_PROFILE: Dictionary = {
	"trap_counts_by_level": [0, 1, 2, 3],
	"trap_rotation_enabled": false,
	"trap_rotation_limits_by_level": [0, 1, 2, -1],
	"trap_rotation_chances_by_level": [0, 0.18, 0.18, 0.3],
	"big_swamp_pulse_probabilities_by_level": [0, 0.20, 0.40, 1],
	"pulse_duration_seconds": 5.0,
	"failed_pulse_spawn_count": 2,
	"allow_king_target": false,
	"max_active_pulses": 1,
	"big_swamp_max_target_distance_cells": 1,
}
const TRAP_PROFILES_BY_KINGDOM: Dictionary = {
	"default": DEFAULT_TRAP_PROFILE,
	"neon": DEFAULT_TRAP_PROFILE,
}
const DEBUG_HUD_LAYOUT: bool = false

class BigSwampPulseState:
	var trap_cell: Vector2i = Vector2i(-1, -1)
	var target_piece_cell: Vector2i = Vector2i(-1, -1)
	var missing_line_cell: Vector2i = Vector2i(-1, -1)
	var candidate_line_cells: Array[Vector2i] = []
	var candidate: Dictionary = {}
	var remaining_time: float = 0.0
	var duration: float = 0.0
	var is_active: bool = false

	func start(pulse_candidate: Dictionary, pulse_duration: float):
		trap_cell = pulse_candidate.get("trap_cell", Vector2i(-1, -1))
		target_piece_cell = pulse_candidate.get("target_piece_cell", Vector2i(-1, -1))
		missing_line_cell = pulse_candidate.get("missing_line_cell", Vector2i(-1, -1))
		candidate_line_cells = []
		for cell in pulse_candidate.get("candidate_line_cells", []):
			candidate_line_cells.append(cell)
		candidate = pulse_candidate.duplicate(true)
		duration = maxf(pulse_duration, 0.01)
		remaining_time = duration
		is_active = true

	func clear():
		trap_cell = Vector2i(-1, -1)
		target_piece_cell = Vector2i(-1, -1)
		missing_line_cell = Vector2i(-1, -1)
		candidate_line_cells.clear()
		candidate.clear()
		remaining_time = 0.0
		duration = 0.0
		is_active = false

class TrapPredictionBlocker:
	var piece_color: int = -1
	var piece_type: int = GameManager.PieceType.KING
	var grid_position: Vector2i = Vector2i(-1, -1)

	func _init(color: int, pos: Vector2i):
		piece_color = color
		piece_type = GameManager.PieceType.KING
		grid_position = pos

func _ready():
	big_swamp_pulse_state = BigSwampPulseState.new()
	GameManager.reset_game()
	_lock_mobile_orientation()
	_ensure_survival_blood_overlay()
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

func _ensure_survival_blood_overlay():
	if survival_blood_overlay != null:
		return
	survival_blood_overlay = SurvivalBloodOverlayScript.new()
	survival_blood_overlay.name = "SurvivalBloodOverlay"
	survival_blood_overlay.visible = false
	survival_blood_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	survival_blood_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	puzzle_panel.add_child(survival_blood_overlay)
	puzzle_panel.move_child(survival_blood_overlay, puzzle_panel.get_child_count() - 1)

func apply_theme(theme: ThemeData):
	if theme == null:
		return

	screen_background.color = theme.gameplay_backdrop_base_color
	board_tint_overlay.color = Color.TRANSPARENT
	screen_gradient.texture = _build_screen_gradient_texture(theme)
	screen_gradient.visible = theme.gameplay_background_texture == null
	board_background.texture = theme.gameplay_background_texture
	board_background.visible = theme.gameplay_background_texture != null
	board_background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	score_panel.color = theme.hud_panel_color
	score_shadow.color = theme.hud_shadow_color
	puzzle_panel.color = Color(0.06, 0.09, 0.13, 1.0)
	move_hint_panel.add_theme_stylebox_override("panel", _build_move_hint_panel_style(theme))
	move_hint_label.add_theme_color_override("font_color", theme.move_hint_text_color)
	move_hint_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.45))
	move_hint_label.add_theme_constant_override("outline_size", 2)
	move_hint_icon.set("icon_color", theme.move_hint_icon_color)
	message_panel.color = theme.hud_panel_color
	message_label.add_theme_color_override("font_color", theme.hud_primary_text_color)
	message_label.add_theme_color_override("font_outline_color", theme.hud_outline_color)
	message_label.add_theme_font_override("font", _build_dialog_font(theme.menu_body_font_path, theme.dialog_font_names, theme.puzzle_message_font_weight))
	message_label.add_theme_font_size_override("font_size", mini(theme.puzzle_message_font_size, 24))
	_apply_puzzle_banner_theme(theme)
	score_frame.add_theme_stylebox_override("panel", _build_gameplay_frame_style(theme))
	puzzle_frame.add_theme_stylebox_override("panel", _build_gameplay_frame_style(theme))
	if theme.checklines_badge_texture != null:
		puzzle_badge.texture = theme.checklines_badge_texture

	_apply_current_score_digit_theme(theme)
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
	high_score_badge.apply_theme(theme)
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
	puzzle_flying_banner.banner_font = _build_dialog_font(theme.banner_font_path, theme.dialog_font_names, theme.puzzle_message_font_weight)
	puzzle_flying_banner.render_scale = 2.5
	puzzle_flying_banner.font_height_ratio = 0.35
	puzzle_flying_banner.wind_strength = 15.0
	puzzle_flying_banner.wave_speed = 3.0
	puzzle_flying_banner.wave_frequency = 7.5
	puzzle_flying_banner.secondary_strength = 5.0
	puzzle_flying_banner.secondary_frequency = 18.0
	puzzle_flying_banner.edge_flutter_strength = 9.0
	puzzle_flying_banner.center_hold_duration = PUZZLE_MESSAGE_BANNER_HOLD_DURATION
	puzzle_flying_banner.width_scale = 0.8

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

	var title_font: Font = _build_dialog_font(theme.menu_title_font_path, theme.dialog_font_names, theme.dialog_title_font_weight)
	var body_font: Font = _build_dialog_font(theme.menu_body_font_path, theme.dialog_font_names, theme.dialog_body_font_weight)
	var button_font: Font = _build_dialog_font(theme.menu_button_font_path, theme.dialog_font_names, theme.dialog_button_font_weight)

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
		survive_button,
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
func _build_dialog_font(theme_font_path: String, font_names: PackedStringArray, font_weight: int) -> Font:
	var theme_font := _load_font_file(theme_font_path)
	if theme_font != null:
		return theme_font
	var font := SystemFont.new()
	font.font_names = font_names
	font.font_weight = font_weight
	return font

func _load_font_file(font_path: String) -> FontFile:
	if font_path.strip_edges().is_empty():
		return null
	var font := FontFile.new()
	if font.load_dynamic_font(font_path) != OK:
		return null
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

func _build_score_digit_slot_style(theme: ThemeData) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color.TRANSPARENT
	style.border_color = theme.hud_primary_text_color
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_left = 5
	style.corner_radius_bottom_right = 5
	style.content_margin_left = 5.0
	style.content_margin_top = 0.0
	style.content_margin_right = 5.0
	style.content_margin_bottom = 0.0
	return style

func _apply_current_score_digit_theme(theme: ThemeData):
	for child in current_score_digits.get_children():
		if child is PanelContainer:
			child.add_theme_stylebox_override("panel", _build_score_digit_slot_style(theme))
			var digit_label := child.get_node_or_null("DigitLabel") as Label
			if digit_label != null:
				digit_label.add_theme_color_override("font_color", theme.hud_primary_text_color)
				digit_label.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
				digit_label.add_theme_font_size_override("font_size", SCORE_DIGIT_FONT_SIZE)

func _update_current_score_digits(value: int):
	var theme := _get_theme()
	for child in current_score_digits.get_children():
		current_score_digits.remove_child(child)
		child.queue_free()

	var score_text := str(maxi(value, 0)).pad_zeros(SCORE_MIN_DIGITS)
	for i in range(score_text.length()):
		var character := score_text.substr(i, 1)
		var digit_panel := PanelContainer.new()
		digit_panel.name = "DigitPlate"
		digit_panel.custom_minimum_size = SCORE_DIGIT_SLOT_SIZE
		digit_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		if theme != null:
			digit_panel.add_theme_stylebox_override("panel", _build_score_digit_slot_style(theme))

		var digit_label := Label.new()
		digit_label.name = "DigitLabel"
		digit_label.text = character
		digit_label.custom_minimum_size = Vector2(10.0, 0.0)
		digit_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		digit_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		digit_label.add_theme_constant_override("outline_size", 0)
		digit_label.add_theme_font_size_override("font_size", SCORE_DIGIT_FONT_SIZE)
		if theme != null:
			digit_label.add_theme_color_override("font_color", theme.hud_primary_text_color)
			digit_label.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		digit_panel.add_child(digit_label)
		current_score_digits.add_child(digit_panel)

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
	board_manager.trap_selected.connect(_on_trap_selected)
	board_manager.trap_deselected.connect(_on_trap_deselected)
	board_manager.capture_made.connect(_on_capture_made)
	board_manager.piece_moved.connect(_on_piece_moved)
	board_manager.piece_sacrificed.connect(_on_piece_sacrificed)
	GameManager.score_updated.connect(_on_score_updated)
	GameManager.line_metrics_updated.connect(_on_line_metrics_updated)
	GameManager.game_over.connect(_on_game_over)
	var theme_manager := _get_theme_manager()
	if theme_manager != null and not theme_manager.theme_changed.is_connected(_on_theme_changed):
		theme_manager.theme_changed.connect(_on_theme_changed)
	if not Settings.settings_changed.is_connected(_on_settings_changed):
		Settings.settings_changed.connect(_on_settings_changed)
	gear_button.pressed.connect(_on_gear_pressed)
	resume_button.pressed.connect(_on_resume_pressed)
	pause_reset_button.pressed.connect(_on_reset_pressed)
	pause_main_menu_button.pressed.connect(_on_main_menu_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	survive_button.pressed.connect(_on_survive_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	get_viewport().size_changed.connect(_on_viewport_size_changed)

func _get_theme_manager() -> Node:
	var main_loop: MainLoop = Engine.get_main_loop()
	if main_loop is SceneTree:
		var root: Window = main_loop.root
		return root.get_node_or_null("ThemeManager")
	return null

func _on_viewport_size_changed():
	_update_layout()

func _update_layout():
	var viewport_size := get_viewport_rect().size
	_update_screen_backdrop(viewport_size)
	var top_bar_height: float = _update_top_hud_layout(viewport_size)
	var board_render_size: float = board_manager.get_rendered_pixel_size()
	var bottom_margin: float = HUD_MARGIN_TOP
	var hint_footprint := MOVE_HINT_GAP + MOVE_HINT_HEIGHT
	var content_margin_x: float = _get_horizontal_content_margin(viewport_size)
	var available_height: float = maxf(viewport_size.y - top_bar_height - TOP_BAR_SHADOW_HEIGHT - BOARD_TOP_GAP - hint_footprint - bottom_margin, 120.0)
	var content_width: float = maxf(viewport_size.x - content_margin_x * 2.0, 1.0)
	var width_scale: float = content_width / board_render_size
	var height_scale: float = available_height / board_render_size
	var scale_factor: float = maxf(minf(width_scale, height_scale), 0.1)
	var scaled_board_height: float = board_render_size * scale_factor
	var required_height: float = top_bar_height + TOP_BAR_SHADOW_HEIGHT + BOARD_TOP_GAP + scaled_board_height + hint_footprint + bottom_margin

	_ensure_window_height(required_height, viewport_size)

	viewport_size = get_viewport_rect().size
	board_render_size = board_manager.get_rendered_pixel_size()
	content_margin_x = _get_horizontal_content_margin(viewport_size)
	available_height = maxf(viewport_size.y - top_bar_height - TOP_BAR_SHADOW_HEIGHT - BOARD_TOP_GAP - hint_footprint - bottom_margin, 120.0)
	content_width = maxf(viewport_size.x - content_margin_x * 2.0, 1.0)
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
	_update_viewport_sized_control(screen_background, viewport_size)
	screen_background.z_index = -100

	_update_viewport_sized_control(screen_gradient, viewport_size)
	screen_gradient.z_index = -95

	_update_viewport_sized_control(board_background, viewport_size)
	board_background.z_index = -92

	_update_viewport_sized_control(board_tint_overlay, viewport_size)
	board_tint_overlay.z_index = -90

func _update_viewport_sized_control(control: Control, viewport_size: Vector2):
	control.anchor_left = 0.0
	control.anchor_top = 0.0
	control.anchor_right = 0.0
	control.anchor_bottom = 0.0
	control.position = Vector2.ZERO
	control.size = viewport_size

func _get_horizontal_content_margin(viewport_size: Vector2) -> float:
	var margin := SCREEN_CONTENT_MARGIN
	if viewport_size.y >= viewport_size.x:
		margin += GameManager.BOARD_INSET_X
	return margin

func _update_top_hud_layout(viewport_size: Vector2) -> float:
	var panel_margin: float = _get_horizontal_content_margin(viewport_size) + HUD_MARGIN_LEFT
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

func _process(delta: float):
	if big_swamp_pulse_state != null and big_swamp_pulse_state.is_active:
		_update_big_swamp_pulse(delta)
	elif is_game_state_ready and not is_processing_move and not game_over_overlay.visible and not pause_overlay.visible:
		_check_game_over()

func _initialize_game():
	is_game_state_ready = false
	board_manager.board_size = GameManager.board_size
	board_manager.clear_board()
	_on_piece_deselected()
	_on_trap_deselected()
	board_manager.set_input_enabled(false)
	await _initialize_puzzle_progress()
	_spawn_initial_pieces()
	is_game_state_ready = true
	_check_game_over()
	if not game_over_overlay.visible and not pause_overlay.visible and not is_processing_move:
		board_manager.set_input_enabled(true)

func _initialize_puzzle_progress():
	current_puzzle_level = Settings.get_kingdom_start_level_index(Settings.theme_id)
	revealed_puzzle_tiles = 0
	puzzle_tile_order.clear()
	hud_message_log.clear()
	score_message_batch.clear()
	is_message_queue_running = false
	is_score_message_batch_open = false
	hud_message_generation += 1
	_cancel_big_swamp_pulse(false)
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
		var image_index := ThemeData.get_puzzle_level_image_index(theme.puzzle_level_images, level_index)
		var level_texture: Texture2D = theme.puzzle_level_images[image_index]
		if level_texture != null:
			return level_texture
	return load("res://assets/ui/themes/default/level0.png") as Texture2D

static func _get_puzzle_level_image_index(puzzle_images: Array, level_index: int) -> int:
	return ThemeData.get_puzzle_level_image_index(puzzle_images, level_index)

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
	trap_rotations_used_current_level = 0
	_cancel_big_swamp_pulse(false)
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

static func _get_trap_profile(kingdom_id: String = "") -> Dictionary:
	var resolved_kingdom_id := kingdom_id.strip_edges()
	if resolved_kingdom_id.is_empty():
		resolved_kingdom_id = Settings.theme_id
	if TRAP_PROFILES_BY_KINGDOM.has(resolved_kingdom_id):
		return TRAP_PROFILES_BY_KINGDOM[resolved_kingdom_id]
	return DEFAULT_TRAP_PROFILE

static func _get_profile_level_int(profile: Dictionary, key: String, level_index: int, fallback: int = 0) -> int:
	if level_index < 0:
		return fallback
	var values: Array = profile.get(key, [])
	if values.is_empty():
		return fallback
	if level_index < values.size():
		return int(values[level_index])
	return int(values[values.size() - 1])

static func _get_profile_level_float(profile: Dictionary, key: String, level_index: int, fallback: float = 0.0) -> float:
	if level_index < 0:
		return fallback
	var values: Array = profile.get(key, [])
	if values.is_empty():
		return fallback
	var raw_value = values[level_index] if level_index < values.size() else values[values.size() - 1]
	return clampf(float(raw_value), 0.0, 1.0)

static func _get_trap_count_for_level(level_index: int, kingdom_id: String = "") -> int:
	return _get_profile_level_int(_get_trap_profile(kingdom_id), "trap_counts_by_level", level_index, 0)

static func _get_trap_rotation_limit_for_level(level_index: int, kingdom_id: String = "") -> int:
	return _get_profile_level_int(_get_trap_profile(kingdom_id), "trap_rotation_limits_by_level", level_index, 0)

static func _is_trap_rotation_enabled_for_kingdom(kingdom_id: String = "") -> bool:
	return bool(_get_trap_profile(kingdom_id).get("trap_rotation_enabled", false))

func _generate_traps_for_level(level_index: int, trap_count_override: int = -1):
	board_manager.set_traps([])

	var trap_count := trap_count_override if trap_count_override >= 0 else _get_trap_count_for_level(level_index)
	if trap_count <= 0:
		return

	var candidate_cells: Array = board_manager.get_empty_cells()
	if candidate_cells.is_empty():
		return

	candidate_cells.shuffle()
	var selected_cells: Array[Vector2i] = []
	for i in range(mini(trap_count, candidate_cells.size())):
		selected_cells.append(candidate_cells[i])

	var theme := _get_theme()
	var trap_type_id := ""
	if theme != null:
		trap_type_id = theme.trap_type_id
	board_manager.set_traps(selected_cells, trap_type_id)

func _get_survival_trap_count() -> int:
	return _get_trap_count_for_level(SURVIVAL_LEVEL_INDEX) + maxi(survival_round_index, 1)

func _get_survival_banner_text() -> String:
	var stars := ""
	for i in range(maxi(survival_round_index, 1)):
		stars += "*"
	return _tf("survival_banner", {"stars": stars})

func _start_survival_round():
	is_processing_move = true
	board_manager.set_input_enabled(false)
	game_over_overlay.visible = false
	is_final_survival_dialog = false
	is_survival_mode = true
	current_puzzle_level = SURVIVAL_LEVEL_INDEX
	revealed_puzzle_tiles = 0
	trap_rotations_used_current_level = 0
	_cancel_big_swamp_pulse(false)
	if survival_blood_overlay != null and survival_blood_overlay.has_method("start"):
		survival_blood_overlay.start()
	puzzle_panel.visible = true
	puzzle_image.texture = _get_puzzle_level_texture(current_puzzle_level)
	puzzle_image.modulate.a = 1.0
	_update_line_metrics_ui()
	_generate_traps_for_level(current_puzzle_level, _get_survival_trap_count())
	_build_puzzle_tile_order()
	_clear_puzzle_tiles()
	_update_layout()
	await _show_puzzle_overlay_message(_get_survival_banner_text(), PUZZLE_IMAGE_PREVIEW_DURATION)
	await _refresh_puzzle_tiles(true)
	is_processing_move = false
	_check_game_over()
	if not game_over_overlay.visible and not pause_overlay.visible:
		board_manager.set_input_enabled(true)

func _should_rotate_traps(level_index: int) -> bool:
	if not _is_trap_rotation_enabled_for_kingdom(Settings.theme_id):
		return false
	if not _can_rotate_traps_for_level(level_index):
		return false
	return randf() < _get_trap_rotation_chance_for_level(level_index)

func _can_rotate_traps_for_level(level_index: int) -> bool:
	var rotation_limit := _get_trap_rotation_limit_for_level(level_index)
	if rotation_limit == 0:
		return false
	if rotation_limit < 0:
		return true
	return trap_rotations_used_current_level < rotation_limit

static func _get_trap_rotation_chance_for_level(level_index: int, kingdom_id: String = "") -> float:
	return _get_profile_level_float(_get_trap_profile(kingdom_id), "trap_rotation_chances_by_level", level_index, 0.0)

static func _get_big_swamp_pulse_probability_for_level(level_index: int, kingdom_id: String = "") -> float:
	return _get_profile_level_float(_get_trap_profile(kingdom_id), "big_swamp_pulse_probabilities_by_level", level_index, 0.0)

static func _get_big_swamp_pulse_duration_seconds(kingdom_id: String = "") -> float:
	return maxf(float(_get_trap_profile(kingdom_id).get("pulse_duration_seconds", 5.0)), 0.01)

static func _get_failed_pulse_spawn_count(kingdom_id: String = "") -> int:
	return maxi(int(_get_trap_profile(kingdom_id).get("failed_pulse_spawn_count", 2)), 0)

static func _get_allow_king_target(kingdom_id: String = "") -> bool:
	return bool(_get_trap_profile(kingdom_id).get("allow_king_target", false))

static func _get_max_active_pulses(kingdom_id: String = "") -> int:
	return maxi(int(_get_trap_profile(kingdom_id).get("max_active_pulses", 1)), 0)

static func _get_big_swamp_max_target_distance_cells(kingdom_id: String = "") -> int:
	return maxi(int(_get_trap_profile(kingdom_id).get("big_swamp_max_target_distance_cells", 1)), 0)

func _maybe_rotate_traps():
	if not _should_rotate_traps(current_puzzle_level):
		return
	if big_swamp_pulse_state.is_active:
		return
	if _rotate_traps_to_empty_cells():
		trap_rotations_used_current_level += 1

func _rotate_traps_to_empty_cells() -> bool:
	var current_traps: Array = board_manager.traps.duplicate()
	if current_traps.is_empty():
		return false

	var candidate_cells: Array = board_manager.get_empty_cells()
	var selected_cells := _select_rotated_trap_cells(current_traps, candidate_cells)
	if selected_cells.is_empty():
		return false

	var trap_type_id := ""
	if current_traps.size() > 0:
		trap_type_id = board_manager.get_trap_type_id(current_traps[0])
	board_manager.set_traps_with_rotation(selected_cells, trap_type_id)
	return true

static func _select_rotated_trap_cells(current_traps: Array, candidate_cells: Array) -> Array[Vector2i]:
	if current_traps.is_empty() or candidate_cells.size() < current_traps.size():
		return []

	var shuffled_cells := candidate_cells.duplicate()
	shuffled_cells.shuffle()
	var selected_cells: Array[Vector2i] = []
	for cell in shuffled_cells:
		selected_cells.append(cell)
		if selected_cells.size() >= current_traps.size():
			break
	return selected_cells

func _maybe_start_big_swamp_pulse():
	var kingdom_id := Settings.theme_id
	if _get_max_active_pulses(kingdom_id) <= 0 or big_swamp_pulse_state.is_active or is_big_swamp_pulse_resolving:
		return
	if board_manager.traps.is_empty():
		return
	var pulse_probability := _get_big_swamp_pulse_probability_for_level(current_puzzle_level, kingdom_id)
	if pulse_probability <= 0.0 or randf() >= pulse_probability:
		return
	var swamp_traps := _get_big_swamp_trap_cells()
	if swamp_traps.is_empty():
		return
	var candidates := _find_big_swamp_pulse_candidates(
		board_manager.board,
		swamp_traps,
		_get_allow_king_target(kingdom_id),
		board_manager.traps,
		_get_big_swamp_max_target_distance_cells(kingdom_id)
	)
	if candidates.is_empty():
		return
	candidates.sort_custom(func(a: Dictionary, b: Dictionary): return int(a.get("score", 0)) > int(b.get("score", 0)))
	var top_score := int(candidates[0].get("score", 0))
	var best_candidates: Array = []
	for candidate in candidates:
		if int(candidate.get("score", 0)) == top_score:
			best_candidates.append(candidate)
	best_candidates.shuffle()
	_start_big_swamp_pulse(best_candidates[0])

func _get_big_swamp_trap_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for trap_cell in board_manager.traps:
		if board_manager.get_trap_type_id(trap_cell) == "swallow":
			cells.append(trap_cell)
	return cells

func _start_big_swamp_pulse(candidate: Dictionary):
	big_swamp_pulse_state.start(candidate, _get_big_swamp_pulse_duration_seconds(Settings.theme_id))
	var target_piece_color: int = -1
	if board_manager.board.has(big_swamp_pulse_state.target_piece_cell):
		target_piece_color = int(board_manager.board[big_swamp_pulse_state.target_piece_cell].piece_color)
	board_manager.start_big_swamp_pulse_visual(
		big_swamp_pulse_state.trap_cell,
		big_swamp_pulse_state.target_piece_cell,
		target_piece_color,
		big_swamp_pulse_state.candidate_line_cells
	)

func _update_big_swamp_pulse(delta: float):
	if is_big_swamp_pulse_resolving:
		return
	if _is_big_swamp_pulse_line_completed():
		_cancel_big_swamp_pulse(true)
		return
	if not _is_big_swamp_pulse_state_valid():
		_cancel_big_swamp_pulse(true)
		return
	big_swamp_pulse_state.remaining_time = maxf(big_swamp_pulse_state.remaining_time - delta, 0.0)
	var progress: float = 1.0 - (big_swamp_pulse_state.remaining_time / maxf(big_swamp_pulse_state.duration, 0.01))
	board_manager.update_big_swamp_pulse_visual(progress)
	if big_swamp_pulse_state.remaining_time <= 0.0 and not is_processing_move:
		_expire_big_swamp_pulse()

func _cancel_big_swamp_pulse(animate_retract: bool):
	if not big_swamp_pulse_state.is_active:
		return
	if animate_retract:
		board_manager.cancel_big_swamp_pulse_visual()
	else:
		board_manager.finish_big_swamp_pulse_visual()
	big_swamp_pulse_state.clear()

func _expire_big_swamp_pulse():
	if is_big_swamp_pulse_resolving or not big_swamp_pulse_state.is_active:
		return
	is_big_swamp_pulse_resolving = true
	if _is_big_swamp_pulse_line_completed() or not _is_big_swamp_pulse_state_valid():
		is_big_swamp_pulse_resolving = false
		_cancel_big_swamp_pulse(true)
		return
	is_processing_move = true
	board_manager.set_input_enabled(false)
	var trap_cell: Vector2i = big_swamp_pulse_state.trap_cell
	var target_cell: Vector2i = big_swamp_pulse_state.target_piece_cell
	var target_piece = _get_valid_big_swamp_target_piece()
	if target_piece == null:
		board_manager.finish_big_swamp_pulse_visual()
		big_swamp_pulse_state.clear()
		is_big_swamp_pulse_resolving = false
		is_processing_move = false
		if not game_over_overlay.visible and not pause_overlay.visible:
			board_manager.set_input_enabled(true)
		return
	var captured_piece_type: int = int(target_piece.piece_type)
	var captured_piece_color: int = int(target_piece.piece_color)
	await board_manager.animate_big_swamp_capture(trap_cell, target_cell)
	target_piece = _get_valid_big_swamp_target_piece()
	if target_piece != null:
		captured_piece_type = int(target_piece.piece_type)
		captured_piece_color = int(target_piece.piece_color)
		board_manager.remove_piece(target_cell)
		board_manager.finish_big_swamp_pulse_visual()
		var trap_data: Resource = board_manager.get_trap_data(trap_cell)
		var trap_name := _get_trap_display_name(trap_data)
		var trap_message := _build_trap_disappearance_message(captured_piece_type, trap_name)
		board_manager.show_trap_message_cloud(trap_cell, trap_message, _get_theme(), captured_piece_type, captured_piece_color)
		_spawn_new_pieces(_get_failed_pulse_spawn_count(Settings.theme_id))
		await get_tree().create_timer(0.2).timeout
		await _resolve_chain_waves()
	else:
		board_manager.finish_big_swamp_pulse_visual()
	big_swamp_pulse_state.clear()
	is_big_swamp_pulse_resolving = false
	is_processing_move = false
	if not game_over_overlay.visible:
		_check_game_over()
	if not game_over_overlay.visible and not pause_overlay.visible:
		board_manager.set_input_enabled(true)

func _get_valid_big_swamp_target_piece():
	if not big_swamp_pulse_state.is_active:
		return null
	var target_cell: Vector2i = big_swamp_pulse_state.target_piece_cell
	if not board_manager.board.has(target_cell):
		return null
	var piece = board_manager.board[target_cell]
	if not is_instance_valid(piece):
		return null
	var expected_type: int = int(big_swamp_pulse_state.candidate.get("target_piece_type", -1))
	var expected_color: int = int(big_swamp_pulse_state.candidate.get("target_piece_color", -1))
	if expected_type >= 0 and int(piece.piece_type) != expected_type:
		return null
	if expected_color >= 0 and int(piece.piece_color) != expected_color:
		return null
	return piece

func _is_big_swamp_pulse_state_valid() -> bool:
	if not big_swamp_pulse_state.is_active:
		return false
	if not (big_swamp_pulse_state.trap_cell in board_manager.traps):
		return false
	if board_manager.get_trap_type_id(big_swamp_pulse_state.trap_cell) != "swallow":
		return false
	if _get_valid_big_swamp_target_piece() == null:
		return false
	if not TrapLineDetectorScript.is_candidate_still_present(
		board_manager.board,
		_get_big_swamp_trap_cells(),
		big_swamp_pulse_state.candidate
	):
		return false
	return true

func _is_big_swamp_pulse_line_completed() -> bool:
	if not big_swamp_pulse_state.is_active:
		return false
	var completion_target: Vector2i = big_swamp_pulse_state.candidate.get("completion_target_cell", Vector2i(-1, -1))
	if completion_target == big_swamp_pulse_state.trap_cell:
		return false
	return _is_candidate_line_completed(
		board_manager.board,
		big_swamp_pulse_state.candidate_line_cells
	)

static func _find_big_swamp_pulse_candidates(board: Dictionary, trap_cells: Array, allow_king_capture: bool, blocked_trap_cells: Array = [], max_target_distance_cells: int = 1) -> Array:
	return TrapLineDetectorScript.detect_trap_lines(board, trap_cells, max_target_distance_cells, blocked_trap_cells)

static func _get_five_cell_windows(direction: Vector2i) -> Array:
	var windows: Array = []
	for y in range(GameManager.BOARD_SIZE):
		for x in range(GameManager.BOARD_SIZE):
			var start := Vector2i(x, y)
			var end := start + direction * (ChainDetector.MIN_LINE_LENGTH - 1)
			if not _is_grid_cell_in_bounds(end):
				continue
			var cells: Array[Vector2i] = []
			for i in range(ChainDetector.MIN_LINE_LENGTH):
				cells.append(start + direction * i)
			windows.append(cells)
	return windows

static func _build_big_swamp_pulse_candidates_for_line(board: Dictionary, trap_cells: Array, blocked_trap_cells: Array, line_cells: Array, direction: Vector2i, allow_king_capture: bool, max_target_distance_cells: int) -> Array:
	var candidates: Array = []
	if _is_candidate_line_completed(board, line_cells):
		return candidates

	for completion_cell in line_cells:
		var candidate_cell: Vector2i = completion_cell
		if candidate_cell in blocked_trap_cells:
			continue
		var occupied_pieces: Array = []
		var has_gap_outside_candidate := false
		for line_cell in line_cells:
			var current_cell: Vector2i = line_cell
			if current_cell == candidate_cell:
				continue
			if current_cell in blocked_trap_cells:
				has_gap_outside_candidate = true
				break
			if not board.has(current_cell):
				has_gap_outside_candidate = true
				break
			occupied_pieces.append(board[current_cell])
		if has_gap_outside_candidate or occupied_pieces.size() != ChainDetector.MIN_LINE_LENGTH - 1:
			continue
		var completion: Dictionary = _get_almost_line_completion(board, occupied_pieces, candidate_cell, line_cells, blocked_trap_cells)
		if completion.is_empty():
			continue
		var target_cell: Vector2i = _select_big_swamp_pulse_target(board, line_cells, candidate_cell, direction, trap_cells, allow_king_capture, max_target_distance_cells)
		if target_cell == Vector2i(-1, -1):
			continue
		var trap_cell: Vector2i = _select_big_swamp_pulse_trap(trap_cells, target_cell, max_target_distance_cells)
		if trap_cell == Vector2i(-1, -1):
			continue
		candidates.append({
			"trap_cell": trap_cell,
			"target_piece_cell": target_cell,
			"missing_line_cell": candidate_cell,
			"candidate_line_cells": line_cells.duplicate(),
			"score": _score_big_swamp_pulse_target(line_cells, candidate_cell, target_cell, direction, trap_cell)
		})

	return candidates

static func _get_almost_line_completion(board: Dictionary, occupied_pieces: Array, missing_cell: Vector2i, candidate_line_cells: Array, blocked_trap_cells: Array = []) -> Dictionary:
	var color_completer := _get_color_almost_line_completer(board, occupied_pieces, missing_cell, candidate_line_cells, blocked_trap_cells)
	if color_completer != Vector2i(-1, -1):
		return {"kind": "color"}
	var type_match: int = _get_almost_type_match(occupied_pieces)
	var type_completer := _get_type_almost_line_completer(board, occupied_pieces, missing_cell, candidate_line_cells, blocked_trap_cells, type_match, _has_king_piece(occupied_pieces))
	if type_completer != Vector2i(-1, -1):
		return {
			"kind": "type",
			"matched_type": type_match
		}
	return {}

static func _can_complete_color_almost_line(board: Dictionary, occupied_pieces: Array, missing_cell: Vector2i, candidate_line_cells: Array, blocked_trap_cells: Array) -> bool:
	var color: int = occupied_pieces[0].piece_color
	var occupied_line_cells: Dictionary = {}
	for piece in occupied_pieces:
		occupied_line_cells[piece.grid_position] = true
		if piece.piece_color != color:
			return false
	for piece in board.values():
		if occupied_line_cells.has(piece.grid_position):
			continue
		if piece.piece_color == color and _can_piece_complete_almost_line_cell(piece, board, missing_cell, candidate_line_cells, blocked_trap_cells):
			return true
	return false

static func _get_color_almost_line_completer(board: Dictionary, occupied_pieces: Array, missing_cell: Vector2i, candidate_line_cells: Array, blocked_trap_cells: Array) -> Vector2i:
	var color: int = occupied_pieces[0].piece_color
	var occupied_line_cells: Dictionary = {}
	for piece in occupied_pieces:
		occupied_line_cells[piece.grid_position] = true
		if piece.piece_color != color:
			return Vector2i(-1, -1)
	for piece in board.values():
		if occupied_line_cells.has(piece.grid_position):
			continue
		if piece.piece_color == color and _can_piece_complete_almost_line_cell(piece, board, missing_cell, candidate_line_cells, blocked_trap_cells):
			return piece.grid_position
	return Vector2i(-1, -1)

static func _get_almost_type_match(occupied_pieces: Array) -> int:
	var matched_type: int = -1
	for piece in occupied_pieces:
		if piece.piece_type == GameManager.PieceType.KING:
			continue
		if matched_type == -1:
			matched_type = piece.piece_type
			continue
		if piece.piece_type != matched_type:
			return -1
	return matched_type

static func _can_complete_type_almost_line(board: Dictionary, occupied_pieces: Array, missing_cell: Vector2i, candidate_line_cells: Array, blocked_trap_cells: Array, matched_type: int, line_has_king: bool) -> bool:
	if matched_type == -1:
		return false
	var occupied_line_cells: Dictionary = {}
	for piece in occupied_pieces:
		occupied_line_cells[piece.grid_position] = true
	for piece in board.values():
		if occupied_line_cells.has(piece.grid_position):
			continue
		if piece.piece_type == matched_type and _can_piece_complete_almost_line_cell(piece, board, missing_cell, candidate_line_cells, blocked_trap_cells):
			return true
		if not line_has_king and piece.piece_type == GameManager.PieceType.KING and _can_piece_complete_almost_line_cell(piece, board, missing_cell, candidate_line_cells, blocked_trap_cells):
			return true
	return false

static func _get_type_almost_line_completer(board: Dictionary, occupied_pieces: Array, missing_cell: Vector2i, candidate_line_cells: Array, blocked_trap_cells: Array, matched_type: int, line_has_king: bool) -> Vector2i:
	if matched_type == -1:
		return Vector2i(-1, -1)
	var occupied_line_cells: Dictionary = {}
	for piece in occupied_pieces:
		occupied_line_cells[piece.grid_position] = true
	for piece in board.values():
		if occupied_line_cells.has(piece.grid_position):
			continue
		if piece.piece_type == matched_type and _can_piece_complete_almost_line_cell(piece, board, missing_cell, candidate_line_cells, blocked_trap_cells):
			return piece.grid_position
		if not line_has_king and piece.piece_type == GameManager.PieceType.KING and _can_piece_complete_almost_line_cell(piece, board, missing_cell, candidate_line_cells, blocked_trap_cells):
			return piece.grid_position
	return Vector2i(-1, -1)

static func _can_piece_complete_almost_line_cell(piece, board: Dictionary, completion_cell: Vector2i, candidate_line_cells: Array, blocked_trap_cells: Array) -> bool:
	if completion_cell in blocked_trap_cells:
		return false
	var can_reach_completion: bool = false
	if board.has(completion_cell):
		can_reach_completion = completion_cell in piece.get_legal_captures(board)
	else:
		can_reach_completion = completion_cell in piece.get_legal_moves(board)
	if not can_reach_completion:
		return false
	return _simulated_completion_creates_candidate_line(piece, board, completion_cell, candidate_line_cells)

static func _build_prediction_movement_board(board: Dictionary, blocked_trap_cells: Array, completion_cell: Vector2i, blocker_color: int) -> Dictionary:
	var prediction_board := board.duplicate()
	for trap_cell in blocked_trap_cells:
		var blocked_cell: Vector2i = trap_cell
		if blocked_cell == completion_cell or prediction_board.has(blocked_cell):
			continue
		prediction_board[blocked_cell] = TrapPredictionBlocker.new(blocker_color, blocked_cell)
	return prediction_board

static func _free_prediction_movement_blockers(prediction_board: Dictionary, board: Dictionary, blocked_trap_cells: Array):
	for trap_cell in blocked_trap_cells:
		var blocked_cell: Vector2i = trap_cell
		if board.has(blocked_cell) or not prediction_board.has(blocked_cell):
			continue
		var blocker = prediction_board[blocked_cell]
		if blocker is Node and is_instance_valid(blocker):
			blocker.free()

static func _simulated_completion_creates_candidate_line(piece, board: Dictionary, completion_cell: Vector2i, candidate_line_cells: Array) -> bool:
	var original_cell: Vector2i = piece.grid_position
	var simulation_board := board.duplicate()
	simulation_board.erase(original_cell)
	simulation_board.erase(completion_cell)
	piece.grid_position = completion_cell
	simulation_board[completion_cell] = piece
	var completed := _is_candidate_line_completed(simulation_board, candidate_line_cells)
	piece.grid_position = original_cell
	return completed

static func _select_big_swamp_pulse_target(board: Dictionary, line_cells: Array, missing_cell: Vector2i, direction: Vector2i, trap_cells: Array, allow_king_capture: bool, max_target_distance_cells: int = 1) -> Vector2i:
	var best_cell: Vector2i = Vector2i(-1, -1)
	var best_score: int = -999999
	var best_trap_distance: int = 999999
	var reachable_targets: Array[Vector2i] = []
	for cell in line_cells:
		if cell == missing_cell or not board.has(cell):
			continue
		var piece = board[cell]
		if not allow_king_capture and piece.piece_type == GameManager.PieceType.KING:
			continue
		var target_cell: Vector2i = cell
		var trap_cell: Vector2i = _select_big_swamp_pulse_trap(trap_cells, target_cell, max_target_distance_cells)
		if trap_cell == Vector2i(-1, -1):
			continue
		if _is_valid_big_swamp_pulse_target_position(line_cells, missing_cell, target_cell, direction, board.has(missing_cell), trap_cell):
			reachable_targets.append(target_cell)

	for target_cell in reachable_targets:
		var trap_cell: Vector2i = _select_big_swamp_pulse_trap(trap_cells, target_cell, max_target_distance_cells)
		if trap_cell == Vector2i(-1, -1):
			continue
		var trap_distance: int = int(target_cell.distance_squared_to(trap_cell)) if trap_cell != Vector2i(-1, -1) else 999999
		var score: int = _score_big_swamp_pulse_target(line_cells, missing_cell, target_cell, direction, trap_cell)
		if trap_distance < best_trap_distance or (trap_distance == best_trap_distance and score > best_score):
			best_trap_distance = trap_distance
			best_score = score
			best_cell = target_cell
	return best_cell

static func _is_cell_adjacent_to_line_gap(cell: Vector2i, gap_cell: Vector2i, direction: Vector2i) -> bool:
	return cell == gap_cell - direction or cell == gap_cell + direction

static func _is_valid_big_swamp_pulse_target_position(line_cells: Array, missing_cell: Vector2i, target_cell: Vector2i, direction: Vector2i, completion_cell_is_occupied: bool, trap_cell: Vector2i = Vector2i(-1, -1)) -> bool:
	if _is_cell_adjacent_to_line_gap(target_cell, missing_cell, direction):
		return true
	var first_cell: Vector2i = line_cells[0]
	var last_cell: Vector2i = line_cells[line_cells.size() - 1]
	if target_cell != first_cell and target_cell != last_cell:
		return false
	if completion_cell_is_occupied:
		return _is_cell_orthogonally_adjacent(target_cell, trap_cell) or _is_trap_attached_to_line_edge(trap_cell, target_cell, direction, target_cell == first_cell)
	if target_cell == first_cell:
		return _is_trap_on_line_edge_extension(trap_cell, first_cell, direction, true)
	return _is_trap_on_line_edge_extension(trap_cell, last_cell, direction, false)

static func _is_cell_orthogonally_adjacent(cell: Vector2i, other_cell: Vector2i) -> bool:
	return absi(cell.x - other_cell.x) + absi(cell.y - other_cell.y) == 1

static func _is_trap_attached_to_line_edge(trap_cell: Vector2i, edge_cell: Vector2i, direction: Vector2i, is_first_edge: bool) -> bool:
	if trap_cell == Vector2i(-1, -1):
		return false
	if _is_trap_on_line_edge_extension(trap_cell, edge_cell, direction, is_first_edge):
		return true
	for perpendicular_offset in _get_line_perpendicular_offsets(direction):
		if trap_cell == edge_cell + perpendicular_offset:
			return true
	return false

static func _is_trap_on_line_edge_extension(trap_cell: Vector2i, edge_cell: Vector2i, direction: Vector2i, is_first_edge: bool) -> bool:
	if trap_cell == Vector2i(-1, -1):
		return false
	var edge_offset: Vector2i = edge_cell - direction if is_first_edge else edge_cell + direction
	return trap_cell == edge_offset

static func _get_line_perpendicular_offsets(direction: Vector2i) -> Array[Vector2i]:
	if direction.x != 0 and direction.y != 0:
		return [Vector2i(direction.x, -direction.y), Vector2i(-direction.x, direction.y)]
	if direction.x != 0:
		return [Vector2i(0, 1), Vector2i(0, -1)]
	return [Vector2i(1, 0), Vector2i(-1, 0)]

static func _score_big_swamp_pulse_target(line_cells: Array, missing_cell: Vector2i, target_cell: Vector2i, direction: Vector2i, trap_cell: Vector2i) -> int:
	var score: int = 0
	if _is_cell_adjacent_to_line_gap(target_cell, missing_cell, direction):
		score += 70
	if target_cell == line_cells[0] or target_cell == line_cells[line_cells.size() - 1]:
		score += 45
	score -= int(target_cell.distance_squared_to(missing_cell)) * 2
	if trap_cell != Vector2i(-1, -1):
		score -= int(target_cell.distance_squared_to(trap_cell))
	return score

static func _select_big_swamp_pulse_trap(trap_cells: Array, target_cell: Vector2i, max_target_distance_cells: int = 1) -> Vector2i:
	var selected: Vector2i = Vector2i(-1, -1)
	var best_distance: int = 999999
	for trap_cell in trap_cells:
		if not _is_cell_within_big_swamp_reach(target_cell, trap_cell, max_target_distance_cells):
			continue
		var distance: int = int(target_cell.distance_squared_to(trap_cell))
		if distance < best_distance:
			best_distance = distance
			selected = trap_cell
	return selected

static func _is_cell_within_big_swamp_reach(target_cell: Vector2i, trap_cell: Vector2i, max_target_distance_cells: int) -> bool:
	var max_distance: int = maxi(max_target_distance_cells, 0)
	return maxi(absi(target_cell.x - trap_cell.x), absi(target_cell.y - trap_cell.y)) <= max_distance

static func _is_candidate_line_completed(board: Dictionary, candidate_line_cells: Array) -> bool:
	var pieces: Array = []
	for cell in candidate_line_cells:
		if not board.has(cell):
			return false
		pieces.append(board[cell])
	if pieces.size() != ChainDetector.MIN_LINE_LENGTH:
		return false
	return ChainDetector._build_line_result(pieces).size() > 0

static func _is_candidate_almost_line_still_present(board: Dictionary, candidate_line_cells: Array, missing_cell: Vector2i, blocked_trap_cells: Array = []) -> bool:
	if missing_cell in blocked_trap_cells:
		return false
	var occupied_pieces: Array = []
	for cell in candidate_line_cells:
		if cell == missing_cell:
			continue
		if cell in blocked_trap_cells:
			return false
		if not board.has(cell):
			return false
		occupied_pieces.append(board[cell])
	return not _get_almost_line_completion(board, occupied_pieces, missing_cell, candidate_line_cells, blocked_trap_cells).is_empty()

static func _has_king_piece(pieces: Array) -> bool:
	for piece in pieces:
		if piece.piece_type == GameManager.PieceType.KING:
			return true
	return false

static func _is_grid_cell_in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < GameManager.BOARD_SIZE and cell.y >= 0 and cell.y < GameManager.BOARD_SIZE

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
		Settings.record_kingdom_completed_level(Settings.theme_id, completed_level_number)
		Settings.record_kingdom_start_level(Settings.theme_id, mini(completed_level_number, SURVIVAL_LEVEL_INDEX))
		var level_complete_message := _tf("level_complete", {"number": completed_level_number})
		_queue_scoring_event(GameManager.build_level_complete_event(completed_level_number))
		await _show_puzzle_overlay_message(level_complete_message, PUZZLE_LEVEL_COMPLETE_HOLD)
		if completed_level_number >= WIN_LEVEL_NUMBER:
			if is_survival_mode:
				pending_survival_round_completion = true
				return
			pending_kingdom_completion_win = true
			return
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
	if game_over_overlay.visible:
		return
	if BoardStateRulesScript.is_loss_board_state(
		board_manager.get_empty_cells(),
		BoardStateRulesScript.NORMAL_SPAWN_COUNT
	):
		if is_survival_mode:
			_finish_survival_run()
			return
		GameManager.end_game(GameManager.GAME_RESULT_LOSS)

func _finish_survival_run():
	is_final_survival_dialog = true
	is_survival_mode = false
	if survival_blood_overlay != null and survival_blood_overlay.has_method("stop"):
		survival_blood_overlay.stop()
	GameManager.end_game(GameManager.GAME_RESULT_WIN)

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

func _on_trap_selected(trap_data: Resource):
	move_hint_label.text = _get_trap_hint_text(trap_data)
	move_hint_panel.visible = true

func _on_trap_deselected():
	move_hint_panel.visible = false
	move_hint_label.text = ""

func _get_trap_hint_text(trap_data: Resource) -> String:
	var trap_name := _get_trap_display_name(trap_data)
	var description := _get_trap_description(trap_data)
	if description.is_empty():
		return trap_name
	return "%s\n%s" % [trap_name, description]

func _spawn_initial_pieces():
	var piece_count = 3
	
	for i in range(piece_count):
		var spawn_data: Dictionary = board_manager.get_random_spawn_piece_data()
		if spawn_data.is_empty():
			break
		if not board_manager.spawn_piece_with_preferred_placement(spawn_data):
			break

func _on_capture_made(_piece, _target, captured_piece_type: int):
	current_turn_had_take = true
	AudioManager.play_sound("capture")
	AudioManager.vibrate()
	_begin_score_message_batch()
	_queue_scoring_event(GameManager.build_sacrifice_event(captured_piece_type))

func _on_piece_sacrificed(_from: Vector2i, _to: Vector2i, piece_type: int):
	if is_processing_move:
		return

	current_turn_had_take = true
	AudioManager.play_sound("capture")
	AudioManager.vibrate()
	var trap_data: Resource = board_manager.get_trap_data(_to)
	var theme := _get_theme()
	var trap_name := _get_trap_display_name(trap_data)
	var trap_message := _build_trap_disappearance_message(piece_type, trap_name)
	var trap_event := GameManager.build_trap_disappearance_event(piece_type, trap_name)
	board_manager.show_trap_message_cloud(_to, trap_message, theme, piece_type, board_manager.get_last_sacrificed_piece_color())
	_begin_score_message_batch()
	_queue_scoring_event(trap_event)
	_resolve_sacrifice_turn(_get_trap_spawn_count(trap_data))

func _build_trap_disappearance_message(piece_type: int, trap_name: String) -> String:
	var sacrifice_cost := mini(GameManager.get_piece_value(piece_type), GameManager.current_score)
	return _tf("trap_cloud_disappeared", {
		"trap": trap_name,
		"cost": maxi(sacrifice_cost, 0)
	})

func _get_trap_display_name(trap_data: Resource) -> String:
	if trap_data != null:
		var display_name_key := str(trap_data.get("display_name_key")).strip_edges()
		if not display_name_key.is_empty():
			return _t(display_name_key)
	if trap_data != null and not str(trap_data.display_name).strip_edges().is_empty():
		return str(trap_data.display_name).strip_edges()
	return _t("piece_generic")

func _get_trap_description(trap_data: Resource) -> String:
	if trap_data == null:
		return ""
	var description_key := str(trap_data.get("description_key")).strip_edges()
	if not description_key.is_empty():
		return _t(description_key)
	return str(trap_data.description).strip_edges()

func _on_piece_moved(_from, _to):
	if is_processing_move:
		return
	current_turn_had_take = false
	_resolve_turn()

func _on_score_updated(_new_score: int):
	_update_ui()

func _on_line_metrics_updated(_color_lines: int, _type_lines: int):
	_update_line_metrics_ui()

func _on_settings_changed():
	_apply_localized_text()
	_update_ui()

func _on_theme_changed(theme_data, _theme_id: String):
	apply_theme(theme_data as ThemeData)

func _update_ui():
	_update_current_score_digits(GameManager.current_score)
	var best_level_display := Settings.get_kingdom_best_level_display(Settings.theme_id)
	high_score_label.text = "%d | L %d" % [GameManager.high_score, best_level_display]
	_update_line_metrics_ui()

func _update_line_metrics_ui():
	color_lines_value_label.text = str(GameManager.color_lines_cleared)
	type_lines_value_label.text = str(GameManager.type_lines_cleared)
	level_value_label.text = str(current_puzzle_level + 1)

func _on_game_over(final_score: int, result: String, achieved_best_score: bool):
	latest_game_result = result
	latest_best_score_achieved = achieved_best_score
	_save_clean_turn_mastery(result)
	board_manager.set_input_enabled(false)
	pause_overlay.visible = false
	game_over_overlay.visible = true
	_update_game_over_dialog(final_score, result, achieved_best_score)
	AudioManager.play_sound("game_over")

func _update_game_over_dialog(final_score: int, result: String, achieved_best_score: bool):
	if is_final_survival_dialog:
		game_over_title_label.text = _t("survival_win_title")
	elif result == GameManager.GAME_RESULT_WIN:
		game_over_title_label.text = _t("game_won")
	else:
		game_over_title_label.text = _t("game_lost")

	survive_button.visible = result == GameManager.GAME_RESULT_WIN and not is_final_survival_dialog

	if is_final_survival_dialog:
		game_over_summary_label.text = _tf("survival_win_summary", {"count": survived_rounds})
	elif achieved_best_score:
		game_over_summary_label.text = _t("new_best_score")
	else:
		game_over_summary_label.text = _t("session_complete")

	var score_lines: Array[String] = [
		"%s: %d" % [_t("session_score"), final_score],
		"%s: %d" % [_t("removed_color_lines"), GameManager.color_lines_cleared],
		"%s: %d" % [_t("removed_type_lines"), GameManager.type_lines_cleared],
		"%s: %d" % [_t("played_campaigns"), SESSION_CAMPAIGNS_PLAYED]
	]
	if is_final_survival_dialog:
		score_lines.append("%s: %d" % [_t("survived_rounds"), survived_rounds])
	game_over_score_label.text = "\n".join(score_lines)

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
	is_survival_mode = false
	survival_round_index = 0
	survived_rounds = 0
	is_final_survival_dialog = false
	survival_round_started_this_turn = false
	pending_kingdom_completion_win = false
	pending_survival_round_completion = false
	if survival_blood_overlay != null and survival_blood_overlay.has_method("stop"):
		survival_blood_overlay.stop()
	session_total_turns = 0
	session_clean_turns = 0
	current_turn_had_take = false
	latest_game_result = GameManager.GAME_RESULT_LOSS
	latest_best_score_achieved = false
	GameManager.reset_game()
	_initialize_game()
	_update_layout()
	_update_ui()

func _on_reset_pressed():
	Settings.reset_kingdom_start_level(Settings.theme_id)
	_on_restart_pressed()

func _on_survive_pressed():
	survival_round_index = 1
	survived_rounds = 0
	is_final_survival_dialog = false
	_start_survival_round()

func _on_main_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")

func _resolve_turn():
	is_processing_move = true
	board_manager.set_input_enabled(false)
	_begin_score_message_batch()
	await get_tree().create_timer(0.3).timeout

	await _resolve_chain_waves()
	if survival_round_started_this_turn:
		survival_round_started_this_turn = false
		_flush_score_message_batch()
		is_processing_move = false
		return
	if game_over_overlay.visible:
		_flush_score_message_batch()
		is_processing_move = false
		return

	var spawned_count: int = _spawn_new_pieces()
	if spawned_count == 0:
		_record_completed_turn()
		_check_game_over()
		_flush_score_message_batch()
		is_processing_move = false
		if not game_over_overlay.visible and not pause_overlay.visible:
			board_manager.set_input_enabled(true)
		return

	if await _finish_pending_completion_after_successful_spawn():
		_record_completed_turn()
		_flush_score_message_batch()
		is_processing_move = false
		return

	_check_game_over()
	if game_over_overlay.visible:
		_record_completed_turn()
		_flush_score_message_batch()
		is_processing_move = false
		return

	await get_tree().create_timer(0.3).timeout
	await _resolve_chain_waves()
	if survival_round_started_this_turn:
		survival_round_started_this_turn = false
		_flush_score_message_batch()
		is_processing_move = false
		return
	if game_over_overlay.visible:
		_flush_score_message_batch()
		is_processing_move = false
		return

	await get_tree().create_timer(0.3).timeout
	_record_completed_turn()
	_maybe_rotate_traps()
	_maybe_start_big_swamp_pulse()
	_check_game_over()

	_flush_score_message_batch()
	is_processing_move = false
	if not game_over_overlay.visible and not pause_overlay.visible:
		board_manager.set_input_enabled(true)

func _resolve_sacrifice_turn(spawn_count: int):
	is_processing_move = true
	board_manager.set_input_enabled(false)
	_begin_score_message_batch()
	await get_tree().create_timer(0.3).timeout

	var spawned_count: int = _spawn_new_pieces(spawn_count)
	if spawned_count == 0:
		_record_completed_turn()
		_check_game_over()
		_flush_score_message_batch()
		is_processing_move = false
		if not game_over_overlay.visible and not pause_overlay.visible:
			board_manager.set_input_enabled(true)
		return

	if await _finish_pending_completion_after_successful_spawn():
		_record_completed_turn()
		_flush_score_message_batch()
		is_processing_move = false
		return

	await get_tree().create_timer(0.3).timeout
	await _resolve_chain_waves()
	if survival_round_started_this_turn:
		survival_round_started_this_turn = false
		_flush_score_message_batch()
		is_processing_move = false
		return
	await get_tree().create_timer(0.3).timeout
	_record_completed_turn()
	_maybe_rotate_traps()
	_maybe_start_big_swamp_pulse()
	_check_game_over()

	_flush_score_message_batch()
	is_processing_move = false
	if not game_over_overlay.visible and not pause_overlay.visible:
		board_manager.set_input_enabled(true)

func _record_completed_turn():
	session_total_turns += 1
	if not current_turn_had_take:
		session_clean_turns += 1
	current_turn_had_take = false

func _has_pending_completion() -> bool:
	return pending_kingdom_completion_win or pending_survival_round_completion

func _finish_pending_completion_after_successful_spawn() -> bool:
	if not _has_pending_completion():
		return false
	if game_over_overlay.visible:
		return false
	if pending_survival_round_completion:
		pending_survival_round_completion = false
		survived_rounds += 1
		survival_round_index += 1
		survival_round_started_this_turn = true
		await _fade_puzzle_image_out()
		await _start_survival_round()
		return true
	if pending_kingdom_completion_win:
		pending_kingdom_completion_win = false
		GameManager.end_game(GameManager.GAME_RESULT_WIN)
		return true
	return false

func _save_clean_turn_mastery(result: String):
	Settings.record_kingdom_clean_turn_session(
		Settings.theme_id,
		session_clean_turns,
		session_total_turns,
		result == GameManager.GAME_RESULT_WIN
	)

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

func _get_trap_spawn_count(trap_data: Resource) -> int:
	if forced_sacrifice_spawn_count > 0:
		return forced_sacrifice_spawn_count
	if trap_data != null:
		return trap_data.get_spawn_count(current_puzzle_level)
	return 2

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
	survive_button.text = _t("survive")
	main_menu_button.text = _t("main_menu")
	if game_over_overlay.visible:
		_update_game_over_dialog(GameManager.current_score, latest_game_result, latest_best_score_achieved)

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
