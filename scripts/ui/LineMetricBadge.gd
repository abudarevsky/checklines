extends Control
class_name LineMetricBadge

@export_enum("color", "type", "level", "best") var badge_mode: String = "color":
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
	icon_color = theme_data.hud_secondary_text_color if badge_mode == "best" else theme_data.hud_primary_text_color
	knight_texture = theme_data.knight_texture
	queue_redraw()

func _draw():
	var size_px := size
	if size_px.x <= 0.0 or size_px.y <= 0.0:
		return

	if badge_mode == "type":
		_draw_type_badge(Rect2(Vector2.ZERO, size_px))
		return
	if badge_mode == "level":
		_draw_level_badge(Rect2(Vector2.ZERO, size_px))
		return
	if badge_mode == "best":
		_draw_best_badge(Rect2(Vector2.ZERO, size_px))
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

func _draw_level_badge(rect: Rect2):
	var badge_rect := rect.grow(-4.0)
	var box_size := minf(badge_rect.size.x, badge_rect.size.y)
	var box_rect := Rect2(
		badge_rect.position + (badge_rect.size - Vector2(box_size, box_size)) * 0.5,
		Vector2(box_size, box_size)
	)

	var ivory := Color(0.96, 0.91, 0.78, 1.0)
	var cutout_color := Color(0.03, 0.07, 0.12, 0.34)
	var corner_radius := int(maxf(4.0, box_size * 0.16))
	var background_style := StyleBoxFlat.new()
	background_style.bg_color = ivory
	background_style.corner_radius_top_left = corner_radius
	background_style.corner_radius_top_right = corner_radius
	background_style.corner_radius_bottom_left = corner_radius
	background_style.corner_radius_bottom_right = corner_radius
	background_style.anti_aliasing = true
	draw_style_box(background_style, box_rect)

	var inset := box_size * 0.24
	var cutout_width := maxf(4.0, box_size * 0.18)
	var x0 := box_rect.position.x
	var y0 := box_rect.position.y
	var x1 := box_rect.end.x
	var y1 := box_rect.end.y
	var cutout_x0 := x0 + inset
	var cutout_y0 := y0 + inset
	var cutout_y1 := y1 - inset
	var cutout_right := x1 - inset
	var horizontal_y0 := cutout_y1 - cutout_width

	draw_rect(Rect2(Vector2(cutout_x0, cutout_y0), Vector2(cutout_width, cutout_y1 - cutout_y0)), cutout_color)
	draw_rect(Rect2(Vector2(cutout_x0, horizontal_y0), Vector2(cutout_right - cutout_x0, cutout_width)), cutout_color)

	var border_width := int(maxf(2.0, box_size * 0.08))
	var border_style := StyleBoxFlat.new()
	border_style.bg_color = Color.TRANSPARENT
	border_style.border_color = icon_color
	border_style.border_width_left = border_width
	border_style.border_width_top = border_width
	border_style.border_width_right = border_width
	border_style.border_width_bottom = border_width
	border_style.corner_radius_top_left = corner_radius
	border_style.corner_radius_top_right = corner_radius
	border_style.corner_radius_bottom_left = corner_radius
	border_style.corner_radius_bottom_right = corner_radius
	border_style.anti_aliasing = true
	draw_style_box(border_style, box_rect)

func _draw_best_badge(rect: Rect2):
	var badge_rect := rect.grow(-5.0)
	var bar_gap := maxf(2.0, badge_rect.size.x * 0.06)
	var bar_width := (badge_rect.size.x - bar_gap * 2.0) / 3.0
	var baseline := badge_rect.end.y
	var heights := [
		badge_rect.size.y * 0.60,
		badge_rect.size.y * 0.74,
		badge_rect.size.y * 0.66,
	]
	for i in range(3):
		var bar_height: float = heights[i]
		var bar_rect := Rect2(
			Vector2(badge_rect.position.x + float(i) * (bar_width + bar_gap), baseline - bar_height),
			Vector2(bar_width, bar_height)
		)
		var style := StyleBoxFlat.new()
		style.bg_color = tile_background_color
		style.border_color = icon_color
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
		style.corner_radius_top_left = 3
		style.corner_radius_top_right = 3
		style.anti_aliasing = true
		draw_style_box(style, bar_rect)

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
