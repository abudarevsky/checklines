extends Control

var cell_size: int = GameManager.CELL_SIZE
var board_color_light: Color = Color(0.34, 0.34, 0.34)
var board_color_dark: Color = Color(0.22, 0.22, 0.22)

func _ready():
	resized.connect(queue_redraw)
	queue_redraw()

func _draw():
	if size.x == 0 or size.y == 0:
		return
	
	var total_cells_width := int(ceil(size.x / cell_size)) + 1
	var total_cells_height := int(ceil(size.y / cell_size)) + 1
	
	# Draw checkerboard
	for y in range(total_cells_height):
		for x in range(total_cells_width):
			var is_light := (x + y) % 2 == 0
			var color := board_color_light if is_light else board_color_dark
			var cell_rect := Rect2(x * cell_size, y * cell_size, cell_size, cell_size)
			draw_rect(cell_rect, color)
	
	# Dark overlay
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.75))
