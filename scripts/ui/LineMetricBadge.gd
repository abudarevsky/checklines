extends Control
class_name LineMetricBadge

@export_enum("color", "type") var badge_mode: String = "color":
	set(value):
		badge_mode = value
		queue_redraw()

var knight_texture: Texture2D
var quadrant_colors: Array[Color] = []
var tile_background_color: Color = Color(0.92, 0.92, 0.92, 1.0)
var icon_color: Color = Color(0.05, 0.05, 0.05, 1.0)

func _ready():
	custom_minimum_size = Vector2(46.0, 36.0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_theme(_get_theme())

func _get_theme():
	var main_loop: MainLoop = Engine.get_main_loop()
	if main_loop is SceneTree:
		var root: Window = main_loop.root
		var theme_manager = root.get_node_or_null("ThemeManager")
		if theme_manager != null:
			return theme_manager.get_active_theme()
	return null

func apply_theme(theme_data):
	if theme_data == null:
		return
	quadrant_colors = [
		theme_data.orange_piece_color,
		theme_data.red_piece_color,
		theme_data.blue_piece_color,
		theme_data.green_piece_color,
	]
	tile_background_color = theme_data.metric_tile_background_color
	icon_color = theme_data.hud_primary_text_color
	knight_texture = theme_data.knight_texture
	queue_redraw()

func _draw():
	var size_px := size
	if size_px.x <= 0.0 or size_px.y <= 0.0:
		return

	if badge_mode == "type":
		_draw_type_badge(Rect2(Vector2.ZERO, size_px))
		return

	_draw_color_badge(Rect2(Vector2.ZERO, size_px))

func _draw_color_badge(rect: Rect2):
	var icon_rect := rect.grow(-4.0)
	var square_size := minf(icon_rect.size.y, icon_rect.size.x * 0.5)
	var total_width := square_size * 2.0
	var start := icon_rect.position + Vector2(
		(icon_rect.size.x - total_width) * 0.5,
		(icon_rect.size.y - square_size) * 0.5
	)

	for index in range(2):
		var square_rect := Rect2(start + Vector2(square_size * float(index), 0.0), Vector2(square_size, square_size))
		draw_rect(square_rect, tile_background_color)
		draw_rect(square_rect.grow(-2.0), quadrant_colors[index % quadrant_colors.size()])

func _draw_type_badge(rect: Rect2):
	_draw_knight_icon(rect.grow(-4.0), icon_color)

func _draw_knight_icon(rect: Rect2, tint: Color):
	if knight_texture == null:
		return

	var texture_size := knight_texture.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return

	var scale_factor := minf(rect.size.x / texture_size.x, rect.size.y / texture_size.y) * 0.9
	var draw_size := texture_size * scale_factor
	var draw_position := rect.position + (rect.size - draw_size) * 0.5
	draw_set_transform(draw_position, 0.0, Vector2(scale_factor, scale_factor))
	draw_texture(knight_texture, Vector2.ZERO, tint)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
