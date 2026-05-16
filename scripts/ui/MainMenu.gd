extends Control

const MAIN_SCREEN_BACKGROUND_TEXTURE := preload("res://assets/ui/themes/main_screen/background_image.png")
const MAIN_SCREEN_FRAME_TEXTURE := preload("res://assets/ui/themes/main_screen/main_screen_backround_mainframe.png")
const ACTIVE_CARD_FRAME_TEXTURE := preload("res://assets/ui/themes/main_screen/card_frame_active_final.png")
const INACTIVE_CARD_FRAME_TEXTURE := preload("res://assets/ui/themes/main_screen/card_frame_inactive_final.png")
const KINGDOM_1_TEXTURE := preload("res://assets/ui/themes/main_screen/kingdom1.png")
const KINGDOM_2_TEXTURE := preload("res://assets/ui/themes/main_screen/kingdom2.png")
const KINGDOM_3_TEXTURE := preload("res://assets/ui/themes/main_screen/kingdom3.png")

const DESIGN_SIZE := Vector2(768.0, 1376.0)
const KINGDOM_SCROLL_VIEW_RECT := Rect2(44.0, 250.0, 680.0, 960.0)
const KINGDOM_SCROLL_CONTENT_SIZE := Vector2(680.0, 1180.0)
const KINGDOM_SCROLL_TOP_FADE_RECT := Rect2(44.0, 250.0, 680.0, 74.0)
const KINGDOM_SCROLL_BOTTOM_FADE_RECT := Rect2(44.0, 1060.0, 680.0, 206.0)
const KINGDOM_CARD_RECTS := [
	Rect2(20.0, 30.0, 640.0, 365.0),
	Rect2(20.0, 425.0, 640.0, 359.0),
	Rect2(20.0, 815.0, 640.0, 325.0)
]
const KINGDOM_FRAME_PADDING := Vector2(12.0, 10.0)
const KINGDOM_CARD_CONTENT_INSET := Vector2(30.0, 58.0)
const KINGDOM_DRAG_CLICK_THRESHOLD := 12.0
const KINGDOM_DOUBLE_PRESS_MS := 500
const KINGDOM_DOUBLE_TAP_POSITION_TOLERANCE := 20.0
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
var kingdom_scroll: ScrollContainer
var kingdom_scroll_content: Control
var kingdom_scroll_top_fade: ColorRect
var kingdom_scroll_bottom_fade: ColorRect
var kingdom_frame_nodes: Array[TextureRect] = []
var kingdom_card_nodes: Array[TextureRect] = []
var kingdom_coming_soon_label: Label
var kingdom_frame_material: ShaderMaterial
var selected_kingdom_index := 0
var kingdom_drag_active := false
var kingdom_drag_start_position := Vector2.ZERO
var kingdom_drag_start_scroll := 0
var kingdom_drag_start_index := -1
var kingdom_drag_moved := false
var last_kingdom_press_index := -1
var last_kingdom_press_msec := 0
var last_touch_msec := 0
var last_touch_position := Vector2.ZERO

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
	button_kingdom_1.pressed.connect(_on_kingdom_pressed.bind(0))
	button_kingdom_2.pressed.connect(_on_kingdom_pressed.bind(1))
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
	_sync_selected_kingdom_from_settings()
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
	kingdom_screen.mouse_filter = Control.MOUSE_FILTER_PASS
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
	kingdom_design_root.mouse_filter = Control.MOUSE_FILTER_PASS
	kingdom_screen.add_child(kingdom_design_root)

	var main_frame := _create_texture_rect("MainFrame", MAIN_SCREEN_FRAME_TEXTURE, Rect2(Vector2.ZERO, DESIGN_SIZE))
	kingdom_design_root.add_child(main_frame)

	kingdom_scroll = ScrollContainer.new()
	kingdom_scroll.name = "KingdomScroll"
	kingdom_scroll.position = KINGDOM_SCROLL_VIEW_RECT.position
	kingdom_scroll.size = KINGDOM_SCROLL_VIEW_RECT.size
	kingdom_scroll.clip_contents = true
	kingdom_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	kingdom_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	kingdom_scroll.mouse_filter = Control.MOUSE_FILTER_PASS
	kingdom_design_root.add_child(kingdom_scroll)
	_hide_scrollbars()

	kingdom_scroll_content = Control.new()
	kingdom_scroll_content.name = "KingdomScrollContent"
	kingdom_scroll_content.custom_minimum_size = KINGDOM_SCROLL_CONTENT_SIZE
	kingdom_scroll_content.size = KINGDOM_SCROLL_CONTENT_SIZE
	kingdom_scroll_content.mouse_filter = Control.MOUSE_FILTER_PASS
	kingdom_scroll.add_child(kingdom_scroll_content)

	kingdom_scroll_top_fade = ColorRect.new()
	kingdom_scroll_top_fade.name = "KingdomScrollTopFade"
	kingdom_scroll_top_fade.position = KINGDOM_SCROLL_TOP_FADE_RECT.position
	kingdom_scroll_top_fade.size = KINGDOM_SCROLL_TOP_FADE_RECT.size
	kingdom_scroll_top_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	kingdom_scroll_top_fade.material = _build_scroll_fade_material(true)
	kingdom_design_root.add_child(kingdom_scroll_top_fade)

	kingdom_scroll_bottom_fade = ColorRect.new()
	kingdom_scroll_bottom_fade.name = "KingdomScrollBottomFade"
	kingdom_scroll_bottom_fade.position = KINGDOM_SCROLL_BOTTOM_FADE_RECT.position
	kingdom_scroll_bottom_fade.size = KINGDOM_SCROLL_BOTTOM_FADE_RECT.size
	kingdom_scroll_bottom_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	kingdom_scroll_bottom_fade.material = _build_scroll_fade_material(false)
	kingdom_design_root.add_child(kingdom_scroll_bottom_fade)

	kingdom_frame_material = _build_frame_mask_material()
	kingdom_frame_nodes.clear()
	kingdom_card_nodes.clear()
	var kingdom_textures: Array[Texture2D] = [KINGDOM_1_TEXTURE, KINGDOM_2_TEXTURE, KINGDOM_3_TEXTURE]
	for i in range(KINGDOM_CARD_RECTS.size()):
		var frame_rect := _get_kingdom_frame_rect(KINGDOM_CARD_RECTS[i])
		var card_rect := _get_kingdom_card_content_rect(frame_rect)
		var card := _create_texture_rect("Kingdom%dCard" % [i + 1], kingdom_textures[i], card_rect, TextureRect.STRETCH_KEEP_ASPECT_COVERED)
		var frame := _create_texture_rect("Kingdom%dFrame" % [i + 1], INACTIVE_CARD_FRAME_TEXTURE, frame_rect)
		kingdom_scroll_content.add_child(card)
		frame.material = kingdom_frame_material
		kingdom_scroll_content.add_child(frame)
		kingdom_frame_nodes.append(frame)
		kingdom_card_nodes.append(card)

	kingdom_coming_soon_label = Label.new()
	kingdom_coming_soon_label.name = "Kingdom3ComingSoon"
	kingdom_coming_soon_label.text = "COMING SOON"
	kingdom_coming_soon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	kingdom_coming_soon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	kingdom_coming_soon_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	kingdom_scroll_content.add_child(kingdom_coming_soon_label)

	_reparent_kingdom_buttons_to_scroll()

	_update_kingdom_screen_layout()
	_update_kingdom_selection()

func _get_kingdom_frame_rect(card_rect: Rect2) -> Rect2:
	return Rect2(
		card_rect.position - KINGDOM_FRAME_PADDING,
		card_rect.size + KINGDOM_FRAME_PADDING * 2.0
	)

func _get_kingdom_card_content_rect(frame_rect: Rect2) -> Rect2:
	return Rect2(
		frame_rect.position + KINGDOM_CARD_CONTENT_INSET,
		frame_rect.size - KINGDOM_CARD_CONTENT_INSET * 2.0
	)

func _build_frame_mask_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	float max_channel = max(tex.r, max(tex.g, tex.b));
	float min_channel = min(tex.r, min(tex.g, tex.b));
	float saturation = max_channel - min_channel;
	float gray_background = 1.0 - smoothstep(0.035, 0.12, saturation);
	float visible_background = smoothstep(0.18, 0.34, max_channel);
	tex.a *= 1.0 - gray_background * visible_background;
	COLOR = tex;
}
"""
	var shader_material := ShaderMaterial.new()
	shader_material.shader = shader
	return shader_material

func _hide_scrollbars():
	if kingdom_scroll == null:
		return
	var vertical_bar := kingdom_scroll.get_v_scroll_bar()
	if vertical_bar != null:
		vertical_bar.modulate = Color.TRANSPARENT
		vertical_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vertical_bar.custom_minimum_size.x = 0.0
	var horizontal_bar := kingdom_scroll.get_h_scroll_bar()
	if horizontal_bar != null:
		horizontal_bar.modulate = Color.TRANSPARENT
		horizontal_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		horizontal_bar.custom_minimum_size.y = 0.0

func _create_texture_rect(node_name: String, texture: Texture2D, rect: Rect2, stretch_mode: TextureRect.StretchMode = TextureRect.STRETCH_SCALE) -> TextureRect:
	var texture_rect := TextureRect.new()
	texture_rect.name = node_name
	texture_rect.texture = texture
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = stretch_mode
	texture_rect.position = rect.position
	texture_rect.size = rect.size
	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return texture_rect

func _build_scroll_fade_material(fade_from_top: bool) -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;

uniform vec4 fade_color : source_color = vec4(0.09, 0.055, 0.035, 0.78);
uniform bool fade_from_top = false;

void fragment() {
	float edge = fade_from_top ? 1.0 - UV.y : UV.y;
	float alpha = smoothstep(0.0, 0.88, edge);
	COLOR = vec4(fade_color.rgb, fade_color.a * alpha);
}
"""
	var shader_material := ShaderMaterial.new()
	shader_material.shader = shader
	shader_material.set_shader_parameter("fade_from_top", fade_from_top)
	return shader_material

func _update_kingdom_screen_layout():
	if kingdom_design_root == null:
		return
	var scale_factor := maxf(size.x / DESIGN_SIZE.x, size.y / DESIGN_SIZE.y)
	var scaled_size := DESIGN_SIZE * scale_factor
	kingdom_design_root.position = (size - scaled_size) * 0.5
	kingdom_design_root.scale = Vector2(scale_factor, scale_factor)
	kingdom_design_root.size = DESIGN_SIZE
	if kingdom_scroll != null:
		kingdom_scroll.position = KINGDOM_SCROLL_VIEW_RECT.position
		kingdom_scroll.size = KINGDOM_SCROLL_VIEW_RECT.size
		_hide_scrollbars()
	if kingdom_scroll_content != null:
		kingdom_scroll_content.custom_minimum_size = KINGDOM_SCROLL_CONTENT_SIZE
		kingdom_scroll_content.size = KINGDOM_SCROLL_CONTENT_SIZE
	if kingdom_scroll_top_fade != null:
		kingdom_scroll_top_fade.position = KINGDOM_SCROLL_TOP_FADE_RECT.position
		kingdom_scroll_top_fade.size = KINGDOM_SCROLL_TOP_FADE_RECT.size
	if kingdom_scroll_bottom_fade != null:
		kingdom_scroll_bottom_fade.position = KINGDOM_SCROLL_BOTTOM_FADE_RECT.position
		kingdom_scroll_bottom_fade.size = KINGDOM_SCROLL_BOTTOM_FADE_RECT.size
	_layout_scroll_button_zone(button_kingdom_1, KINGDOM_CARD_RECTS[0])
	_layout_scroll_button_zone(button_kingdom_2, KINGDOM_CARD_RECTS[1])
	_layout_scroll_button_zone(button_kingdom_3, KINGDOM_CARD_RECTS[2])
	_layout_button_zone(button_how_to_play, HOW_TO_PLAY_ZONE)
	_layout_button_zone(button_settings, SETTINGS_ZONE)
	_layout_button_zone(button_quit, EXIT_ZONE)
	if kingdom_coming_soon_label != null:
		var label_rect := KINGDOM_CARD_RECTS[2].grow(-24.0)
		kingdom_coming_soon_label.position = label_rect.position
		kingdom_coming_soon_label.size = label_rect.size

func _reparent_kingdom_buttons_to_scroll():
	if kingdom_scroll_content == null:
		return
	for button in [button_kingdom_1, button_kingdom_2, button_kingdom_3]:
		if button.get_parent() != kingdom_scroll_content:
			button.reparent(kingdom_scroll_content)

func _layout_scroll_button_zone(button: Button, content_rect: Rect2):
	if button == null:
		return
	button.set_anchors_preset(Control.PRESET_TOP_LEFT, false)
	button.mouse_filter = Control.MOUSE_FILTER_PASS
	button.z_index = 100
	button.visible = true
	button.position = content_rect.position
	button.size = content_rect.size

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
	for i in range(kingdom_frame_nodes.size()):
		kingdom_frame_nodes[i].texture = ACTIVE_CARD_FRAME_TEXTURE if i == selected_kingdom_index else INACTIVE_CARD_FRAME_TEXTURE
		var frame_rect := _get_kingdom_frame_rect(KINGDOM_CARD_RECTS[i])
		kingdom_frame_nodes[i].position = frame_rect.position
		kingdom_frame_nodes[i].size = frame_rect.size
		kingdom_frame_nodes[i].modulate = Color.WHITE
		kingdom_card_nodes[i].modulate = Color(1, 1, 1, 1) if i < 2 else Color(0.34, 0.34, 0.38, 0.72)
	button_kingdom_3.disabled = true

func _sync_selected_kingdom_from_settings():
	selected_kingdom_index = 1 if Settings.theme_id == "neon" else 0

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

func _on_kingdom_selected(kingdom_index: int):
	if kingdom_index >= 2:
		return
	selected_kingdom_index = kingdom_index
	Settings.set_theme_id("neon" if kingdom_index == 1 else "default")
	_update_kingdom_selection()

func _on_kingdom_pressed(kingdom_index: int):
	if kingdom_index >= 2:
		return
	var press_msec := Time.get_ticks_msec()
	var is_double_press := last_kingdom_press_index == kingdom_index and press_msec - last_kingdom_press_msec <= KINGDOM_DOUBLE_PRESS_MS
	_on_kingdom_selected(kingdom_index)
	last_kingdom_press_index = kingdom_index
	last_kingdom_press_msec = press_msec
	if is_double_press:
		_play_selected_kingdom(kingdom_index)

func _handle_kingdom_pointer_input(event: InputEvent) -> bool:
	if kingdom_scroll == null or kingdom_design_root == null:
		return false
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var local_position := _get_kingdom_scroll_local_position(event.position)
		if not kingdom_drag_active and not _is_position_in_kingdom_scroll(local_position):
			return false
		if event.pressed:
			_start_kingdom_drag(local_position)
			if event.double_click and kingdom_drag_start_index >= 0:
				_on_kingdom_selected(kingdom_drag_start_index)
				_play_selected_kingdom(kingdom_drag_start_index)
		else:
			_finish_kingdom_drag()
		return true
	elif event is InputEventMouseButton and (event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN):
		var local_position := _get_kingdom_scroll_local_position(event.position)
		if not _is_position_in_kingdom_scroll(local_position):
			return false
		var wheel_delta := -64 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 64
		kingdom_scroll.scroll_vertical += wheel_delta
		return true
	elif event is InputEventMouseMotion and kingdom_drag_active:
		_update_kingdom_drag(_get_kingdom_scroll_local_position(event.position))
		return true
	elif event is InputEventScreenTouch:
		var local_position := _get_kingdom_scroll_local_position(event.position)
		if not kingdom_drag_active and not _is_position_in_kingdom_scroll(local_position):
			return false
		if event.pressed:
			_start_kingdom_drag(local_position)
			# Custom double tap detection for mobile to ensure consistency
			if _is_double_tap(event) and kingdom_drag_start_index >= 0:
				_on_kingdom_selected(kingdom_drag_start_index)
				_play_selected_kingdom(kingdom_drag_start_index)
		else:
			_finish_kingdom_drag()
		return true
	elif event is InputEventScreenDrag and kingdom_drag_active:
		_update_kingdom_drag(_get_kingdom_scroll_local_position(event.position))
		return true
	return false

func _get_kingdom_scroll_local_position(viewport_position: Vector2) -> Vector2:
	return kingdom_scroll.get_global_transform().affine_inverse() * viewport_position

func _is_position_in_kingdom_scroll(local_position: Vector2) -> bool:
	return Rect2(Vector2.ZERO, kingdom_scroll.size).has_point(local_position)

func _start_kingdom_drag(local_position: Vector2):
	kingdom_drag_active = true
	kingdom_drag_moved = false
	kingdom_drag_start_position = local_position
	kingdom_drag_start_scroll = kingdom_scroll.scroll_vertical
	kingdom_drag_start_index = _get_kingdom_index_from_scroll_position(local_position)

func _update_kingdom_drag(local_position: Vector2):
	var drag_delta := local_position - kingdom_drag_start_position
	if absf(drag_delta.y) > KINGDOM_DRAG_CLICK_THRESHOLD:
		kingdom_drag_moved = true
	kingdom_scroll.scroll_vertical = kingdom_drag_start_scroll - int(drag_delta.y)

func _finish_kingdom_drag():
	if kingdom_drag_active and not kingdom_drag_moved and kingdom_drag_start_index >= 0:
		_on_kingdom_selected(kingdom_drag_start_index)
	kingdom_drag_active = false
	kingdom_drag_start_index = -1

func _get_kingdom_index_from_scroll_position(local_position: Vector2) -> int:
	var content_position := local_position + Vector2(float(kingdom_scroll.scroll_horizontal), float(kingdom_scroll.scroll_vertical))
	for i in range(KINGDOM_CARD_RECTS.size()):
		if _get_kingdom_frame_rect(KINGDOM_CARD_RECTS[i]).has_point(content_position):
			return i
	return -1

func _play_selected_kingdom(kingdom_index: int):
	if kingdom_index >= 2:
		return
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

func _is_double_tap(event: InputEventScreenTouch) -> bool:
	# For mobile devices, we implement our own double tap detection
	# to ensure consistent behavior across platforms
	if event.pressed:
		var current_msec := Time.get_ticks_msec()
		var time_diff := current_msec - last_touch_msec
		var position_diff := event.position.distance_to(last_touch_position)
		
		# Check if this is a double tap: within threshold time and close position
		if time_diff <= KINGDOM_DOUBLE_PRESS_MS and position_diff <= KINGDOM_DOUBLE_TAP_POSITION_TOLERANCE:
			last_touch_msec = 0
			last_touch_position = Vector2.ZERO
			return true
		
		# Update last touch info for next comparison
		last_touch_msec = current_msec
		last_touch_position = event.position
	
	return false

func _input(event: InputEvent):
	if not event.is_action_pressed("ui_cancel"):
		return

	if settings_panel.visible:
		settings_panel.visible = false
		return

	if how_to_play_panel.visible:
		how_to_play_panel.visible = false
		return

func _unhandled_input(event: InputEvent):
	if not settings_panel.visible and not how_to_play_panel.visible and _handle_kingdom_pointer_input(event):
		get_viewport().set_input_as_handled()
