extends Node2D
class_name TrapMessageCloud

const CLOUD_SHADER := preload("res://shaders/trap_message_cloud.gdshader")
const BIG_SWAMP_TEXTURE := preload("res://assets/sprites/big_swamp.png")
const FLIGHT_DURATION: float = 1.55
const FADE_IN_DURATION: float = 0.18
const CENTER_HOLD_DURATION: float = 0.3
const FADE_OUT_DURATION: float = 0.52
const SWAMP_IMAGE_SIZE: Vector2 = Vector2(350.0, 350.0)
const ICON_SIZE: float = 86.0
const COFFIN_SIZE: Vector2 = Vector2(116.0, 104.0)
const TEXT_HEIGHT: float = 108.0
const TEXT_BOTTOM_MARGIN: float = 48.0

var cloud_rect: ColorRect
var shadow_rect: ColorRect
var border_rect: ColorRect
var swamp_image: TextureRect
var coffin_overlay: Polygon2D
var coffin_border: Line2D
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

	swamp_image = TextureRect.new()
	swamp_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	swamp_image.texture = _get_big_swamp_texture()
	swamp_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	swamp_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	swamp_image.position = Vector2(-SWAMP_IMAGE_SIZE.x * 0.5, cloud_rect.position.y + 18.0)
	swamp_image.size = SWAMP_IMAGE_SIZE
	add_child(swamp_image)

	var coffin_center := Vector2(78.0, cloud_rect.position.y + 322.0)
	coffin_overlay = Polygon2D.new()
	coffin_overlay.polygon = _get_coffin_points(COFFIN_SIZE)
	coffin_overlay.position = coffin_center
	coffin_overlay.color = _get_coffin_color(theme)
	add_child(coffin_overlay)

	coffin_border = Line2D.new()
	coffin_border.points = _get_closed_coffin_points(COFFIN_SIZE)
	coffin_border.position = coffin_center
	coffin_border.width = 5.0
	coffin_border.default_color = _get_border_color(theme)
	coffin_border.joint_mode = Line2D.LINE_JOINT_ROUND
	add_child(coffin_border)

	piece_icon = TextureRect.new()
	piece_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	piece_icon.position = coffin_center - Vector2(ICON_SIZE, ICON_SIZE) * 0.5 + Vector2(0.0, -2.0)
	piece_icon.size = Vector2(ICON_SIZE, ICON_SIZE)
	piece_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	piece_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	piece_icon.modulate = _get_piece_color(theme, piece_color)
	if theme != null and piece_type >= 0:
		piece_icon.texture = theme.get_piece_texture(piece_type)
	add_child(piece_icon)

	message_label = Label.new()
	message_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	message_label.text = message
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	message_label.position = Vector2(cloud_rect.position.x + 24.0, cloud_rect.position.y + cloud_size.y - TEXT_HEIGHT - TEXT_BOTTOM_MARGIN)
	message_label.size = Vector2(cloud_size.x - 48.0, TEXT_HEIGHT)
	message_label.add_theme_font_override("font", _get_message_font(theme))
	message_label.add_theme_color_override("font_color", _get_text_color(theme))
	message_label.add_theme_color_override("font_outline_color", _get_text_outline_color(theme))
	message_label.add_theme_constant_override("outline_size", 9)
	message_label.add_theme_font_size_override("font_size", _get_font_size(theme))
	add_child(message_label)

func _build_cloud_rect(size: Vector2, offset: Vector2, color: Color) -> ColorRect:
	var rect := ColorRect.new()
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.position = -size * 0.5 + offset
	rect.size = size
	rect.color = Color.WHITE
	var cloud_material := ShaderMaterial.new()
	cloud_material.shader = CLOUD_SHADER
	cloud_material.set_shader_parameter("cloud_color", color)
	rect.material = cloud_material
	return rect

func _get_cloud_size(message: String) -> Vector2:
	return Vector2(430.0, 500.0)

func _get_cloud_color(theme: Resource) -> Color:
	if theme != null:
		return theme.hud_panel_color
	return Color(0.08, 0.1, 0.13, 0.92)

func _get_text_color(theme: Resource) -> Color:
	if theme != null:
		return theme.hud_primary_text_color
	return Color.WHITE

func _get_piece_color(theme: Resource, piece_color: int) -> Color:
	if theme != null and piece_color >= 0:
		return theme.get_piece_color(piece_color)
	return _get_text_color(theme)

func _get_coffin_color(theme: Resource) -> Color:
	var color := _get_cloud_color(theme).darkened(0.45)
	color.a = 0.88
	return color

func _get_text_outline_color(theme: Resource) -> Color:
	if theme != null:
		return theme.hud_outline_color
	return Color(0.0, 0.0, 0.0, 0.72)

func _get_border_color(theme: Resource) -> Color:
	var color := _get_cloud_color(theme).darkened(0.55)
	color.a = 0.98
	return color

func _get_shadow_color() -> Color:
	return Color(0.0, 0.0, 0.0, 0.42)

func _get_font_size(theme: Resource) -> int:
	if theme != null:
		return int(round(float(clampi(theme.puzzle_message_font_size + 8, 36, 44)) * 1.2))
	return 46

func _get_message_font(theme: Resource) -> Font:
	if theme != null:
		var theme_font := _load_font_file(theme.menu_body_font_path)
		if theme_font != null:
			return theme_font
		var system_font := SystemFont.new()
		system_font.font_names = theme.dialog_font_names
		system_font.font_weight = theme.puzzle_message_font_weight
		return system_font
	return ThemeDB.fallback_font

func _load_font_file(font_path: String) -> FontFile:
	if font_path.strip_edges().is_empty():
		return null
	var font := FontFile.new()
	if font.load_dynamic_font(font_path) != OK:
		return null
	return font

func _get_big_swamp_texture() -> Texture2D:
	return BIG_SWAMP_TEXTURE

func _get_coffin_points(size: Vector2) -> PackedVector2Array:
	var half_width := size.x * 0.5
	var half_height := size.y * 0.5
	var shoulder_y := -half_height + size.y * 0.27
	return PackedVector2Array([
		Vector2(0.0, -half_height),
		Vector2(half_width * 0.74, shoulder_y),
		Vector2(half_width, half_height),
		Vector2(-half_width, half_height),
		Vector2(-half_width * 0.74, shoulder_y)
	])

func _get_closed_coffin_points(size: Vector2) -> PackedVector2Array:
	var points := _get_coffin_points(size)
	points.append(points[0])
	return points

func _play(to: Vector2):
	z_index = 120
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
