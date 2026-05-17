extends Node

signal settings_changed

@export var sound_enabled: bool = true
@export var vibration_enabled: bool = true
@export var theme_id: String = "neon"
@export var language_code: String = "en"
@export var kingdom_progress_levels: Dictionary = {}
@export var kingdom_clean_turn_stats: Dictionary = {}

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
	config.set_value("progress", "kingdom_levels", kingdom_progress_levels)
	config.set_value("progress", "kingdom_clean_turn_stats", kingdom_clean_turn_stats)
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
		kingdom_progress_levels = _normalize_kingdom_progress_levels(config.get_value("progress", "kingdom_levels", {}))
		kingdom_clean_turn_stats = _normalize_kingdom_clean_turn_stats(config.get_value("progress", "kingdom_clean_turn_stats", {}))
		settings_changed.emit()
	else:
		language_code = _get_system_language_code()
		kingdom_progress_levels = {}
		kingdom_clean_turn_stats = {}

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

func get_kingdom_max_completed_level(kingdom_id: String) -> int:
	return maxi(int(kingdom_progress_levels.get(kingdom_id, 0)), 0)

func get_kingdom_best_level_display(kingdom_id: String) -> int:
	return maxi(get_kingdom_max_completed_level(kingdom_id), 1)

func get_kingdom_menu_image_level_index(kingdom_id: String) -> int:
	return maxi(get_kingdom_max_completed_level(kingdom_id) - 2, 0)

func record_kingdom_completed_level(kingdom_id: String, completed_level_number: int):
	if kingdom_id.is_empty():
		return

	var normalized_level := maxi(completed_level_number, 0)
	if normalized_level <= get_kingdom_max_completed_level(kingdom_id):
		return

	kingdom_progress_levels[kingdom_id] = normalized_level
	save_settings()
	settings_changed.emit()

func get_kingdom_progress_badge_tier(kingdom_id: String) -> int:
	return clampi(get_kingdom_max_completed_level(kingdom_id), 0, 3)

func record_kingdom_clean_turn_session(kingdom_id: String, clean_turns: int, total_turns: int):
	if kingdom_id.is_empty() or total_turns <= 0:
		return

	var current_best := get_kingdom_best_clean_turn_percent(kingdom_id)
	var session_percent := float(clean_turns) / float(total_turns) * 100.0
	if session_percent <= current_best:
		return

	kingdom_clean_turn_stats[kingdom_id] = {
		"best_percent": session_percent,
		"clean_turns": maxi(clean_turns, 0),
		"total_turns": maxi(total_turns, 0)
	}
	save_settings()
	settings_changed.emit()

func get_kingdom_best_clean_turn_percent(kingdom_id: String) -> float:
	var stats: Dictionary = kingdom_clean_turn_stats.get(kingdom_id, {})
	return maxf(float(stats.get("best_percent", 0.0)), 0.0)

func get_kingdom_tactical_badge_tier(kingdom_id: String) -> int:
	var best_percent := get_kingdom_best_clean_turn_percent(kingdom_id)
	if best_percent >= 25.0:
		return 3
	if best_percent >= 15.0:
		return 2
	if best_percent >= 5.0:
		return 1
	return 0

func _normalize_theme_id(value: String) -> String:
	if value == DEFAULT_THEME_ID or value == NEON_THEME_ID:
		return value
	return NEON_THEME_ID

func _normalize_language_code(value: String) -> String:
	if value in LANGUAGE_CODES:
		return value
	return DEFAULT_LANGUAGE_CODE

func _normalize_kingdom_progress_levels(value: Variant) -> Dictionary:
	var normalized: Dictionary = {}
	if value is not Dictionary:
		return normalized

	for raw_key in value.keys():
		var kingdom_id := str(raw_key)
		if kingdom_id.is_empty():
			continue
		normalized[kingdom_id] = maxi(int(value[raw_key]), 0)
	return normalized

func _normalize_kingdom_clean_turn_stats(value: Variant) -> Dictionary:
	var normalized: Dictionary = {}
	if value is not Dictionary:
		return normalized

	for raw_key in value.keys():
		var kingdom_id := str(raw_key)
		if kingdom_id.is_empty() or value[raw_key] is not Dictionary:
			continue
		var raw_stats: Dictionary = value[raw_key]
		normalized[kingdom_id] = {
			"best_percent": maxf(float(raw_stats.get("best_percent", 0.0)), 0.0),
			"clean_turns": maxi(int(raw_stats.get("clean_turns", 0)), 0),
			"total_turns": maxi(int(raw_stats.get("total_turns", 0)), 0)
		}
	return normalized

func _get_system_language_code() -> String:
	var locale_language := OS.get_locale_language()
	return _normalize_language_code(locale_language)
