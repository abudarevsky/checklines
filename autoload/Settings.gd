extends Node

signal settings_changed

@export var sound_enabled: bool = true
@export var vibration_enabled: bool = true
@export var theme_id: String = "neon"
@export var language_code: String = "en"

const SETTINGS_FILE := "user://settings.cfg"
const DEFAULT_THEME_ID := "default"
const NEON_THEME_ID := "neon"
const DEFAULT_LANGUAGE_CODE := "en"
const LANGUAGE_CODES := ["en", "ru", "de", "fr", "es", "fi", "sv"]

func _ready():
	load_settings()

func save_settings():
	var config := ConfigFile.new()
	config.set_value("settings", "sound_enabled", sound_enabled)
	config.set_value("settings", "vibration_enabled", vibration_enabled)
	config.set_value("settings", "theme_id", theme_id)
	config.set_value("settings", "language_code", language_code)
	config.save(SETTINGS_FILE)

func load_settings():
	var config := ConfigFile.new()
	if config.load(SETTINGS_FILE) == OK:
		sound_enabled = config.get_value("settings", "sound_enabled", true)
		vibration_enabled = config.get_value("settings", "vibration_enabled", true)
		if config.has_section_key("settings", "theme_id"):
			theme_id = _normalize_theme_id(str(config.get_value("settings", "theme_id", NEON_THEME_ID)))
		else:
			var legacy_dark_theme: bool = config.get_value("settings", "dark_theme", true)
			theme_id = NEON_THEME_ID if legacy_dark_theme else DEFAULT_THEME_ID
		theme_id = _normalize_theme_id(theme_id)
		language_code = _normalize_language_code(str(config.get_value("settings", "language_code", DEFAULT_LANGUAGE_CODE)))
		settings_changed.emit()
	else:
		language_code = _get_system_language_code()

func toggle_sound():
	sound_enabled = not sound_enabled
	save_settings()
	settings_changed.emit()

func toggle_vibration():
	vibration_enabled = not vibration_enabled
	save_settings()
	settings_changed.emit()

func toggle_theme():
	if theme_id == NEON_THEME_ID:
		theme_id = DEFAULT_THEME_ID
	else:
		theme_id = NEON_THEME_ID
	save_settings()
	settings_changed.emit()

func set_theme_id(new_theme_id: String):
	var normalized_theme_id := _normalize_theme_id(new_theme_id)
	if normalized_theme_id == theme_id:
		return

	theme_id = normalized_theme_id
	save_settings()
	settings_changed.emit()

func set_language_code(new_language_code: String):
	var normalized_language_code := _normalize_language_code(new_language_code)
	if normalized_language_code == language_code:
		return

	language_code = normalized_language_code
	save_settings()
	settings_changed.emit()

func _normalize_theme_id(value: String) -> String:
	if value == DEFAULT_THEME_ID or value == NEON_THEME_ID:
		return value
	return NEON_THEME_ID

func _normalize_language_code(value: String) -> String:
	if value in LANGUAGE_CODES:
		return value
	return DEFAULT_LANGUAGE_CODE

func _get_system_language_code() -> String:
	var locale_language := OS.get_locale_language()
	return _normalize_language_code(locale_language)
