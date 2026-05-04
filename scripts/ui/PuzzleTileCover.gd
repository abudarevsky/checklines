extends Control
class_name PuzzleTileCover

var cover_color: Color = Color(0.16, 0.12, 0.07, 0.88)
var outline_color: Color = Color(0.72, 0.54, 0.26, 0.58)
var shadow_color: Color = Color(0.0, 0.0, 0.0, 0.24)
var column: int = 0
var row: int = 0
var columns: int = 1
var rows: int = 1

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func setup(
	tile_column: int,
	tile_row: int,
	total_columns: int,
	total_rows: int,
	fill_color: Color
):
	column = tile_column
	row = tile_row
	columns = total_columns
	rows = total_rows
	cover_color = _paper_cover_color(fill_color)
	queue_redraw()

func _draw():
	var rect := Rect2(Vector2.ZERO, size)
	if rect.size.x <= 2.0 or rect.size.y <= 2.0:
		return

	var points := _build_piece_points(rect)
	var shadow_points := PackedVector2Array()
	for point in points:
		shadow_points.append(point + Vector2(1.5, 2.0))
	draw_colored_polygon(shadow_points, shadow_color)
	draw_colored_polygon(points, cover_color)
	draw_polyline(points + PackedVector2Array([points[0]]), outline_color, 1.6, true)

	var highlight := Color(1.0, 0.86, 0.48, 0.10)
	draw_line(Vector2(rect.position.x + 4.0, rect.position.y + 4.0), Vector2(rect.end.x - 4.0, rect.position.y + 4.0), highlight, 1.0)
	draw_line(Vector2(rect.position.x + 4.0, rect.position.y + 4.0), Vector2(rect.position.x + 4.0, rect.end.y - 4.0), highlight, 1.0)

func _paper_cover_color(theme_color: Color) -> Color:
	if theme_color.a <= 0.0:
		return cover_color
	return Color(
		maxf(theme_color.r, 0.15),
		maxf(theme_color.g, 0.11),
		maxf(theme_color.b, 0.06),
		maxf(theme_color.a, 0.84)
	)

func _build_piece_points(rect: Rect2) -> PackedVector2Array:
	var points := PackedVector2Array()
	var left := rect.position.x
	var top := rect.position.y
	var right := rect.end.x
	var bottom := rect.end.y
	var tab_radius: float = minf(rect.size.x, rect.size.y) * 0.13
	var tab_center_x: float = (left + right) * 0.5
	var tab_center_y: float = (top + bottom) * 0.5

	points.append(Vector2(left, top))
	_append_horizontal_edge(points, left, right, top, tab_center_x, tab_radius, _top_connector_direction())
	points.append(Vector2(right, top))
	_append_vertical_edge(points, top, bottom, right, tab_center_y, tab_radius, _right_connector_direction())
	points.append(Vector2(right, bottom))
	_append_horizontal_edge(points, right, left, bottom, tab_center_x, tab_radius, _bottom_connector_direction())
	points.append(Vector2(left, bottom))
	_append_vertical_edge(points, bottom, top, left, tab_center_y, tab_radius, _left_connector_direction())
	return points

func _append_horizontal_edge(
	points: PackedVector2Array,
	from_x: float,
	to_x: float,
	y: float,
	center_x: float,
	radius: float,
	direction: int
):
	var sign_x := 1.0 if to_x > from_x else -1.0
	var start_x := center_x - radius * sign_x
	var end_x := center_x + radius * sign_x
	points.append(Vector2(start_x, y))
	if direction == 0:
		points.append(Vector2(end_x, y))
	else:
		var arc_steps := 8
		for i in range(arc_steps + 1):
			var t := float(i) / float(arc_steps)
			var angle := PI * t
			var x := start_x + (end_x - start_x) * t
			var y_offset := -sin(angle) * radius * float(direction)
			points.append(Vector2(x, y + y_offset))
	points.append(Vector2(to_x, y))

func _append_vertical_edge(
	points: PackedVector2Array,
	from_y: float,
	to_y: float,
	x: float,
	center_y: float,
	radius: float,
	direction: int
):
	var sign_y := 1.0 if to_y > from_y else -1.0
	var start_y := center_y - radius * sign_y
	var end_y := center_y + radius * sign_y
	points.append(Vector2(x, start_y))
	if direction == 0:
		points.append(Vector2(x, end_y))
	else:
		var arc_steps := 8
		for i in range(arc_steps + 1):
			var t := float(i) / float(arc_steps)
			var angle := PI * t
			var y := start_y + (end_y - start_y) * t
			var x_offset := sin(angle) * radius * float(direction)
			points.append(Vector2(x + x_offset, y))
	points.append(Vector2(x, to_y))

func _top_connector_direction() -> int:
	if row == 0:
		return 0
	return -1 if (column + row) % 2 == 0 else 1

func _right_connector_direction() -> int:
	if column >= columns - 1:
		return 0
	return 1 if (column + row) % 2 == 0 else -1

func _bottom_connector_direction() -> int:
	if row >= rows - 1:
		return 0
	return 1 if (column + row) % 2 == 0 else -1

func _left_connector_direction() -> int:
	if column == 0:
		return 0
	return -1 if (column + row) % 2 == 0 else 1
