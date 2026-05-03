extends Node

const DEFAULT_THEME_PATH := "res://themes/default_theme.tres"

var active_theme = null

signal theme_changed(theme)

func _ready():
	active_theme = load(DEFAULT_THEME_PATH)

func get_active_theme():
	return active_theme

func get_piece_texture(piece_type: int) -> Texture2D:
	return active_theme.get_piece_texture(piece_type)

func get_piece_color(piece_color: int) -> Color:
	return active_theme.get_piece_color(piece_color)

func get_border_color(piece_color: int) -> Color:
	return active_theme.get_border_color(piece_color)
