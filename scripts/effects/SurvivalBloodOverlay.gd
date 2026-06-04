extends Control
class_name SurvivalBloodOverlay

var drop_offsets: Array[Vector2] = []
var fall_progress: float = 0.0
var drop_color: Color = Color(0.55, 0.0, 0.0, 0.82)

const DROP_COUNT: int = 18
const FALL_SPEED: float = 0.22

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_drops()
	set_process(false)

func start():
	if drop_offsets.is_empty():
		_build_drops()
	fall_progress = 0.0
	visible = true
	set_process(true)
	queue_redraw()

func stop():
	visible = false
	set_process(false)

func _process(delta: float):
	fall_progress = fposmod(fall_progress + delta * FALL_SPEED, 1.0)
	queue_redraw()

func _notification(what: int):
	if what == NOTIFICATION_RESIZED:
		_build_drops()

func _draw():
	if not visible:
		return
	var overlay_size := size
	if overlay_size.x <= 0.0 or overlay_size.y <= 0.0:
		return

	for i in range(drop_offsets.size()):
		var offset := drop_offsets[i]
		var y := fposmod(offset.y + fall_progress + float(i % 5) * 0.12, 1.0) * overlay_size.y
		var x := offset.x * overlay_size.x
		var drop_size := 4.0 + float(i % 4) * 2.0
		var drop_alpha := 0.35 + float(i % 3) * 0.18
		var color := drop_color
		color.a = drop_alpha
		draw_circle(Vector2(x, y), drop_size, color)
		draw_line(
			Vector2(x, y - drop_size * 0.5),
			Vector2(x, y + drop_size * 2.5),
			color,
			maxf(1.0, drop_size * 0.42)
		)

func _build_drops():
	drop_offsets.clear()
	for i in range(DROP_COUNT):
		var x := fposmod(float(i * 37), 101.0) / 100.0
		var y := fposmod(float(i * 19), 97.0) / 96.0
		drop_offsets.append(Vector2(x, y))
