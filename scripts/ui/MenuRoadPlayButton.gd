extends Button
class_name MenuRoadPlayButton

var reveal_progress: float = 0.0:
	set(value):
		reveal_progress = clampf(value, 0.0, 1.0)
		if road_fill != null and road_fill.material is ShaderMaterial:
			(road_fill.material as ShaderMaterial).set_shader_parameter("reveal_progress", reveal_progress)

var road_fill: ColorRect

func _ready():
	focus_mode = Control.FOCUS_NONE
	flat = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	road_fill = ColorRect.new()
	road_fill.name = "RoadFill"
	road_fill.color = Color.WHITE
	road_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	road_fill.set_anchors_preset(Control.PRESET_FULL_RECT)
	road_fill.material = _build_material()
	add_child(road_fill)
	move_child(road_fill, 0)
	reveal_progress = reveal_progress

func play_unroll():
	reveal_progress = 0.0
	road_fill.scale = Vector2(0.0, 1.0)
	road_fill.pivot_offset = Vector2.ZERO
	var tween := create_tween()
	tween.tween_property(self, "reveal_progress", 1.0, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(road_fill, "scale:x", 1.0, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func show_complete():
	reveal_progress = 1.0
	if road_fill != null:
		road_fill.scale = Vector2.ONE

func _build_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;

uniform float reveal_progress = 0.0;

void fragment() {
	vec2 p = UV;
	float road_top = 0.22 + sin(p.x * 7.0) * 0.045;
	float road_bottom = 0.80 + sin(p.x * 7.0 + 0.9) * 0.045;
	float road = step(road_top, p.y) * step(p.y, road_bottom);
	float reveal_edge = reveal_progress * 1.12;
	float reveal = 1.0 - smoothstep(reveal_edge, reveal_edge + 0.14, p.x);
	float alpha = road * reveal;
	vec3 glass = mix(vec3(0.73, 0.77, 0.81), vec3(1.0), 0.18 * (1.0 - p.y));
	COLOR = vec4(glass, alpha * 0.34);
}
"""
	var shader_material := ShaderMaterial.new()
	shader_material.shader = shader
	return shader_material
