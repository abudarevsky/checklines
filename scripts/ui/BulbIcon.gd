extends Control
class_name BulbIcon

@export var icon_color: Color = Color(0.96, 0.91, 0.78, 1.0):
	set(value):
		icon_color = value
		queue_redraw()

func _draw():
	var center := Vector2(size.x * 0.5, size.y * 0.38)
	var radius := minf(size.x, size.y) * 0.22
	draw_circle(center, radius, icon_color)

	var neck_width := radius * 0.9
	var neck_height := radius * 0.65
	var neck_pos := Vector2(center.x - neck_width * 0.5, center.y + radius * 0.45)
	draw_rect(Rect2(neck_pos, Vector2(neck_width, neck_height)), icon_color)

	var base_width := radius * 1.1
	var base_y := neck_pos.y + neck_height + radius * 0.18
	for i in range(3):
		var y := base_y + float(i) * radius * 0.28
		draw_line(
			Vector2(center.x - base_width * 0.5, y),
			Vector2(center.x + base_width * 0.5, y),
			icon_color,
			maxf(2.0, radius * 0.12)
		)
