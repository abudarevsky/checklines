extends Node2D
class_name TrapMessageCloud

const CLOUD_SHADER := preload("res://shaders/trap_message_cloud.gdshader")
const FLIGHT_DURATION: float = 1.55
const FADE_IN_DURATION: float = 0.18
const CENTER_HOLD_DURATION: float = 0.3
const FADE_OUT_DURATION: float = 0.52
const ICON_SIZE: float = 54.0

var cloud_rect: ColorRect
var shadow_rect: ColorRect
var border_rect: ColorRect
var piece_icon: TextureRect
var message_label: Label
var shader_material: ShaderMaterial

func setup(message: String, from: Vector2, to: Vector2, theme: Resource, piece_type: int = -1, piece_color: int = -1):
	position = from
	_build_cloud(message, theme, piece_type, piece_color)
	_play(to)

func _build_cloud(message: String, theme: Resource, piece_type: int, piece_color: int):
	var cloud_size := _get_cloud_size(message)
	shadow_rect = _build_cloud_rect(cloud_size, Vector2(10.0, 12.0), _get_shadow_color())
	add_child(shadow_rect)

	border_rect = _build_cloud_rect(cloud_size + Vector2(12.0, 12.0), Vector2.ZERO, _get_border_color(theme))
	add_child(border_rect)

	cloud_rect = ColorRect.new()
	cloud_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cloud_rect.position = -cloud_size * 0.5
	cloud_rect.size = cloud_size
	cloud_rect.color = Color.WHITE

	shader_material = ShaderMaterial.new()
	shader_material.shader = CLOUD_SHADER
	shader_material.set_shader_parameter("cloud_color", _get_cloud_color(theme))
	cloud_rect.material = shader_material
	add_child(cloud_rect)

	piece_icon = TextureRect.new()
	piece_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	piece_icon.position = cloud_rect.position + Vector2(30.0, (cloud_size.y - ICON_SIZE) * 0.5)
	piece_icon.size = Vector2(ICON_SIZE, ICON_SIZE)
	piece_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	piece_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	piece_icon.modulate = _get_text_color(theme)
	if theme != null and piece_type >= 0:
		piece_icon.texture = theme.get_piece_texture(piece_type)
	add_child(piece_icon)

	message_label = Label.new()
	message_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	message_label.text = message
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	message_label.position = cloud_rect.position + Vector2(100.0, 8.0)
	message_label.size = cloud_size - Vector2(126.0, 16.0)
	message_label.add_theme_color_override("font_color", _get_text_color(theme))
	message_label.add_theme_color_override("font_outline_color", _get_border_color(theme))
	message_label.add_theme_constant_override("outline_size", 5)
	message_label.add_theme_font_size_override("font_size", _get_font_size(theme))
	add_child(message_label)

func _build_cloud_rect(size: Vector2, offset: Vector2, color: Color) -> ColorRect:
	var rect := ColorRect.new()
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.position = -size * 0.5 + offset
	rect.size = size
	rect.color = Color.WHITE
	var material := ShaderMaterial.new()
	material.shader = CLOUD_SHADER
	material.set_shader_parameter("cloud_color", color)
	rect.material = material
	return rect

func _get_cloud_size(message: String) -> Vector2:
	var width := clampf(float(message.length()) * 16.0 + 150.0, 380.0, 760.0)
	return Vector2(width, 102.0)

func _get_cloud_color(theme: Resource) -> Color:
	if theme != null:
		var color: Color = theme.board_cell_dark_color
		color.a = 0.95
		return color
	return Color(0.1, 0.12, 0.16, 0.95)

func _get_text_color(theme: Resource) -> Color:
	if theme != null:
		var color: Color = theme.board_cell_light_color
		color = color.lightened(0.45)
		color.a = 1.0
		return color
	return Color.WHITE

func _get_border_color(theme: Resource) -> Color:
	var color := _get_cloud_color(theme).darkened(0.55)
	color.a = 0.98
	return color

func _get_shadow_color() -> Color:
	return Color(0.0, 0.0, 0.0, 0.42)

func _get_font_size(theme: Resource) -> int:
	if theme != null:
		return clampi(theme.puzzle_message_font_size + 2, 28, 34)
	return 30

func _play(to: Vector2):
	z_index = 80
	scale = Vector2(0.82, 0.82)
	modulate.a = 0.0

	var move_tween := create_tween()
	move_tween.set_parallel(true)
	move_tween.tween_property(self, "position", to, FLIGHT_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	move_tween.tween_property(self, "scale", Vector2.ONE, 0.26).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	move_tween.tween_property(self, "rotation", randf_range(-0.04, 0.04), FLIGHT_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	var fade_tween := create_tween()
	fade_tween.tween_property(self, "modulate:a", 1.0, FADE_IN_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	fade_tween.tween_interval(maxf(0.0, FLIGHT_DURATION - FADE_IN_DURATION + CENTER_HOLD_DURATION))
	fade_tween.tween_property(self, "modulate:a", 0.0, FADE_OUT_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	fade_tween.finished.connect(queue_free)
