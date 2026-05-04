extends Node

const DEFAULT_THEME_PATH := "res://themes/default_theme.tres"
const NEON_THEME_PATH := "res://themes/neon_theme.tres"
const DEFAULT_THEME_ID := "default"
const NEON_THEME_ID := "neon"

var active_theme = null
var active_theme_id: String = ""

signal theme_changed(theme_data, theme_id)

func _ready():
	if Settings.settings_changed.is_connected(_on_settings_changed):
		Settings.settings_changed.disconnect(_on_settings_changed)
	Settings.settings_changed.connect(_on_settings_changed)
	_reload_active_theme()

func get_active_theme():
	return active_theme

func get_active_theme_id() -> String:
	return active_theme_id

func get_theme_display_name(theme_id: String) -> String:
	match theme_id:
		DEFAULT_THEME_ID:
			return "Default"
		NEON_THEME_ID:
			return "Neon"
	return "Default"

func get_available_theme_ids() -> PackedStringArray:
	return PackedStringArray([DEFAULT_THEME_ID, NEON_THEME_ID])

func set_active_theme_id(theme_id: String):
	Settings.set_theme_id(theme_id)

func get_piece_texture(piece_type: int) -> Texture2D:
	return active_theme.get_piece_texture(piece_type)

func get_piece_color(piece_color: int) -> Color:
	return active_theme.get_piece_color(piece_color)

func get_border_color(piece_color: int) -> Color:
	return active_theme.get_border_color(piece_color)

func _on_settings_changed():
	_reload_active_theme()

func _reload_active_theme():
	var requested_theme_id := Settings.theme_id if Settings.theme_id != "" else NEON_THEME_ID
	if requested_theme_id != DEFAULT_THEME_ID and requested_theme_id != NEON_THEME_ID:
		requested_theme_id = NEON_THEME_ID

	if requested_theme_id == active_theme_id and active_theme != null:
		return

	var theme_path := NEON_THEME_PATH if requested_theme_id == NEON_THEME_ID else DEFAULT_THEME_PATH
	var loaded_theme = load(theme_path)
	if loaded_theme == null:
		loaded_theme = load(DEFAULT_THEME_PATH)
		requested_theme_id = DEFAULT_THEME_ID

	active_theme = loaded_theme
	active_theme_id = requested_theme_id
	theme_changed.emit(active_theme, active_theme_id)
