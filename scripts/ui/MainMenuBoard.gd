extends Control

var cell_size: int = GameManager.CELL_SIZE
var board_color_light: Color = Color(0.34, 0.34, 0.34)
var board_color_dark: Color = Color(0.22, 0.22, 0.22)
var overlay_color: Color = Color(0, 0, 0, 0.75)
var background_texture: Texture2D

func _ready():
	apply_theme(_get_theme())
	resized.connect(queue_redraw)
	queue_redraw()

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
	board_color_light = theme_data.menu_checker_light_color
	board_color_dark = theme_data.menu_checker_dark_color
	overlay_color = theme_data.menu_overlay_color
	background_texture = theme_data.menu_background_texture
	queue_redraw()

func _draw():
	if size.x == 0 or size.y == 0:
		return
	if background_texture != null:
		_draw_cover_texture(background_texture)
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
	draw_rect(Rect2(Vector2.ZERO, size), overlay_color)

func _draw_cover_texture(texture: Texture2D):
	var texture_size := texture.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return
	var scale_factor := maxf(size.x / texture_size.x, size.y / texture_size.y)
	var draw_size := texture_size * scale_factor
	var draw_position := (size - draw_size) * 0.5
	draw_texture_rect(texture, Rect2(draw_position, draw_size), false)
