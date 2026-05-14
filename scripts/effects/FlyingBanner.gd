extends Node2D
class_name FlyingBanner

@export var phrase_text: String = "Level complete!":
	set(value):
		phrase_text = value
		_update_banner_texture()

@export var banner_size: Vector2 = Vector2(520.0, 96.0):
	set(value):
		banner_size = value
		_rebuild_banner()

@export_range(2, 96, 1) var horizontal_subdivisions: int = 48:
	set(value):
		horizontal_subdivisions = value
		_rebuild_banner()

@export_range(0.1, 1.0, 0.05) var width_scale: float = 1.0:
	set(value):
		width_scale = value
		_rebuild_banner()

@export var flight_duration: float = 1.25
@export var center_hold_duration: float = 1.0
@export_range(1.0, 4.0, 0.25) var render_scale: float = 2.0:
	set(value):
		render_scale = value
		_update_banner_texture()

@export_range(0.2, 0.8, 0.01) var font_height_ratio: float = 0.46:
	set(value):
		font_height_ratio = value
		_update_banner_texture()

@export var wind_strength: float = 8.0:
	set(value):
		wind_strength = value
		_update_shader_parameters()

@export var wave_speed: float = 2.0:
	set(value):
		wave_speed = value
		_update_shader_parameters()

@export var wave_frequency: float = 6.0:
	set(value):
		wave_frequency = value
		_update_shader_parameters()

@export var secondary_strength: float = 2.5:
	set(value):
		secondary_strength = value
		_update_shader_parameters()

@export var secondary_frequency: float = 14.0:
	set(value):
		secondary_frequency = value
		_update_shader_parameters()

@export var edge_flutter_strength: float = 5.0:
	set(value):
		edge_flutter_strength = value
		_update_shader_parameters()

@export var banner_color: Color = Color(0.05, 0.12, 0.28, 0.95):
	set(value):
		banner_color = value
		_update_banner_texture()

@export var banner_border_color: Color = Color(0.96, 0.86, 0.52, 1.0):
	set(value):
		banner_border_color = value
		_update_banner_texture()

@export var banner_text_color: Color = Color(1.0, 0.96, 0.86, 1.0):
	set(value):
		banner_text_color = value
		_update_banner_texture()

@export var banner_text_outline_color: Color = Color(0.0, 0.0, 0.0, 0.55):
	set(value):
		banner_text_outline_color = value
		_update_banner_texture()

@export var banner_shadow_color: Color = Color(0.0, 0.0, 0.0, 0.32):
	set(value):
		banner_shadow_color = value
		_update_banner_texture()

@export var auto_free_on_finish: bool = false

var mesh_instance: MeshInstance2D
var banner_viewport: SubViewport
var banner_control: Control
var banner_shadow: ColorRect
var banner_panel: Panel
var banner_label: Label
var shader_material: ShaderMaterial
var flight_tween: Tween
var flight_sequence: int = 0

const WOBBLE_SHADER := preload("res://shaders/flying_banner_wobble.gdshader")

func _ready():
	_ensure_nodes()
	_rebuild_banner()
	hide()

func show_banner(text: String, from: Vector2, to: Vector2, duration: float = -1.0):
	flight_sequence += 1
	var sequence_id := flight_sequence
	phrase_text = text
	position = from
	visible = true

	if flight_tween:
		flight_tween.kill()

	var resolved_duration := flight_duration if duration <= 0.0 else duration
	var center := (from + to) * 0.5
	flight_tween = create_tween()
	flight_tween.set_trans(Tween.TRANS_SINE)
	flight_tween.set_ease(Tween.EASE_IN_OUT)
	flight_tween.tween_property(self, "position", center, resolved_duration)
	flight_tween.tween_callback(func(): position = center)
	flight_tween.tween_interval(center_hold_duration)
	flight_tween.tween_property(self, "position", to, resolved_duration)
	await flight_tween.finished

	if sequence_id != flight_sequence:
		return

	flight_tween = null

	if auto_free_on_finish:
		queue_free()
	else:
		hide()

func stop_banner():
	flight_sequence += 1
	if flight_tween:
		flight_tween.kill()
		flight_tween = null
	hide()

func _ensure_nodes():
	if mesh_instance == null:
		mesh_instance = get_node_or_null("BannerMesh") as MeshInstance2D
	if mesh_instance == null:
		mesh_instance = MeshInstance2D.new()
		mesh_instance.name = "BannerMesh"
		add_child(mesh_instance)

	if banner_viewport == null:
		banner_viewport = get_node_or_null("BannerViewport") as SubViewport
	if banner_viewport == null:
		banner_viewport = SubViewport.new()
		banner_viewport.name = "BannerViewport"
		add_child(banner_viewport)

	banner_viewport.transparent_bg = true
	banner_viewport.disable_3d = true
	banner_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

	banner_control = banner_viewport.get_node_or_null("BannerControl") as Control
	if banner_control == null:
		banner_control = Control.new()
		banner_control.name = "BannerControl"
		banner_viewport.add_child(banner_control)

	banner_shadow = banner_control.get_node_or_null("Shadow") as ColorRect
	if banner_shadow == null:
		banner_shadow = ColorRect.new()
		banner_shadow.name = "Shadow"
		banner_control.add_child(banner_shadow)

	banner_panel = banner_control.get_node_or_null("Panel") as Panel
	if banner_panel == null:
		banner_panel = Panel.new()
		banner_panel.name = "Panel"
		banner_control.add_child(banner_panel)

	banner_label = banner_panel.get_node_or_null("Label") as Label
	if banner_label == null:
		banner_label = Label.new()
		banner_label.name = "Label"
		banner_panel.add_child(banner_label)

	shader_material = mesh_instance.material as ShaderMaterial
	if shader_material == null:
		shader_material = ShaderMaterial.new()
		shader_material.shader = WOBBLE_SHADER
		mesh_instance.material = shader_material

func _rebuild_banner():
	if not is_inside_tree():
		return

	_ensure_nodes()
	_update_banner_texture()
	mesh_instance.mesh = _build_subdivided_quad_mesh(banner_size, horizontal_subdivisions)
	_update_shader_parameters()

func _update_banner_texture():
	if not is_inside_tree():
		return

	_ensure_nodes()
	var safe_render_scale := maxf(render_scale, 1.0)
	var render_size := banner_size * safe_render_scale
	var viewport_size := Vector2i(maxi(1, ceili(render_size.x)), maxi(1, ceili(render_size.y)))
	banner_viewport.size = viewport_size
	banner_control.size = render_size

	var shadow_offset := maxf(4.0, render_size.y * 0.08)
	banner_shadow.position = Vector2(0.0, shadow_offset)
	banner_shadow.size = render_size
	banner_shadow.color = banner_shadow_color

	banner_panel.position = Vector2.ZERO
	banner_panel.size = render_size - Vector2(0.0, shadow_offset)
	banner_panel.add_theme_stylebox_override("panel", _build_banner_style(safe_render_scale))

	var horizontal_padding := 22.0 * safe_render_scale
	banner_label.position = Vector2(horizontal_padding, 0.0)
	banner_label.size = banner_panel.size - Vector2(horizontal_padding * 2.0, 0.0)
	banner_label.text = phrase_text
	banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	banner_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	banner_label.add_theme_color_override("font_color", banner_text_color)
	banner_label.add_theme_font_size_override("font_size", int(maxf(30.0, render_size.y * font_height_ratio)))
	banner_label.add_theme_constant_override("outline_size", int(maxf(2.0, safe_render_scale * 1.5)))
	banner_label.add_theme_color_override("font_outline_color", banner_text_outline_color)

	if shader_material != null:
		shader_material.set_shader_parameter("banner_texture", banner_viewport.get_texture())

func _update_shader_parameters():
	if shader_material == null:
		return

	shader_material.set_shader_parameter("wind_strength", wind_strength)
	shader_material.set_shader_parameter("wave_speed", wave_speed)
	shader_material.set_shader_parameter("wave_frequency", wave_frequency)
	shader_material.set_shader_parameter("secondary_strength", secondary_strength)
	shader_material.set_shader_parameter("secondary_frequency", secondary_frequency)
	shader_material.set_shader_parameter("edge_flutter_strength", edge_flutter_strength)
	if banner_viewport != null:
		shader_material.set_shader_parameter("banner_texture", banner_viewport.get_texture())

func _build_banner_style(scale_factor: float = 1.0) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = banner_color
	style.border_color = banner_border_color
	var border_width := int(maxf(3.0, 3.0 * scale_factor))
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	var radius := int(maxf(6.0, banner_size.y * 0.12) * scale_factor)
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.anti_aliasing = true
	return style

func _build_subdivided_quad_mesh(size: Vector2, subdivisions: int) -> ArrayMesh:
	var columns := maxi(2, subdivisions)
	var vertices := PackedVector2Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	var half_size := size * Vector2(width_scale, 1.0) * 0.5

	for x in range(columns + 1):
		var u := float(x) / float(columns)
		var px := lerpf(-half_size.x, half_size.x, u)
		vertices.append(Vector2(px, -half_size.y))
		uvs.append(Vector2(u, 0.0))
		vertices.append(Vector2(px, half_size.y))
		uvs.append(Vector2(u, 1.0))

	for x in range(columns):
		var top_left := x * 2
		var bottom_left := top_left + 1
		var top_right := top_left + 2
		var bottom_right := top_left + 3
		indices.append_array([top_left, bottom_left, top_right, top_right, bottom_left, bottom_right])

	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices

	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh
