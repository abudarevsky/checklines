extends Control

@onready var how_to_play_panel: PanelContainer = $HowToPlayPanel
@onready var background: Control = $Background
@onready var menu_panel: PanelContainer = $CenterContainer/MenuPanel
@onready var title_label: Label = $CenterContainer/MenuPanel/MenuContent/Title
@onready var subtitle_label: Label = $CenterContainer/MenuPanel/MenuContent/Subtitle
@onready var button_play: Button = $CenterContainer/MenuPanel/MenuContent/ButtonPlay
@onready var button_how_to_play: Button = $CenterContainer/MenuPanel/MenuContent/ButtonHowToPlay
@onready var button_quit: Button = $CenterContainer/MenuPanel/MenuContent/ButtonQuit
@onready var how_to_play_header: Label = $HowToPlayPanel/HowToPlayCenter/InstructionsContainer/Header
@onready var how_to_play_instructions: RichTextLabel = $HowToPlayPanel/HowToPlayCenter/InstructionsContainer/Instructions
@onready var button_back: Button = $HowToPlayPanel/HowToPlayCenter/InstructionsContainer/ButtonRow/ButtonBack

func _ready():
	_lock_mobile_orientation()
	apply_theme(_get_theme())
	button_play.pressed.connect(_on_play_pressed)
	button_how_to_play.pressed.connect(_on_how_to_play_pressed)
	button_quit.pressed.connect(_on_quit_pressed)
	button_back.pressed.connect(_on_back_pressed)

func _lock_mobile_orientation():
	if OS.has_feature("android"):
		DisplayServer.screen_set_orientation(DisplayServer.SCREEN_PORTRAIT)

func _get_theme():
	var theme_manager = get_node_or_null("/root/ThemeManager")
	if theme_manager != null:
		return theme_manager.get_active_theme()
	return null

func apply_theme(theme):
	if theme == null:
		return

	if background.has_method("apply_theme"):
		background.apply_theme(theme)

	var panel_style := _build_panel_style(theme.menu_panel_background_color, theme.menu_panel_border_color)
	menu_panel.add_theme_stylebox_override("panel", panel_style)
	how_to_play_panel.add_theme_stylebox_override("panel", panel_style.duplicate())

	title_label.add_theme_color_override("font_color", theme.menu_title_color)
	subtitle_label.add_theme_color_override("font_color", theme.menu_subtitle_color)
	how_to_play_header.add_theme_color_override("font_color", theme.menu_title_color)
	how_to_play_instructions.add_theme_color_override("default_color", theme.menu_title_color)

	_apply_button_style(
		button_play,
		theme.menu_button_green_color,
		theme.menu_button_green_hover_color,
		theme.menu_button_text_color
	)
	_apply_button_style(
		button_how_to_play,
		theme.menu_button_orange_color,
		theme.menu_button_orange_hover_color,
		theme.menu_button_text_color
	)
	_apply_button_style(
		button_quit,
		theme.menu_button_outline_color,
		theme.menu_button_outline_hover_color,
		theme.menu_outline_button_text_color,
		theme.menu_button_outline_border_color,
		theme.menu_button_outline_border_hover_color
	)
	_apply_button_style(
		button_back,
		theme.menu_button_outline_color,
		theme.menu_button_outline_hover_color,
		theme.menu_outline_button_text_color,
		theme.menu_button_outline_border_color,
		theme.menu_button_outline_border_hover_color
	)

func _build_panel_style(background_color: Color, border_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background_color
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = border_color
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.content_margin_left = 32.0
	style.content_margin_top = 28.0
	style.content_margin_right = 32.0
	style.content_margin_bottom = 28.0
	return style

func _apply_button_style(button: Button, normal_color: Color, hover_color: Color, text_color: Color, normal_border_color: Color = Color.TRANSPARENT, hover_border_color: Color = Color.TRANSPARENT):
	button.add_theme_stylebox_override("normal", _build_button_style(normal_color, normal_border_color))
	button.add_theme_stylebox_override("hover", _build_button_style(hover_color, hover_border_color))
	button.add_theme_color_override("font_color", text_color)

func _build_button_style(background_color: Color, border_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background_color
	style.border_width_left = 2 if border_color.a > 0.0 else 0
	style.border_width_top = 2 if border_color.a > 0.0 else 0
	style.border_width_right = 2 if border_color.a > 0.0 else 0
	style.border_width_bottom = 2 if border_color.a > 0.0 else 0
	style.border_color = border_color
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 20.0
	style.content_margin_right = 20.0
	style.content_margin_top = 10.0
	style.content_margin_bottom = 10.0
	return style

func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/board/GameBoard.tscn")

func _on_how_to_play_pressed():
	how_to_play_panel.visible = true

func _on_back_pressed():
	how_to_play_panel.visible = false

func _on_quit_pressed():
	get_tree().quit()

func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel") and how_to_play_panel.visible:
		how_to_play_panel.visible = false
