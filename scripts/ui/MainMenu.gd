extends Control

const MAIN_SCREEN_BACKGROUND_TEXTURE := preload("res://assets/ui/themes/main_screen/background_image.png")
const MAIN_SCREEN_FRAME_TEXTURE := preload("res://assets/ui/themes/main_screen/main_screen_backround_mainframe.png")
const ACTIVE_CARD_FRAME_TEXTURE := preload("res://assets/ui/themes/main_screen/active_card_frame.png")
const INACTIVE_CARD_FRAME_TEXTURE := preload("res://assets/ui/themes/main_screen/inactive_card_frame.png")
const KINGDOM_1_TEXTURE := preload("res://assets/ui/themes/main_screen/kingdom1.png")
const KINGDOM_2_TEXTURE := preload("res://assets/ui/themes/main_screen/kingdom2.png")
const KINGDOM_3_TEXTURE := preload("res://assets/ui/themes/main_screen/kingdom3.png")

const DESIGN_SIZE := Vector2(768.0, 1376.0)
const KINGDOM_CARD_RECTS := [
	Rect2(64.0, 245.0, 640.0, 365.0),
	Rect2(64.0, 600.0, 640.0, 385.0),
	Rect2(64.0, 960.0, 640.0, 325.0)
]
const HOW_TO_PLAY_ZONE := Rect2(58.0, 1266.0, 230.0, 92.0)
const SETTINGS_ZONE := Rect2(290.0, 1266.0, 220.0, 92.0)
const EXIT_ZONE := Rect2(512.0, 1266.0, 214.0, 92.0)

@onready var how_to_play_panel: PanelContainer = $HowToPlayPanel
@onready var settings_panel: PanelContainer = $SettingsPanel
@onready var background: Control = $Background
@onready var kingdom_screen: Control = $KingdomScreen
@onready var button_zones: Control = $ButtonZones
@onready var menu_panel: PanelContainer = $CenterContainer/MenuPanel
@onready var title_label: Label = $CenterContainer/MenuPanel/MenuContent/Title
@onready var subtitle_label: Label = $CenterContainer/MenuPanel/MenuContent/Subtitle
@onready var button_kingdom_1: Button = $ButtonZones/Kingdom1Button
@onready var button_kingdom_2: Button = $ButtonZones/Kingdom2Button
@onready var button_kingdom_3: Button = $ButtonZones/Kingdom3Button
@onready var button_how_to_play: Button = $ButtonZones/ButtonHowToPlay
@onready var button_settings: Button = $ButtonZones/ButtonSettings
@onready var button_quit: Button = $ButtonZones/ButtonQuit
@onready var how_to_play_header: Label = $HowToPlayPanel/HowToPlayCenter/InstructionsContainer/Header
@onready var how_to_play_instructions: RichTextLabel = $HowToPlayPanel/HowToPlayCenter/InstructionsContainer/Instructions
@onready var button_back: Button = $HowToPlayPanel/HowToPlayCenter/InstructionsContainer/ButtonRow/ButtonBack
@onready var settings_title_label: Label = $SettingsPanel/SettingsCenter/SettingsCard/SettingsContent/SettingsTitle
@onready var settings_sound_label: Label = $SettingsPanel/SettingsCenter/SettingsCard/SettingsContent/SoundRow/SoundLabel
@onready var settings_sound_button: Button = $SettingsPanel/SettingsCenter/SettingsCard/SettingsContent/SoundRow/SoundButton
@onready var settings_vibration_label: Label = $SettingsPanel/SettingsCenter/SettingsCard/SettingsContent/VibrationRow/VibrationLabel
@onready var settings_vibration_button: Button = $SettingsPanel/SettingsCenter/SettingsCard/SettingsContent/VibrationRow/VibrationButton
@onready var settings_theme_label: Label = $SettingsPanel/SettingsCenter/SettingsCard/SettingsContent/ThemeRow/ThemeLabel
@onready var settings_theme_option: OptionButton = $SettingsPanel/SettingsCenter/SettingsCard/SettingsContent/ThemeRow/ThemeOption
@onready var settings_language_label: Label = $SettingsPanel/SettingsCenter/SettingsCard/SettingsContent/LanguageRow/LanguageLabel
@onready var settings_language_option: OptionButton = $SettingsPanel/SettingsCenter/SettingsCard/SettingsContent/LanguageRow/LanguageOption
@onready var settings_close_button: Button = $SettingsPanel/SettingsCenter/SettingsCard/SettingsContent/ButtonRow/ButtonCloseSettings

var kingdom_design_root: Control
var kingdom_frame_nodes: Array[TextureRect] = []
var kingdom_card_nodes: Array[TextureRect] = []
var kingdom_coming_soon_label: Label

func _ready():
	_lock_mobile_orientation()
	background.visible = false
	_build_kingdom_screen()
	resized.connect(_update_kingdom_screen_layout)
	apply_theme(_get_theme())
	_populate_theme_selector()
	_populate_language_selector()
	_apply_localized_text()
	_sync_settings_ui()
	button_kingdom_1.pressed.connect(_on_kingdom_1_pressed)
	button_kingdom_2.pressed.connect(_on_kingdom_2_pressed)
	button_how_to_play.pressed.connect(_on_how_to_play_pressed)
	button_settings.pressed.connect(_on_settings_pressed)
	button_quit.pressed.connect(_on_quit_pressed)
	button_back.pressed.connect(_on_back_pressed)
	settings_close_button.pressed.connect(_on_settings_close_pressed)
	settings_sound_button.pressed.connect(_on_settings_sound_pressed)
	settings_vibration_button.pressed.connect(_on_settings_vibration_pressed)
	settings_theme_option.item_selected.connect(_on_settings_theme_selected)
	settings_language_option.item_selected.connect(_on_settings_language_selected)
	var theme_manager: Variant = _get_theme_manager()
	if theme_manager != null and not theme_manager.theme_changed.is_connected(_on_theme_changed):
		theme_manager.theme_changed.connect(_on_theme_changed)
	if not Settings.settings_changed.is_connected(_on_settings_changed):
		Settings.settings_changed.connect(_on_settings_changed)
	settings_theme_label.get_parent().visible = false
	_update_kingdom_selection()

func _lock_mobile_orientation():
	if OS.has_feature("android"):
		DisplayServer.screen_set_orientation(DisplayServer.SCREEN_PORTRAIT)

func _get_theme() -> ThemeData:
	var theme_manager: Variant = _get_theme_manager()
	if theme_manager != null:
		return theme_manager.get_active_theme()
	return null

func _get_theme_manager() -> Node:
	var main_loop: MainLoop = Engine.get_main_loop()
	if main_loop is SceneTree:
		var root: Window = main_loop.root
		return root.get_node_or_null("ThemeManager")
	return null

func apply_theme(theme_data):
	if theme_data == null:
		return

	if background.has_method("apply_theme"):
		background.apply_theme(theme_data)

	var panel_style := _build_panel_style(theme_data.menu_panel_background_color, theme_data.menu_panel_border_color)
	menu_panel.add_theme_stylebox_override("panel", panel_style)
	how_to_play_panel.add_theme_stylebox_override("panel", panel_style.duplicate())

	var title_font: SystemFont = _build_menu_font(theme_data.dialog_font_names, theme_data.dialog_title_font_weight)
	var body_font: SystemFont = _build_menu_font(theme_data.dialog_font_names, theme_data.dialog_body_font_weight)
	var button_font: SystemFont = _build_menu_font(theme_data.dialog_font_names, theme_data.dialog_button_font_weight)
	var dialog_panel_style := _build_dialog_panel_style(theme_data.dialog_panel_background_color, theme_data.dialog_panel_border_color)

	title_label.add_theme_color_override("font_color", theme_data.menu_title_color)
	subtitle_label.add_theme_color_override("font_color", theme_data.menu_subtitle_color)
	how_to_play_header.add_theme_color_override("font_color", theme_data.menu_title_color)
	how_to_play_instructions.add_theme_color_override("default_color", theme_data.menu_title_color)
	title_label.add_theme_font_override("font", title_font)
	subtitle_label.add_theme_font_override("font", body_font)
	how_to_play_header.add_theme_font_override("font", title_font)
	how_to_play_instructions.add_theme_font_override("normal_font", body_font)
	how_to_play_instructions.add_theme_font_override("bold_font", button_font)
	settings_title_label.add_theme_color_override("font_color", theme_data.dialog_title_color)
	settings_sound_label.add_theme_color_override("font_color", theme_data.dialog_body_color)
	settings_vibration_label.add_theme_color_override("font_color", theme_data.dialog_body_color)
	settings_theme_label.add_theme_color_override("font_color", theme_data.dialog_body_color)
	settings_language_label.add_theme_color_override("font_color", theme_data.dialog_body_color)
	settings_title_label.add_theme_font_override("font", title_font)
	settings_sound_label.add_theme_font_override("font", body_font)
	settings_vibration_label.add_theme_font_override("font", body_font)
	settings_theme_label.add_theme_font_override("font", body_font)
	settings_language_label.add_theme_font_override("font", body_font)
	settings_panel.add_theme_stylebox_override("panel", dialog_panel_style)
	_apply_dialog_button_style(
		settings_sound_button,
		button_font,
		theme_data.dialog_button_secondary_color,
		theme_data.dialog_button_secondary_hover_color,
		theme_data.dialog_button_text_color,
		theme_data.dialog_button_text_color,
		theme_data.dialog_button_secondary_border_color,
		theme_data.dialog_button_secondary_border_hover_color
	)
	_apply_dialog_button_style(
		settings_vibration_button,
		button_font,
		theme_data.dialog_button_secondary_color,
		theme_data.dialog_button_secondary_hover_color,
		theme_data.dialog_button_text_color,
		theme_data.dialog_button_text_color,
		theme_data.dialog_button_secondary_border_color,
		theme_data.dialog_button_secondary_border_hover_color
	)
	_apply_dialog_button_style(
		settings_close_button,
		button_font,
		theme_data.dialog_button_secondary_color,
		theme_data.dialog_button_secondary_hover_color,
		theme_data.dialog_button_text_color,
		theme_data.dialog_button_text_color,
		theme_data.dialog_button_secondary_border_color,
		theme_data.dialog_button_secondary_border_hover_color
	)
	_apply_button_style(
		button_settings,
		button_font,
		theme_data.menu_button_outline_color,
		theme_data.menu_button_outline_hover_color,
		theme_data.menu_outline_button_text_color,
		theme_data.menu_outline_button_text_color_hover,
		theme_data.menu_button_outline_border_color,
		theme_data.menu_button_outline_border_hover_color
	)
	settings_theme_option.add_theme_font_override("font", body_font)
	settings_theme_option.add_theme_font_size_override("font_size", theme_data.dialog_selector_font_size)
	settings_theme_option.add_theme_color_override("font_color", theme_data.dialog_button_text_color)
	settings_theme_option.add_theme_color_override("font_hover_color", theme_data.dialog_button_text_color)
	settings_theme_option.add_theme_stylebox_override("normal", _build_dialog_button_style(theme_data.dialog_button_secondary_color, theme_data.dialog_button_secondary_border_color))
	settings_theme_option.add_theme_stylebox_override("hover", _build_dialog_button_style(theme_data.dialog_button_secondary_hover_color, theme_data.dialog_button_secondary_border_hover_color))
	settings_theme_option.add_theme_stylebox_override("pressed", _build_dialog_button_style(theme_data.dialog_button_secondary_hover_color, theme_data.dialog_button_secondary_border_hover_color))
	_apply_theme_selector_popup_style(settings_theme_option, body_font, theme_data)
	settings_language_option.add_theme_font_override("font", body_font)
	settings_language_option.add_theme_font_size_override("font_size", theme_data.dialog_selector_font_size)
	settings_language_option.add_theme_color_override("font_color", theme_data.dialog_button_text_color)
	settings_language_option.add_theme_color_override("font_hover_color", theme_data.dialog_button_text_color)
	settings_language_option.add_theme_stylebox_override("normal", _build_dialog_button_style(theme_data.dialog_button_secondary_color, theme_data.dialog_button_secondary_border_color))
	settings_language_option.add_theme_stylebox_override("hover", _build_dialog_button_style(theme_data.dialog_button_secondary_hover_color, theme_data.dialog_button_secondary_border_hover_color))
	settings_language_option.add_theme_stylebox_override("pressed", _build_dialog_button_style(theme_data.dialog_button_secondary_hover_color, theme_data.dialog_button_secondary_border_hover_color))
	_apply_theme_selector_popup_style(settings_language_option, body_font, theme_data)

	_apply_button_style(button_kingdom_1, button_font, Color.TRANSPARENT, Color.TRANSPARENT, Color.TRANSPARENT, Color.TRANSPARENT)
	_apply_button_style(button_kingdom_2, button_font, Color.TRANSPARENT, Color.TRANSPARENT, Color.TRANSPARENT, Color.TRANSPARENT)
	_apply_button_style(
		button_how_to_play,
		button_font,
		theme_data.menu_button_orange_color,
		theme_data.menu_button_orange_hover_color,
		theme_data.menu_button_text_color,
		theme_data.menu_button_text_color_hover
	)
	_apply_button_style(
		button_quit,
		button_font,
		theme_data.menu_button_outline_color,
		theme_data.menu_button_outline_hover_color,
		theme_data.menu_outline_button_text_color,
		theme_data.menu_outline_button_text_color_hover,
		theme_data.menu_button_outline_border_color,
		theme_data.menu_button_outline_border_hover_color
	)
	_apply_button_style(
		button_back,
		button_font,
		theme_data.menu_button_outline_color,
		theme_data.menu_button_outline_hover_color,
		theme_data.menu_outline_button_text_color,
		theme_data.menu_outline_button_text_color_hover,
		theme_data.menu_button_outline_border_color,
		theme_data.menu_button_outline_border_hover_color
	)
	_apply_button_zone_style(button_kingdom_1)
	_apply_button_zone_style(button_kingdom_2)
	_apply_button_zone_style(button_kingdom_3)
	_apply_button_zone_style(button_how_to_play)
	_apply_button_zone_style(button_settings)
	_apply_button_zone_style(button_quit)
	_style_coming_soon_label(theme_data, body_font)

func _build_kingdom_screen():
	kingdom_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in kingdom_screen.get_children():
		child.queue_free()

	var background_texture := TextureRect.new()
	background_texture.name = "BackgroundImage"
	background_texture.texture = MAIN_SCREEN_BACKGROUND_TEXTURE
	background_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background_texture.set_anchors_preset(Control.PRESET_FULL_RECT)
	background_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	kingdom_screen.add_child(background_texture)

	kingdom_design_root = Control.new()
	kingdom_design_root.name = "DesignRoot"
	kingdom_design_root.custom_minimum_size = DESIGN_SIZE
	kingdom_design_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	kingdom_screen.add_child(kingdom_design_root)

	var main_frame := _create_texture_rect("MainFrame", MAIN_SCREEN_FRAME_TEXTURE, Rect2(Vector2.ZERO, DESIGN_SIZE))
	kingdom_design_root.add_child(main_frame)

	kingdom_frame_nodes.clear()
	kingdom_card_nodes.clear()
	var kingdom_textures := [KINGDOM_1_TEXTURE, KINGDOM_2_TEXTURE, KINGDOM_3_TEXTURE]
	for i in range(KINGDOM_CARD_RECTS.size()):
		var frame := _create_texture_rect("Kingdom%dFrame" % [i + 1], INACTIVE_CARD_FRAME_TEXTURE, KINGDOM_CARD_RECTS[i].grow(16.0))
		var card := _create_texture_rect("Kingdom%dCard" % [i + 1], kingdom_textures[i], KINGDOM_CARD_RECTS[i])
		kingdom_design_root.add_child(frame)
		kingdom_design_root.add_child(card)
		kingdom_frame_nodes.append(frame)
		kingdom_card_nodes.append(card)

	kingdom_coming_soon_label = Label.new()
	kingdom_coming_soon_label.name = "Kingdom3ComingSoon"
	kingdom_coming_soon_label.text = "COMING SOON"
	kingdom_coming_soon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	kingdom_coming_soon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	kingdom_coming_soon_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	kingdom_design_root.add_child(kingdom_coming_soon_label)

	_update_kingdom_screen_layout()
	_update_kingdom_selection()

func _create_texture_rect(node_name: String, texture: Texture2D, rect: Rect2) -> TextureRect:
	var texture_rect := TextureRect.new()
	texture_rect.name = node_name
	texture_rect.texture = texture
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_SCALE
	texture_rect.position = rect.position
	texture_rect.size = rect.size
	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return texture_rect

func _update_kingdom_screen_layout():
	if kingdom_design_root == null:
		return
	var scale_factor := maxf(size.x / DESIGN_SIZE.x, size.y / DESIGN_SIZE.y)
	var scaled_size := DESIGN_SIZE * scale_factor
	kingdom_design_root.position = (size - scaled_size) * 0.5
	kingdom_design_root.scale = Vector2(scale_factor, scale_factor)
	kingdom_design_root.size = DESIGN_SIZE
	_layout_button_zone(button_kingdom_1, KINGDOM_CARD_RECTS[0])
	_layout_button_zone(button_kingdom_2, KINGDOM_CARD_RECTS[1])
	_layout_button_zone(button_kingdom_3, KINGDOM_CARD_RECTS[2])
	_layout_button_zone(button_how_to_play, HOW_TO_PLAY_ZONE)
	_layout_button_zone(button_settings, SETTINGS_ZONE)
	_layout_button_zone(button_quit, EXIT_ZONE)
	if kingdom_coming_soon_label != null:
		var label_rect := KINGDOM_CARD_RECTS[2].grow(-24.0)
		kingdom_coming_soon_label.position = label_rect.position
		kingdom_coming_soon_label.size = label_rect.size

func _layout_button_zone(button: Button, design_rect: Rect2):
	if button == null or kingdom_design_root == null:
		return
	var scale_factor := kingdom_design_root.scale.x
	button.set_anchors_preset(Control.PRESET_TOP_LEFT, false)
	button.position = kingdom_design_root.position + design_rect.position * scale_factor
	button.size = design_rect.size * scale_factor

func _update_kingdom_selection():
	if kingdom_frame_nodes.size() < 3:
		return
	var selected_index := 0
	if Settings.theme_id == "neon":
		selected_index = 1
	for i in range(kingdom_frame_nodes.size()):
		kingdom_frame_nodes[i].texture = ACTIVE_CARD_FRAME_TEXTURE if i == selected_index else INACTIVE_CARD_FRAME_TEXTURE
		kingdom_card_nodes[i].modulate = Color(1, 1, 1, 1) if i < 2 else Color(0.34, 0.34, 0.38, 0.72)
	button_kingdom_3.disabled = true

func _style_coming_soon_label(theme_data: ThemeData, font: Font):
	if kingdom_coming_soon_label == null:
		return
	kingdom_coming_soon_label.add_theme_font_override("font", font)
	kingdom_coming_soon_label.add_theme_font_size_override("font_size", 46)
	kingdom_coming_soon_label.add_theme_color_override("font_color", theme_data.dialog_body_color)
	kingdom_coming_soon_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.82))
	kingdom_coming_soon_label.add_theme_constant_override("outline_size", 5)

func _build_menu_font(font_names: PackedStringArray, font_weight: int) -> SystemFont:
	var font := SystemFont.new()
	font.font_names = font_names
	font.font_weight = font_weight
	return font

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

func _apply_button_style(button: Button, font: Font, normal_color: Color, hover_color: Color, text_color: Color, text_color_hover: Color, normal_border_color: Color = Color.TRANSPARENT, hover_border_color: Color = Color.TRANSPARENT):
	button.add_theme_font_override("font", font)
	button.add_theme_stylebox_override("normal", _build_button_style(normal_color, normal_border_color))
	button.add_theme_stylebox_override("hover", _build_button_style(hover_color, hover_border_color))
	button.add_theme_color_override("font_color", text_color)
	button.add_theme_color_override("font_hover_color", text_color_hover)

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

func _apply_dialog_button_style(button: Button, font: Font, normal_color: Color, hover_color: Color, text_color: Color, text_color_hover: Color, normal_border_color: Color = Color.TRANSPARENT, hover_border_color: Color = Color.TRANSPARENT):
	_apply_button_style(button, font, normal_color, hover_color, text_color, text_color_hover, normal_border_color, hover_border_color)

func _apply_button_zone_style(button: Button):
	var empty_style := StyleBoxEmpty.new()
	button.flat = true
	button.add_theme_stylebox_override("normal", empty_style)
	button.add_theme_stylebox_override("hover", empty_style)
	button.add_theme_stylebox_override("pressed", empty_style)
	button.add_theme_stylebox_override("focus", empty_style)
	button.add_theme_color_override("font_color", Color.TRANSPARENT)
	button.add_theme_color_override("font_hover_color", Color.TRANSPARENT)
	button.add_theme_color_override("font_pressed_color", Color.TRANSPARENT)

func _build_dialog_button_style(background_color: Color, border_color: Color) -> StyleBoxFlat:
	return _build_button_style(background_color, border_color)

func _apply_theme_selector_popup_style(option_button: OptionButton, body_font: Font, theme_data: ThemeData):
	var popup := option_button.get_popup()
	if popup == null:
		return

	popup.add_theme_font_override("font", body_font)
	popup.add_theme_font_size_override("font_size", theme_data.dialog_selector_font_size)
	popup.add_theme_color_override("font_color", theme_data.dialog_button_text_color)
	popup.add_theme_color_override("font_hover_color", theme_data.dialog_button_text_color)
	popup.add_theme_stylebox_override("panel", _build_dialog_panel_style(theme_data.dialog_panel_background_color, theme_data.dialog_panel_border_color))

func _on_kingdom_1_pressed():
	Settings.set_theme_id("default")
	get_tree().change_scene_to_file("res://scenes/board/GameBoard.tscn")

func _on_kingdom_2_pressed():
	Settings.set_theme_id("neon")
	get_tree().change_scene_to_file("res://scenes/board/GameBoard.tscn")

func _on_how_to_play_pressed():
	settings_panel.visible = false
	how_to_play_panel.visible = true

func _on_back_pressed():
	how_to_play_panel.visible = false

func _on_settings_pressed():
	how_to_play_panel.visible = false
	settings_panel.visible = true
	_sync_settings_ui()

func _on_settings_close_pressed():
	settings_panel.visible = false

func _on_settings_sound_pressed():
	Settings.toggle_sound()
	_sync_settings_ui()

func _on_settings_vibration_pressed():
	Settings.toggle_vibration()
	_sync_settings_ui()

func _on_settings_theme_selected(index: int):
	var theme_id = str(settings_theme_option.get_item_metadata(index))
	Settings.set_theme_id(theme_id)

func _on_settings_language_selected(index: int):
	var language_code = str(settings_language_option.get_item_metadata(index))
	Settings.set_language_code(language_code)

func _on_settings_changed():
	_apply_localized_text()
	_populate_theme_selector()
	_populate_language_selector()
	_sync_settings_ui()
	_update_kingdom_selection()

func _on_theme_changed(_theme_data, _theme_id):
	apply_theme(_get_theme())
	_populate_theme_selector()
	_populate_language_selector()
	_apply_localized_text()
	_sync_settings_ui()
	_update_kingdom_selection()

func _populate_theme_selector():
	settings_theme_option.clear()
	var theme_manager: Variant = _get_theme_manager()
	if theme_manager == null:
		return

	for theme_id in theme_manager.get_available_theme_ids():
		settings_theme_option.add_item(Localization.t("theme_" + str(theme_id)))
		settings_theme_option.set_item_metadata(settings_theme_option.get_item_count() - 1, theme_id)

func _populate_language_selector():
	settings_language_option.clear()
	for language_code in Localization.get_available_language_codes():
		settings_language_option.add_item(Localization.get_language_display_name(language_code))
		settings_language_option.set_item_metadata(settings_language_option.get_item_count() - 1, language_code)

func _sync_settings_ui():
	settings_sound_button.text = Localization.t("sound_on") if Settings.sound_enabled else Localization.t("sound_off")
	settings_vibration_button.text = Localization.t("vibration_on") if Settings.vibration_enabled else Localization.t("vibration_off")

	var theme_manager: Variant = _get_theme_manager()
	if theme_manager != null:
		for i in range(settings_theme_option.get_item_count()):
			if str(settings_theme_option.get_item_metadata(i)) == Settings.theme_id:
				settings_theme_option.select(i)
				break

	for i in range(settings_language_option.get_item_count()):
		if str(settings_language_option.get_item_metadata(i)) == Settings.language_code:
			settings_language_option.select(i)
			break

func _apply_localized_text():
	title_label.text = Localization.t("main_title")
	subtitle_label.text = Localization.t("main_subtitle")
	button_kingdom_1.text = ""
	button_kingdom_2.text = ""
	button_kingdom_3.text = ""
	button_how_to_play.text = ""
	button_settings.text = ""
	button_quit.text = ""
	how_to_play_header.text = Localization.t("how_to_play")
	how_to_play_instructions.text = Localization.t("how_to_play_text")
	button_back.text = Localization.t("back")
	settings_title_label.text = Localization.t("settings")
	settings_sound_label.text = Localization.t("sound")
	settings_vibration_label.text = Localization.t("vibration")
	settings_theme_label.text = Localization.t("theme")
	settings_language_label.text = Localization.t("language")
	settings_close_button.text = Localization.t("close")

func _on_quit_pressed():
	get_tree().quit()

func _input(event: InputEvent):
	if not event.is_action_pressed("ui_cancel"):
		return

	if settings_panel.visible:
		settings_panel.visible = false
		return

	if how_to_play_panel.visible:
		how_to_play_panel.visible = false
		return
