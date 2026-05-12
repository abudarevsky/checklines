extends Node2D
class_name TrapVisual

const TRAP_SHADER := preload("res://shaders/trap_cell_waves.gdshader")

var cell_size: float = GameManager.CELL_SIZE
var trap_data: Resource
var theme_data: Resource
var is_light_cell: bool = true
var shader_material: ShaderMaterial
var shadow_sprites: Array[Sprite2D] = []
var shadow_color_cursor: int = 0

func setup(size: float, trap: Resource, theme: Resource, light_cell: bool = true):
	cell_size = size
	trap_data = trap
	theme_data = theme
	is_light_cell = light_cell
	_setup_material()
	_setup_shadow_sprites()
	queue_redraw()

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
	shader_material.set_shader_parameter("base_color", _tint_color(trap_data.base_color, tint))
	shader_material.set_shader_parameter("wave_color", _tint_color(trap_data.wave_color, tint))
	shader_material.set_shader_parameter("border_color", _tint_color(trap_data.border_color, tint))
	shader_material.set_shader_parameter("wave_strength", trap_data.wave_strength)
	shader_material.set_shader_parameter("wave_speed", trap_data.wave_speed)
	shader_material.set_shader_parameter("wave_frequency", trap_data.wave_frequency)

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
