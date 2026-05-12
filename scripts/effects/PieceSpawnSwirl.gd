extends Node2D
class_name PieceSpawnSwirl

const SPAWN_SWIRL_SHADER := preload("res://shaders/piece_spawn_swirl.gdshader")
const SPAWN_NOTICE_DURATION: float = 1.0

var effect_size: float = GameManager.CELL_SIZE
var effect_color: Color = Color.WHITE
var progress: float = 0.0:
	set(value):
		progress = value
		_update_shader_parameters()

var shader_material: ShaderMaterial

func setup(size: float, color: Color):
	effect_size = size * 1.38
	effect_color = color
	effect_color.a = 1.0
	_setup_material()
	queue_redraw()

func _ready():
	_setup_material()
	_play()

func _draw():
	var half_size := effect_size * 0.5
	draw_rect(Rect2(Vector2(-half_size, -half_size), Vector2(effect_size, effect_size)), Color.WHITE)

func _setup_material():
	if shader_material == null:
		shader_material = ShaderMaterial.new()
		shader_material.shader = SPAWN_SWIRL_SHADER
	material = shader_material
	_update_shader_parameters()

func _update_shader_parameters():
	if shader_material == null:
		return
	shader_material.set_shader_parameter("effect_color", effect_color)
	shader_material.set_shader_parameter("progress", progress)

func _play():
	progress = 0.0
	scale = Vector2.ONE
	modulate.a = 1.0
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "progress", 1.0, SPAWN_NOTICE_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1.26, 1.26), SPAWN_NOTICE_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, SPAWN_NOTICE_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.finished.connect(queue_free)
