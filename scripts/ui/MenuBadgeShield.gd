extends Control
class_name MenuBadgeShield

enum Tier { EMPTY, BRONZE, SILVER, GOLD }
enum Kind { PROGRESSION, TACTICAL, CAMPAIGN }

var tier: int = Tier.EMPTY:
	set(value):
		tier = value
		queue_redraw()

var kind: int = Kind.PROGRESSION:
	set(value):
		kind = value
		queue_redraw()

var progress_level: int = 0:
	set(value):
		progress_level = maxi(value, 0)
		queue_redraw()

var survival_stars: int = 0:
	set(value):
		survival_stars = maxi(value, 0)
		queue_redraw()

func _draw():
	match kind:
		Kind.PROGRESSION:
			_draw_progression_band()
		Kind.TACTICAL:
			_draw_maltese_cross()
		Kind.CAMPAIGN:
			_draw_crown()

func _draw_progression_band():
	var points := PackedVector2Array([
		Vector2(size.x * 0.06, size.y * 0.30),
		Vector2(size.x * 0.20, size.y * 0.20),
		Vector2(size.x * 0.40, size.y * 0.28),
		Vector2(size.x * 0.62, size.y * 0.18),
		Vector2(size.x * 0.94, size.y * 0.28),
		Vector2(size.x * 0.88, size.y * 0.72),
		Vector2(size.x * 0.66, size.y * 0.64),
		Vector2(size.x * 0.46, size.y * 0.76),
		Vector2(size.x * 0.24, size.y * 0.66),
		Vector2(size.x * 0.10, size.y * 0.76)
	])
	_draw_glass_shape(points)
	if progress_level > 0:
		_draw_progress_level_mark()
	if survival_stars > 0:
		_draw_survival_stars()

func _draw_progress_level_mark():
	var level := clampi(progress_level, 0, 4)
	if level <= 0:
		return

	var stroke := maxf(size.y * 0.048, 4.0)
	var y_top := size.y * 0.33
	var y_bottom := size.y * 0.57
	var height := y_bottom - y_top
	var mark_color := Color(1.0, 0.96, 0.72, 0.98) if tier != Tier.EMPTY else Color(0.94, 0.97, 1.0, 0.72)
	var shadow := Color(0.0, 0.0, 0.0, 0.34)
	match level:
		1:
			_draw_roman_one(Vector2(size.x * 0.50, y_top), height, stroke, shadow)
			_draw_roman_one(Vector2(size.x * 0.50, y_top), height, stroke * 0.64, mark_color)
		2:
			for x in [size.x * 0.44, size.x * 0.56]:
				_draw_roman_one(Vector2(x, y_top), height, stroke, shadow)
				_draw_roman_one(Vector2(x, y_top), height, stroke * 0.64, mark_color)
		3:
			for x in [size.x * 0.40, size.x * 0.50, size.x * 0.60]:
				_draw_roman_one(Vector2(x, y_top), height, stroke, shadow)
				_draw_roman_one(Vector2(x, y_top), height, stroke * 0.64, mark_color)
		4:
			_draw_roman_one(Vector2(size.x * 0.36, y_top), height, stroke, shadow)
			_draw_roman_v(Vector2(size.x * 0.56, y_top), height, stroke, shadow)
			_draw_roman_one(Vector2(size.x * 0.36, y_top), height, stroke * 0.64, mark_color)
			_draw_roman_v(Vector2(size.x * 0.56, y_top), height, stroke * 0.64, mark_color)

func _draw_roman_one(top: Vector2, height: float, stroke: float, color: Color):
	draw_line(top, top + Vector2(0.0, height), color, stroke, true)

func _draw_roman_v(top: Vector2, height: float, stroke: float, color: Color):
	var left := top + Vector2(-size.x * 0.09, 0.0)
	var bottom := top + Vector2(0.0, height)
	var right := top + Vector2(size.x * 0.09, 0.0)
	draw_line(left, bottom, color, stroke, true)
	draw_line(bottom, right, color, stroke, true)

func _draw_survival_stars():
	var star_count := maxi(survival_stars, 1)
	var max_row_width := size.x * 0.72
	var radius := minf(size.y * 0.065, max_row_width / maxf(float(star_count) * 2.15, 1.0))
	radius = maxf(radius, size.y * 0.025)
	var gap := radius * 2.15
	if star_count > 1:
		gap = minf(gap, max_row_width / float(star_count - 1))
	var row_width := gap * float(star_count - 1)
	var center := Vector2((size.x - row_width) * 0.5, size.y * 0.66)
	for i in range(star_count):
		draw_colored_polygon(_get_star_points(center + Vector2(gap * i, 0.0), radius), Color(0.62, 0.95, 1.0, 0.96))

func _get_star_points(center: Vector2, outer_radius: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	var inner_radius := outer_radius * 0.44
	for i in range(10):
		var radius := outer_radius if i % 2 == 0 else inner_radius
		var angle := -PI * 0.5 + float(i) * PI / 5.0
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	return points

func _draw_maltese_cross():
	var points := PackedVector2Array([
		Vector2(size.x * 0.38, size.y * 0.06),
		Vector2(size.x * 0.62, size.y * 0.06),
		Vector2(size.x * 0.64, size.y * 0.34),
		Vector2(size.x * 0.94, size.y * 0.26),
		Vector2(size.x * 0.94, size.y * 0.50),
		Vector2(size.x * 0.66, size.y * 0.52),
		Vector2(size.x * 0.76, size.y * 0.94),
		Vector2(size.x * 0.50, size.y * 0.82),
		Vector2(size.x * 0.24, size.y * 0.94),
		Vector2(size.x * 0.34, size.y * 0.52),
		Vector2(size.x * 0.06, size.y * 0.50),
		Vector2(size.x * 0.06, size.y * 0.26),
		Vector2(size.x * 0.36, size.y * 0.34)
	])
	_draw_glass_shape(points)

func _draw_crown():
	var points := PackedVector2Array([
		Vector2(size.x * 0.10, size.y * 0.76),
		Vector2(size.x * 0.14, size.y * 0.30),
		Vector2(size.x * 0.34, size.y * 0.54),
		Vector2(size.x * 0.50, size.y * 0.16),
		Vector2(size.x * 0.66, size.y * 0.54),
		Vector2(size.x * 0.86, size.y * 0.30),
		Vector2(size.x * 0.90, size.y * 0.76)
	])
	_draw_glass_shape(points)
	draw_line(Vector2(size.x * 0.16, size.y * 0.84), Vector2(size.x * 0.84, size.y * 0.84), _get_edge_color(), 4.0, true)

func _draw_glass_shape(points: PackedVector2Array):
	var fill := _get_fill_color()
	var edge := _get_edge_color()
	draw_colored_polygon(points, fill)
	draw_polyline(points + PackedVector2Array([points[0]]), edge, 4.0, true)

	var highlight := PackedVector2Array([
		Vector2(size.x * 0.18, size.y * 0.18),
		Vector2(size.x * 0.82, size.y * 0.18),
		Vector2(size.x * 0.74, size.y * 0.30),
		Vector2(size.x * 0.26, size.y * 0.30)
	])
	draw_colored_polygon(highlight, Color(1, 1, 1, 0.10 if tier == Tier.EMPTY else 0.18))

func _get_fill_color() -> Color:
	match tier:
		Tier.BRONZE:
			return Color(0.44, 0.23, 0.10, 0.74)
		Tier.SILVER:
			return Color(0.64, 0.68, 0.74, 0.80)
		Tier.GOLD:
			return Color(0.88, 0.67, 0.18, 0.82)
	return Color(0.72, 0.76, 0.80, 0.16)

func _get_edge_color() -> Color:
	match tier:
		Tier.BRONZE:
			return Color(0.72, 0.48, 0.25, 0.78)
		Tier.SILVER:
			return Color(0.95, 0.97, 1.0, 0.84)
		Tier.GOLD:
			return Color(1.0, 0.87, 0.42, 0.88)
	return Color(0.94, 0.97, 1.0, 0.36)
