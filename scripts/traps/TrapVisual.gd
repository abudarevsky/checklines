extends Node2D
class_name TrapVisual

const TRAP_SHADER := preload("res://shaders/trap_cell_waves.gdshader")
const SPARKLE_COUNT := 5
const SPARKLE_COLOR := Color(1.0, 0.78, 0.25, 0.95)

class TrapCornerMarks:
	extends Node2D

	var cell_size: float = GameManager.CELL_SIZE
	var corner_colors: Array[Color] = []

	func setup(size: float, colors: Array[Color]):
		cell_size = size
		corner_colors = colors
		queue_redraw()

	func _draw():
		if corner_colors.size() < 4:
			return
		var length := cell_size * 0.2
		var thickness := maxf(2.0, cell_size * 0.055)
		var max_pos := cell_size - thickness
		_draw_corner(Vector2.ZERO, Vector2.RIGHT, Vector2.DOWN, length, thickness, corner_colors[0])
		_draw_corner(Vector2(max_pos, 0.0), Vector2.LEFT, Vector2.DOWN, length, thickness, corner_colors[1])
		_draw_corner(Vector2(max_pos, max_pos), Vector2.LEFT, Vector2.UP, length, thickness, corner_colors[2])
		_draw_corner(Vector2(0.0, max_pos), Vector2.RIGHT, Vector2.UP, length, thickness, corner_colors[3])

	func _draw_corner(origin: Vector2, horizontal_dir: Vector2, vertical_dir: Vector2, length: float, thickness: float, color: Color):
		var horizontal_origin := origin
		if horizontal_dir.x < 0.0:
			horizontal_origin.x -= length - thickness
		if vertical_dir.y < 0.0:
			horizontal_origin.y -= 0.0
		draw_rect(Rect2(horizontal_origin, Vector2(length, thickness)), color)

		var vertical_origin := origin
		if vertical_dir.y < 0.0:
			vertical_origin.y -= length - thickness
		draw_rect(Rect2(vertical_origin, Vector2(thickness, length)), color)

class TrapSparkleStar:
	extends Node2D

	var star_size: float = 4.0
	var star_color: Color = Color(1.0, 0.78, 0.25, 0.95)

	func setup(size: float, color: Color):
		star_size = size
		star_color = color
		queue_redraw()

	func _draw():
		var points := PackedVector2Array()
		for i in range(8):
			var angle := -PI * 0.5 + float(i) * PI * 0.25
			var radius := star_size if i % 2 == 0 else star_size * 0.36
			points.append(Vector2(cos(angle), sin(angle)) * radius)
		draw_colored_polygon(points, star_color)

var cell_size: float = GameManager.CELL_SIZE
var trap_data: Resource
var theme_data: Resource
var is_light_cell: bool = true
var shader_material: ShaderMaterial
var corner_marks: TrapCornerMarks
var sparkle_stars: Array[TrapSparkleStar] = []
var shadow_sprites: Array[Sprite2D] = []
var shadow_color_cursor: int = 0
var is_selected: bool = false

func setup(size: float, trap: Resource, theme: Resource, light_cell: bool = true):
	cell_size = size
	trap_data = trap
	theme_data = theme
	is_light_cell = light_cell
	_setup_material()
	_setup_corner_marks()
	_setup_sparkles()
	_setup_shadow_sprites()
	queue_redraw()

func set_selected(selected: bool):
	is_selected = selected
	_setup_material()
	if corner_marks != null:
		corner_marks.modulate.a = 1.0 if is_selected else 0.78
	for star in sparkle_stars:
		if is_instance_valid(star):
			star.visible = is_selected

func _ready():
	_setup_material()
	_setup_shadow_sprites()

func _draw():
	draw_rect(Rect2(Vector2.ZERO, Vector2(cell_size, cell_size)), Color.WHITE)

func _setup_material():
	if trap_data == null:
		return
	if shader_material == null:
		shader_material = ShaderMaterial.new()
		shader_material.shader = TRAP_SHADER
	material = shader_material
	var tint: Color = trap_data.light_cell_tint if is_light_cell else trap_data.dark_cell_tint
	var selected_boost := 1.35 if is_selected else 1.0
	shader_material.set_shader_parameter("base_color", _boost_color(_tint_color(trap_data.base_color, tint), selected_boost))
	shader_material.set_shader_parameter("wave_color", _boost_color(_tint_color(trap_data.wave_color, tint), selected_boost))
	shader_material.set_shader_parameter("border_color", _boost_color(_tint_color(trap_data.border_color, tint), 1.75 if is_selected else 1.0))
	shader_material.set_shader_parameter("wave_strength", trap_data.wave_strength * (1.45 if is_selected else 1.0))
	shader_material.set_shader_parameter("wave_speed", trap_data.wave_speed * (1.25 if is_selected else 1.0))
	shader_material.set_shader_parameter("wave_frequency", trap_data.wave_frequency)

func _setup_corner_marks():
	if theme_data == null:
		return
	if corner_marks == null:
		corner_marks = TrapCornerMarks.new()
		corner_marks.z_index = 3
		add_child(corner_marks)
	var colors: Array[Color] = [
		_with_alpha(theme_data.red_piece_color, 0.92),
		_with_alpha(theme_data.blue_piece_color, 0.92),
		_with_alpha(theme_data.green_piece_color, 0.92),
		_with_alpha(theme_data.orange_piece_color, 0.92),
	]
	corner_marks.setup(cell_size, colors)

func _setup_sparkles():
	if sparkle_stars.is_empty():
		for i in range(SPARKLE_COUNT):
			var star := TrapSparkleStar.new()
			star.z_index = 4
			star.visible = is_selected
			star.modulate.a = 0.0
			add_child(star)
			sparkle_stars.append(star)

	for i in range(sparkle_stars.size()):
		_configure_sparkle(sparkle_stars[i], i)

func _configure_sparkle(star: TrapSparkleStar, index: int):
	var size := randf_range(cell_size * 0.035, cell_size * 0.07)
	star.setup(size, SPARKLE_COLOR)
	star.position = Vector2(
		randf_range(cell_size * 0.22, cell_size * 0.78),
		randf_range(cell_size * 0.22, cell_size * 0.78)
	)
	star.scale = Vector2.ONE * 0.15
	star.modulate = Color(1.0, 1.0, 1.0, 0.0)
	_animate_sparkle(star, index)

func _animate_sparkle(star: TrapSparkleStar, index: int):
	var delay := randf_range(0.15, 1.4) + float(index) * 0.18
	var tween := create_tween()
	tween.set_loops()
	tween.tween_interval(delay)
	tween.tween_callback(_refresh_sparkle.bind(star))
	tween.tween_property(star, "scale", Vector2.ONE, randf_range(0.26, 0.42)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(star, "modulate:a", 0.95, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_interval(randf_range(0.08, 0.22))
	tween.tween_property(star, "scale", Vector2.ONE * 1.35, randf_range(0.24, 0.38)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(star, "modulate:a", 0.0, randf_range(0.24, 0.38)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func _refresh_sparkle(star: TrapSparkleStar):
	star.position = Vector2(
		randf_range(cell_size * 0.18, cell_size * 0.82),
		randf_range(cell_size * 0.18, cell_size * 0.82)
	)
	star.rotation = randf_range(-PI, PI)
	star.scale = Vector2.ONE * 0.15
	star.modulate.a = 0.0

func _setup_shadow_sprites():
	if trap_data == null or theme_data == null:
		return
	if shadow_sprites.is_empty():
		for i in range(2):
			var sprite := Sprite2D.new()
			sprite.centered = true
			sprite.position = Vector2(cell_size, cell_size) * 0.5
			sprite.z_index = 1
			sprite.modulate.a = 0.0
			add_child(sprite)
			shadow_sprites.append(sprite)

	for i in range(shadow_sprites.size()):
		_configure_shadow_sprite(shadow_sprites[i], i)

func _configure_shadow_sprite(sprite: Sprite2D, index: int):
	var piece_type := randi_range(GameManager.PieceType.PAWN, GameManager.PieceType.KING)
	sprite.texture = theme_data.get_piece_texture(piece_type)
	if sprite.texture == null:
		return
	var texture_size := sprite.texture.get_size()
	var max_side: float = maxf(texture_size.x, texture_size.y)
	var scale_factor := cell_size * (0.52 + randf() * 0.1) / maxf(max_side, 1.0)
	sprite.scale = Vector2(scale_factor, scale_factor)
	sprite.rotation = randf_range(-0.09, 0.09)
	sprite.modulate = _get_next_piece_shadow_color(index)
	sprite.modulate.a = 0.0
	_animate_shadow(sprite, index)

func _animate_shadow(sprite: Sprite2D, index: int):
	var delay := randf_range(0.3, 2.2) + float(index) * 0.7
	var tween := create_tween()
	tween.set_loops()
	tween.tween_interval(delay)
	tween.tween_callback(_refresh_shadow_sprite.bind(sprite, index))
	tween.tween_property(sprite, "modulate:a", _get_shadow_alpha(index), randf_range(1.2, 1.8)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_interval(randf_range(0.4, 1.2))
	tween.tween_property(sprite, "modulate:a", 0.0, randf_range(1.4, 2.0)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _refresh_shadow_sprite(sprite: Sprite2D, index: int):
	var piece_type := randi_range(GameManager.PieceType.PAWN, GameManager.PieceType.KING)
	sprite.texture = theme_data.get_piece_texture(piece_type)
	sprite.modulate = _get_next_piece_shadow_color(index)
	sprite.modulate.a = 0.0

func _get_next_piece_shadow_color(index: int) -> Color:
	var colors: Array = GameManager.PieceColor.values()
	if colors.is_empty() or theme_data == null:
		return trap_data.shadow_dark_color
	var color_index := shadow_color_cursor % colors.size()
	shadow_color_cursor += 1
	var piece_color: Color = theme_data.get_piece_color(colors[color_index])
	var shadow_color := piece_color.lerp(Color.BLACK, 0.45)
	shadow_color.a = _get_shadow_alpha(index)
	return shadow_color

func _get_shadow_alpha(index: int) -> float:
	if index % 2 == 0:
		return trap_data.shadow_dark_color.a
	return maxf(trap_data.shadow_dark_color.a * 0.72, trap_data.shadow_light_color.a)

func _tint_color(color: Color, tint: Color) -> Color:
	return Color(color.r * tint.r, color.g * tint.g, color.b * tint.b, color.a * tint.a)

func _with_alpha(color: Color, alpha: float) -> Color:
	return Color(color.r, color.g, color.b, alpha)

func _boost_color(color: Color, amount: float) -> Color:
	return Color(
		clampf(color.r * amount, 0.0, 1.0),
		clampf(color.g * amount, 0.0, 1.0),
		clampf(color.b * amount, 0.0, 1.0),
		color.a
	)
