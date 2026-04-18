extends Node

signal settings_changed

@export var sound_enabled: bool = true
@export var vibration_enabled: bool = true
@export var dark_theme: bool = true

const SETTINGS_FILE := "user://settings.cfg"

func _ready():
	load_settings()

func save_settings():
	var config := ConfigFile.new()
	config.set_value("settings", "sound_enabled", sound_enabled)
	config.set_value("settings", "vibration_enabled", vibration_enabled)
	config.set_value("settings", "dark_theme", dark_theme)
	config.save(SETTINGS_FILE)

func load_settings():
	var config := ConfigFile.new()
	if config.load(SETTINGS_FILE) == OK:
		sound_enabled = config.get_value("settings", "sound_enabled", true)
		vibration_enabled = config.get_value("settings", "vibration_enabled", true)
		dark_theme = config.get_value("settings", "dark_theme", true)
		settings_changed.emit()

func toggle_sound():
	sound_enabled = not sound_enabled
	save_settings()
	settings_changed.emit()

func toggle_vibration():
	vibration_enabled = not vibration_enabled
	save_settings()
	settings_changed.emit()

func toggle_theme():
	dark_theme = not dark_theme
	save_settings()
	settings_changed.emit()