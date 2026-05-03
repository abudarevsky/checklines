extends Control
class_name LineMetricBadge

@export_enum("color", "type") var badge_mode: String = "color":
	set(value):
		badge_mode = value
		queue_redraw()

var knight_texture: Texture2D
var quadrant_colors: Array[Color] = []
var tile_outline_color: Color = Color(0.08, 0.08, 0.08, 0.6)
var tile_background_color: Color = Color(0.92, 0.92, 0.92, 1.0)

func _ready():
	custom_minimum_size = Vector2(36.0, 36.0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_theme(_get_theme())

func _get_theme():
	var theme_manager = get_node_or_null("/root/ThemeManager")
	if theme_manager != null:
		return theme_manager.get_active_theme()
	return null

func apply_theme(theme):
	if theme == null:
		return
	quadrant_colors = [
		theme.orange_piece_color,
		theme.red_piece_color,
		theme.blue_piece_color,
		theme.green_piece_color,
	]
	tile_outline_color = theme.metric_outline_color
	tile_background_color = theme.metric_tile_background_color
	knight_texture = theme.knight_texture
	queue_redraw()

func _draw():
	var size_px := size
	if size_px.x <= 0.0 or size_px.y <= 0.0:
		return

	var tile_size := size_px * 0.5
	for index in range(4):
		var row := index / 2
		var column := index % 2
		var tile_rect := Rect2(Vector2(column, row) * tile_size, tile_size)
		draw_rect(tile_rect, tile_background_color)

		if badge_mode == "color":
			draw_rect(tile_rect.grow(-2.0), quadrant_colors[index])
		else:
			_draw_knight_quadrant(tile_rect.grow(-2.0), quadrant_colors[index])

	draw_line(Vector2(size_px.x * 0.5, 0.0), Vector2(size_px.x * 0.5, size_px.y), tile_outline_color, 1.5)
	draw_line(Vector2(0.0, size_px.y * 0.5), Vector2(size_px.x, size_px.y * 0.5), tile_outline_color, 1.5)
	draw_rect(Rect2(Vector2.ZERO, size_px), tile_outline_color, false, 2.0)

func _draw_knight_quadrant(rect: Rect2, tint: Color):
	draw_rect(rect, tint.darkened(0.78))
	if knight_texture == null:
		return

	var texture_size := knight_texture.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return

	var scale_factor := minf(rect.size.x / texture_size.x, rect.size.y / texture_size.y) * 0.82
	var draw_size := texture_size * scale_factor
	var draw_position := rect.position + (rect.size - draw_size) * 0.5
	draw_set_transform(draw_position, 0.0, Vector2(scale_factor, scale_factor))
	draw_texture(knight_texture, Vector2.ZERO, tint)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
