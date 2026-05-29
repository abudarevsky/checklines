extends Node2D
class_name BoardManager

const SpawnPlannerScript = preload("res://scripts/board/SpawnPlanner.gd")
const TrapLibraryScript = preload("res://scripts/traps/TrapLibrary.gd")
const TrapVisualScript = preload("res://scripts/traps/TrapVisual.gd")
const TrapMessageCloudScript = preload("res://scripts/effects/TrapMessageCloud.gd")
const BIG_SWAMP_GEYSER_SHADER := preload("res://shaders/big_swamp_tentacle.gdshader")
const TRAP_ROTATION_FOG_DURATION := 1.64

signal piece_selected(piece)
signal piece_deselected
signal trap_selected(trap_data)
signal trap_deselected
signal piece_moved(from, to)
signal capture_made(piece, target, captured_piece_type)
signal piece_sacrificed(from, to, piece_type)

class BoardRotationFog:
	extends Node2D

	var board_pixel_size: float = GameManager.BOARD_PIXEL_SIZE
	var wind_direction: Vector2 = Vector2.RIGHT
	var cloud_lobe_radii: Array = []
	var cloud_lobe_offsets: Array = []
	var cloud_lobe_rotations: Array = []
	var progress: float = 0.0:
		set(value):
			progress = clampf(value, 0.0, 1.0)
			queue_redraw()

	func setup(size: float, direction: Vector2):
		board_pixel_size = size
		wind_direction = direction.normalized()
		if wind_direction == Vector2.ZERO:
			wind_direction = Vector2.RIGHT
		_build_cloud_lobes()
		queue_redraw()

	func _draw():
		var drift := wind_direction * board_pixel_size * lerpf(0.0, 0.78, progress)
		var alpha := 1.0 - smoothstep(0.28, 1.0, progress)
		draw_rect(Rect2(Vector2.ZERO, Vector2(board_pixel_size, board_pixel_size)), Color(0.22, 0.34, 0.4, 0.62 * alpha))
		for i in range(9):
			var column := float(i % 3)
			var row := floorf(float(i) / 3.0)
			var base := Vector2(
				(column + 0.35) * board_pixel_size / 3.0,
				(row + 0.28) * board_pixel_size / 3.0
			)
			var wave := Vector2(
				sin(progress * TAU + float(i) * 1.7),
				cos(progress * TAU * 0.8 + float(i))
			) * board_pixel_size * 0.045
			var growth := lerpf(1.0, 1.35, progress)
			for lobe_index in range(3):
				var radii: Vector2 = cloud_lobe_radii[i][lobe_index] * growth
				var offset: Vector2 = cloud_lobe_offsets[i][lobe_index] * growth
				var lobe_rotation: float = cloud_lobe_rotations[i][lobe_index]
				draw_set_transform(base + drift + wave + offset, lobe_rotation, radii)
				draw_circle(Vector2.ZERO, 1.0, Color(0.45, 0.6, 0.68, 0.42 * alpha))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	func _build_cloud_lobes():
		cloud_lobe_radii.clear()
		cloud_lobe_offsets.clear()
		cloud_lobe_rotations.clear()
		for i in range(9):
			var base_radius := board_pixel_size * randf_range(0.11, 0.18)
			var lobe_radii := [
				Vector2(base_radius * randf_range(1.15, 1.65), base_radius * randf_range(0.72, 1.02)),
				Vector2(base_radius * randf_range(0.95, 1.35), base_radius * randf_range(0.72, 1.1)),
				Vector2(base_radius * randf_range(0.9, 1.45), base_radius * randf_range(0.7, 1.0)),
			]
			var lobe_offsets := [
				Vector2.ZERO,
				Vector2(base_radius * randf_range(-0.82, -0.42), base_radius * randf_range(-0.2, 0.28)),
				Vector2(base_radius * randf_range(0.42, 0.82), base_radius * randf_range(-0.24, 0.22)),
			]
			var lobe_rotations := [
				randf_range(-0.45, 0.45),
				randf_range(-0.55, 0.35),
				randf_range(-0.35, 0.55),
			]
			cloud_lobe_radii.append(lobe_radii)
			cloud_lobe_offsets.append(lobe_offsets)
			cloud_lobe_rotations.append(lobe_rotations)

class BigSwampGeyserEffect:
	extends Node2D

	var cell_size: float = GameManager.CELL_SIZE
	var start_point: Vector2 = Vector2.ZERO
	var end_point: Vector2 = Vector2.ZERO
	var edge_color: Color = Color(0.13, 0.46, 0.5, 0.58)
	var progress: float = 0.0:
		set(value):
			progress = clampf(value, 0.0, 1.0)
			_update_visual()
			queue_redraw()
	var alpha: float = 1.0:
		set(value):
			alpha = clampf(value, 0.0, 1.0)
			_update_visual()
			queue_redraw()
	var shader_rect: ColorRect
	var shader_material: ShaderMaterial

	func setup(size: float, from_point: Vector2, to_point: Vector2, theme: Resource, piece_color: int = -1):
		cell_size = size
		start_point = from_point
		end_point = to_point
		if theme != null and piece_color >= 0:
			var target_color: Color = theme.get_piece_color(piece_color)
			edge_color = Color(target_color.r, target_color.g, target_color.b, 0.62)
		z_index = 90
		shader_rect = ColorRect.new()
		shader_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		shader_rect.color = Color.WHITE
		shader_material = ShaderMaterial.new()
		shader_material.shader = BIG_SWAMP_GEYSER_SHADER
		shader_rect.material = shader_material
		add_child(shader_rect)
		_layout_shader_rect()
		_update_visual()

	func _process(_delta: float):
		_update_visual()
		queue_redraw()

	func _draw():
		var direction := end_point - start_point
		var length := direction.length()
		if length <= 0.01:
			return
		var normal := Vector2(-direction.y, direction.x).normalized()
		var unit := direction / length
		var steam_ramp := smoothstep(0.08, 0.32, progress) * (1.0 - smoothstep(0.88, 1.0, progress))
		var steam_alpha := 0.42 * alpha * steam_ramp
		var time := Time.get_ticks_msec() * 0.001
		for i in range(7):
			var t := (float(i) + 0.5) / 7.0
			var drift := sin(time * 2.2 + float(i) * 1.4 + progress * 8.0) * cell_size * 0.08
			var lift := sin(time * 1.6 + float(i)) * cell_size * 0.04 - cell_size * 0.08
			var center := start_point.lerp(end_point, t) + normal * drift + Vector2(0.0, lift)
			var radius := cell_size * (0.08 + 0.05 * sin(time * 2.0 + float(i)))
			var lobe_color := Color(0.78, 0.86, 0.82, steam_alpha * (0.65 + 0.35 * sin(t * PI)))
			draw_circle(center, radius, lobe_color)
			draw_circle(center - unit * radius * 0.45, radius * 0.62, lobe_color)

	func _layout_shader_rect():
		if shader_rect == null:
			return
		var rect_size := Vector2(cell_size, cell_size)
		shader_rect.size = rect_size
		shader_rect.position = start_point - rect_size * 0.5

	func _update_visual():
		if shader_material != null:
			shader_material.set_shader_parameter("swamp_color", edge_color)
			shader_material.set_shader_parameter("progress", progress)
			shader_material.set_shader_parameter("alpha", alpha)

var board: Dictionary = {}
var board_size: int = GameManager.BOARD_SIZE
var cell_size: float = GameManager.CELL_SIZE
var selected_piece = null
var highlighted_cells = []
var highlighted_attacks = []
var dimmed_pieces = []
var highlight_nodes = []
var dim_border_nodes = []
var traps: Array[Vector2i] = []
var trap_type_by_cell: Dictionary = {}
var selected_trap_cell: Vector2i = Vector2i(-1, -1)
var pulsing_trap_cells: Dictionary = {}
var active_big_swamp_pulse_effect: Node2D = null
var active_big_swamp_target_sprite: Sprite2D = null
var active_big_swamp_target_alpha: float = 1.0
var last_sacrificed_piece_color: int = -1
var input_enabled: bool = true
var show_borders: bool = true
var left_border_width: float = GameManager.BORDER_WIDTH
var top_border_width: float = GameManager.BORDER_WIDTH
var right_border_width: float = GameManager.BORDER_WIDTH
var bottom_border_width: float = GameManager.BORDER_WIDTH
var border_tween: Tween

@onready var pieces_container: Node2D = $PiecesContainer
@onready var trap_visuals_container: Node2D = $TrapVisualsContainer
@onready var highlights_container: Node2D = $HighlightsContainer
@onready var effects_container: Node2D = $EffectsContainer

var piece_scene: PackedScene

func _ready():
	piece_scene = preload("res://scenes/pieces/Piece.tscn")
	_sync_container_positions()
	clear_board()
	apply_theme(_get_theme())

func _get_theme():
	var main_loop: MainLoop = Engine.get_main_loop()
	if main_loop is SceneTree:
		var root: Window = main_loop.root
		var theme_manager = root.get_node_or_null("ThemeManager")
		if theme_manager != null:
			return theme_manager.get_active_theme()
	return null

func apply_theme(theme):
	if theme != null:
		for child in pieces_container.get_children():
			if child is Piece:
				child.apply_theme(theme)
	_refresh_trap_visuals()
	queue_redraw()

func clear_board():
	for child in pieces_container.get_children():
		child.queue_free()
	for child in highlights_container.get_children():
		child.queue_free()
	for child in effects_container.get_children():
		child.queue_free()
	board.clear()
	traps.clear()
	trap_type_by_cell.clear()
	pulsing_trap_cells.clear()
	_clear_big_swamp_pulse_effect(false)
	selected_trap_cell = Vector2i(-1, -1)
	last_sacrificed_piece_color = -1
	_clear_trap_visuals()
	selected_piece = null
	highlighted_cells.clear()
	highlighted_attacks.clear()
	highlight_nodes.clear()
	dim_border_nodes.clear()
	dimmed_pieces.clear()
	if border_tween:
		border_tween.kill()
		border_tween = null
	_reset_border_widths()

func _process(_delta):
	queue_redraw()

func _draw():
	_draw_board()
	_draw_borders()

func _get_board_origin() -> Vector2:
	return Vector2(GameManager.BOARD_FRAME_MARGIN, GameManager.BOARD_FRAME_MARGIN)

func _get_board_pixel_size() -> float:
	return board_size * cell_size

func get_rendered_pixel_size() -> float:
	return _get_board_pixel_size() + GameManager.BOARD_FRAME_MARGIN * 2.0

func _sync_container_positions():
	var board_origin := _get_board_origin()
	pieces_container.position = board_origin
	if trap_visuals_container != null:
		trap_visuals_container.position = board_origin
	highlights_container.position = board_origin
	if effects_container != null:
		effects_container.position = board_origin

func _draw_board():
	var theme = _get_theme()
	if theme == null:
		return
	var board_origin := _get_board_origin()
	for y in range(board_size):
		for x in range(board_size):
			var is_light: bool = (x + y) % 2 == 0
			var color: Color = theme.board_cell_light_color if is_light else theme.board_cell_dark_color
			var rect := Rect2(
				board_origin.x + x * cell_size,
				board_origin.y + y * cell_size,
				cell_size,
				cell_size
			)
			draw_rect(rect, color)

func set_traps(cells: Array, trap_type_id: String = ""):
	traps.clear()
	trap_type_by_cell.clear()
	var had_selected_trap := selected_trap_cell != Vector2i(-1, -1)
	selected_trap_cell = Vector2i(-1, -1)
	var resolved_trap_type_id := trap_type_id
	if resolved_trap_type_id.is_empty():
		resolved_trap_type_id = TrapLibraryScript.get_default_trap_id()
	for cell in cells:
		var grid_pos: Vector2i = cell
		if _is_grid_in_bounds(grid_pos) and not board.has(grid_pos) and not (grid_pos in traps):
			traps.append(grid_pos)
			trap_type_by_cell[grid_pos] = resolved_trap_type_id
	for pulsing_cell in pulsing_trap_cells.keys():
		if not (pulsing_cell in traps):
			pulsing_trap_cells.erase(pulsing_cell)
	if selected_piece != null:
		deselect_piece()
	elif had_selected_trap:
		trap_deselected.emit()
	_refresh_trap_visuals()
	queue_redraw()

func set_traps_with_rotation(cells: Array, trap_type_id: String = ""):
	var old_traps := traps.duplicate()
	var old_trap_type_by_cell := trap_type_by_cell.duplicate()
	set_traps(cells, trap_type_id)
	_play_trap_rotation_board_fog_effect()
	_play_trap_rotation_reveal_effects()
	_play_trap_rotation_disappear_effects(old_traps, old_trap_type_by_cell)

func is_trap(grid_pos: Vector2i) -> bool:
	return grid_pos in traps

func get_trap_type_id(grid_pos: Vector2i) -> String:
	return str(trap_type_by_cell.get(grid_pos, TrapLibraryScript.get_default_trap_id()))

func get_trap_data(grid_pos: Vector2i) -> Resource:
	return TrapLibraryScript.get_trap(get_trap_type_id(grid_pos))

func _refresh_trap_visuals():
	if trap_visuals_container == null:
		return
	_clear_trap_visuals()
	var theme: Resource = _get_theme()
	if theme == null:
		return
	for trap_cell in traps:
		var visual = TrapVisualScript.new()
		visual.position = Vector2(trap_cell.x * cell_size, trap_cell.y * cell_size)
		trap_visuals_container.add_child(visual)
		var is_light_cell := (trap_cell.x + trap_cell.y) % 2 == 0
		visual.setup(cell_size, get_trap_data(trap_cell), theme, is_light_cell)
		visual.set_selected(trap_cell == selected_trap_cell)
		visual.set_pulsing(pulsing_trap_cells.has(trap_cell))

func _clear_trap_visuals():
	if trap_visuals_container == null:
		return
	for child in trap_visuals_container.get_children():
		trap_visuals_container.remove_child(child)
		child.queue_free()

func _play_trap_rotation_disappear_effects(old_traps: Array, old_trap_type_by_cell: Dictionary):
	if trap_visuals_container == null:
		return
	var theme: Resource = _get_theme()
	if theme == null:
		return
	for trap_cell in old_traps:
		var grid_pos: Vector2i = trap_cell
		var visual = TrapVisualScript.new()
		visual.position = Vector2(grid_pos.x * cell_size, grid_pos.y * cell_size)
		trap_visuals_container.add_child(visual)
		var trap_type_id := str(old_trap_type_by_cell.get(grid_pos, TrapLibraryScript.get_default_trap_id()))
		var is_light_cell := (grid_pos.x + grid_pos.y) % 2 == 0
		visual.setup(cell_size, TrapLibraryScript.get_trap(trap_type_id), theme, is_light_cell)
		visual.play_rotation_disappear()

func _play_trap_rotation_reveal_effects():
	if trap_visuals_container == null:
		return
	for child in trap_visuals_container.get_children():
		if child is TrapVisual:
			child.play_rotation_reveal()

func _play_trap_rotation_board_fog_effect():
	if effects_container == null:
		return
	var fog := BoardRotationFog.new()
	fog.z_index = 80
	fog.setup(_get_board_pixel_size(), _get_random_fog_wind_direction())
	effects_container.add_child(fog)
	var tween := create_tween()
	tween.tween_interval(0.08)
	tween.tween_property(fog, "progress", 1.0, TRAP_ROTATION_FOG_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(fog.queue_free)

func _get_random_fog_wind_direction() -> Vector2:
	var angle := randf_range(-PI, PI)
	return Vector2(cos(angle), sin(angle))

func start_big_swamp_pulse_visual(trap_cell: Vector2i, target_cell: Vector2i, piece_color: int = -1):
	if effects_container == null:
		return
	_clear_big_swamp_pulse_effect(false)
	_clear_big_swamp_target_fade(false)
	pulsing_trap_cells.clear()
	pulsing_trap_cells[trap_cell] = true
	_refresh_trap_visuals()
	var theme: Resource = _get_theme()
	var effect := BigSwampGeyserEffect.new()
	effect.setup(cell_size, _get_cell_local_position(trap_cell), _get_cell_local_position(target_cell), theme, piece_color)
	effects_container.add_child(effect)
	active_big_swamp_pulse_effect = effect
	_start_big_swamp_target_fade(target_cell)

func update_big_swamp_pulse_visual(progress: float):
	var clamped_progress := clampf(progress, 0.0, 1.0)
	if is_instance_valid(active_big_swamp_pulse_effect):
		active_big_swamp_pulse_effect.set("progress", clamped_progress)
	_update_big_swamp_target_fade(clamped_progress)

func cancel_big_swamp_pulse_visual():
	pulsing_trap_cells.clear()
	_refresh_trap_visuals()
	_clear_big_swamp_target_fade(true)
	_clear_big_swamp_pulse_effect(true)

func finish_big_swamp_pulse_visual():
	pulsing_trap_cells.clear()
	_refresh_trap_visuals()
	_clear_big_swamp_target_fade(false)
	_clear_big_swamp_pulse_effect(false)

func _start_big_swamp_target_fade(target_cell: Vector2i):
	active_big_swamp_target_sprite = null
	active_big_swamp_target_alpha = 1.0
	if not board.has(target_cell):
		return
	var piece = board[target_cell]
	if not is_instance_valid(piece) or not (piece is Piece):
		return
	var sprite: Sprite2D = piece.sprite
	if sprite == null:
		return
	active_big_swamp_target_sprite = sprite
	active_big_swamp_target_alpha = sprite.modulate.a
	_update_big_swamp_target_fade(0.0)

func _update_big_swamp_target_fade(progress: float):
	if not is_instance_valid(active_big_swamp_target_sprite):
		active_big_swamp_target_sprite = null
		return
	var color := active_big_swamp_target_sprite.modulate
	color.a = lerpf(active_big_swamp_target_alpha, 0.0, clampf(progress, 0.0, 1.0))
	active_big_swamp_target_sprite.modulate = color

func _clear_big_swamp_target_fade(restore_alpha: bool):
	if is_instance_valid(active_big_swamp_target_sprite) and restore_alpha:
		var color := active_big_swamp_target_sprite.modulate
		color.a = active_big_swamp_target_alpha
		active_big_swamp_target_sprite.modulate = color
	active_big_swamp_target_sprite = null
	active_big_swamp_target_alpha = 1.0

func _clear_big_swamp_pulse_effect(animate_retract: bool):
	if not is_instance_valid(active_big_swamp_pulse_effect):
		active_big_swamp_pulse_effect = null
		return
	var effect := active_big_swamp_pulse_effect
	active_big_swamp_pulse_effect = null
	if animate_retract:
		var tween := create_tween()
		tween.set_parallel()
		tween.tween_property(effect, "progress", 0.0, 0.26).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tween.tween_property(effect, "alpha", 0.0, 0.26).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tween.chain().tween_callback(effect.queue_free)
	else:
		effect.queue_free()

func animate_big_swamp_capture(_trap_cell: Vector2i, target_cell: Vector2i):
	if not board.has(target_cell):
		return
	var piece = board[target_cell]
	if not is_instance_valid(piece):
		return
	if is_instance_valid(active_big_swamp_pulse_effect):
		active_big_swamp_pulse_effect.set("progress", 1.0)
	_update_big_swamp_target_fade(1.0)
	if is_instance_valid(active_big_swamp_pulse_effect):
		var steam_tween := create_tween()
		steam_tween.tween_property(active_big_swamp_pulse_effect, "alpha", 0.0, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		await steam_tween.finished

func _draw_borders():
	if not show_borders:
		return
	var theme = _get_theme()
	if theme == null:
		return
	var board_origin := _get_board_origin()
	var board_size_px := _get_board_pixel_size()
	var board_end_x := board_origin.x + board_size_px
	var board_end_y := board_origin.y + board_size_px
	var padding := float(GameManager.BORDER_PADDING)
	
	draw_rect(
		Rect2(board_origin.x - padding - left_border_width, board_origin.y, left_border_width, board_size_px),
		theme.left_border_color
	)
	draw_rect(
		Rect2(board_origin.x, board_origin.y - padding - top_border_width, board_size_px, top_border_width),
		theme.top_border_color
	)
	draw_rect(
		Rect2(board_end_x + padding, board_origin.y, right_border_width, board_size_px),
		theme.right_border_color
	)
	draw_rect(
		Rect2(board_origin.x, board_end_y + padding, board_size_px, bottom_border_width),
		theme.bottom_border_color
	)

func _get_cell_local_position(grid_pos: Vector2i) -> Vector2:
	return Vector2(grid_pos.x * cell_size + cell_size / 2, grid_pos.y * cell_size + cell_size / 2)

func get_cell_position(grid_pos: Vector2i) -> Vector2:
	return _get_cell_local_position(grid_pos)

func show_trap_message_cloud(grid_pos: Vector2i, message: String, theme: Resource, piece_type: int = -1, piece_color: int = -1):
	if effects_container == null or message.strip_edges().is_empty():
		return
	var start := _get_cell_local_position(grid_pos)
	var board_size_px := _get_board_pixel_size()
	var end := Vector2(board_size_px * 0.5, board_size_px * 0.5)
	var cloud = TrapMessageCloudScript.new()
	effects_container.add_child(cloud)
	cloud.setup(message, start, end, theme, piece_type, piece_color)

func get_last_sacrificed_piece_color() -> int:
	return last_sacrificed_piece_color

func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return _get_board_origin() + _get_cell_local_position(grid_pos)

func world_to_grid(world_pos: Vector2) -> Vector2i:
	var board_origin := _get_board_origin()
	return Vector2i(
		floori((world_pos.x - board_origin.x) / cell_size),
		floori((world_pos.y - board_origin.y) / cell_size)
	)

func _reset_border_widths():
	left_border_width = GameManager.BORDER_WIDTH
	top_border_width = GameManager.BORDER_WIDTH
	right_border_width = GameManager.BORDER_WIDTH
	bottom_border_width = GameManager.BORDER_WIDTH

func _get_border_property_name(color: GameManager.PieceColor) -> String:
	match color:
		GameManager.PieceColor.RED:
			return "left_border_width"
		GameManager.PieceColor.BLUE:
			return "top_border_width"
		GameManager.PieceColor.GREEN:
			return "right_border_width"
		GameManager.PieceColor.ORANGE:
			return "bottom_border_width"
	return "left_border_width"

func _animate_border_selection(color: GameManager.PieceColor):
	if border_tween:
		border_tween.kill()
	border_tween = create_tween()
	border_tween.set_parallel(true)
	for property_name in ["left_border_width", "top_border_width", "right_border_width", "bottom_border_width"]:
		var target_width: float = GameManager.BORDER_WIDTH
		if property_name == _get_border_property_name(color):
			target_width = GameManager.SELECTED_BORDER_WIDTH
		border_tween.tween_property(self, property_name, target_width, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _shrink_all_borders():
	if border_tween:
		border_tween.kill()
	border_tween = create_tween()
	border_tween.set_parallel(true)
	for property_name in ["left_border_width", "top_border_width", "right_border_width", "bottom_border_width"]:
		border_tween.tween_property(self, property_name, float(GameManager.BORDER_WIDTH), 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func add_piece(type, color, grid_pos):
	if board.has(grid_pos):
		return null
	
	var piece = piece_scene.instantiate()
	piece.setup(type, color, grid_pos)
	piece.position = _get_cell_local_position(grid_pos)
	pieces_container.add_child(piece)
	piece.play_spawn_notice()
	board[grid_pos] = piece
	
	return piece

func remove_piece(grid_pos: Vector2i) -> bool:
	if not board.has(grid_pos):
		return false
	
	var piece = board[grid_pos]
	piece.queue_free()
	board.erase(grid_pos)
	return true

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var local_pos = get_local_mouse_position()
		var grid_pos = world_to_grid(local_pos)
		if not _is_grid_in_bounds(grid_pos):
			return
		if not input_enabled:
			return
		_handle_grid_click(grid_pos)

func _is_grid_in_bounds(grid_pos: Vector2i) -> bool:
	return grid_pos.x >= 0 and grid_pos.x < board_size and grid_pos.y >= 0 and grid_pos.y < board_size

func _handle_grid_click(grid_pos: Vector2i):
	if board.has(grid_pos):
		handle_occupied_cell_click(grid_pos)
	elif is_trap(grid_pos):
		handle_trap_cell_click(grid_pos)
	else:
		handle_empty_cell_click(grid_pos)

func handle_occupied_cell_click(grid_pos: Vector2i):
	if selected_piece:
		var captures = selected_piece.get_legal_captures(board)
		if grid_pos in captures:
			move_piece(selected_piece, grid_pos)
			return
	
	_on_piece_clicked(board[grid_pos])

func _on_piece_clicked(piece):
	if selected_piece == piece:
		deselect_piece()
		return
	
	select_piece(piece)

func handle_empty_cell_click(grid_pos: Vector2i):
	if selected_piece:
		var moves = selected_piece.get_legal_moves(board)
		if grid_pos in moves:
			move_piece(selected_piece, grid_pos)
			return
		deselect_piece()
	deselect_trap()

func handle_trap_cell_click(grid_pos: Vector2i):
	if selected_piece:
		var moves = selected_piece.get_legal_moves(board)
		if grid_pos in moves:
			move_piece(selected_piece, grid_pos)
			return
	select_trap(grid_pos)

func select_piece(piece):
	deselect_trap()
	deselect_piece()
	selected_piece = piece
	piece.set_selected(true)
	_animate_border_selection(piece.piece_color)
	
	var moves = piece.get_legal_moves(board)
	var captures = piece.get_legal_captures(board)
	highlighted_cells = moves
	highlighted_attacks = captures
	
	for cell in moves:
		highlight_nodes.append(_draw_highlight(cell))
	
	for cell in captures:
		highlight_nodes.append(_draw_attack_overlay(piece, cell))
		_dim_target_piece(cell, piece.piece_color)
	
	piece_selected.emit(piece)

func deselect_piece():
	var had_selected := selected_piece != null
	if selected_piece:
		selected_piece.set_selected(false)
		_shrink_all_borders()
	selected_piece = null
	highlighted_cells.clear()
	highlighted_attacks.clear()
	_restore_dimmed_pieces()
	_clear_highlights()
	if had_selected:
		piece_deselected.emit()

func select_trap(grid_pos: Vector2i):
	if selected_trap_cell == grid_pos:
		deselect_trap()
		return
	deselect_piece()
	selected_trap_cell = grid_pos
	_refresh_trap_visuals()
	trap_selected.emit(get_trap_data(grid_pos))

func deselect_trap():
	if selected_trap_cell == Vector2i(-1, -1):
		return
	selected_trap_cell = Vector2i(-1, -1)
	_refresh_trap_visuals()
	trap_deselected.emit()

func set_input_enabled(enabled: bool):
	input_enabled = enabled
	if not enabled:
		deselect_piece()

func _draw_highlight(cell: Vector2i) -> Node:
	var theme = _get_theme()
	var highlight = ColorRect.new()
	highlight.position = Vector2(cell.x * cell_size, cell.y * cell_size)
	highlight.size = Vector2(cell_size, cell_size)
	highlight.color = theme.move_highlight_color
	highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	highlights_container.add_child(highlight)
	return highlight

func _draw_attack_overlay(attacker: Piece, target_cell: Vector2i) -> Node:
	var theme = _get_theme()
	var overlay_container = Node2D.new()
	overlay_container.name = "AttackOverlay"
	overlay_container.position = Vector2(target_cell.x * cell_size, target_cell.y * cell_size)
	
	var overlay_sprite = Sprite2D.new()
	overlay_sprite.texture = theme.get_piece_texture(int(attacker.piece_type))
	var overlay_scale = cell_size / 4.0 / 512.0
	overlay_sprite.scale = Vector2(overlay_scale, overlay_scale)
	overlay_sprite.modulate = attacker.sprite.modulate
	
	var overlay_size = cell_size * 0.25
	var offset_x = cell_size * 0.75
	var offset_y = cell_size * 0.25
	overlay_sprite.position = Vector2(offset_x, offset_y)
	
	var bg_rect = ColorRect.new()
	bg_rect.size = Vector2(overlay_size, overlay_size)
	bg_rect.color = theme.attack_overlay_background_color
	bg_rect.position = Vector2(offset_x - overlay_size / 2, offset_y - overlay_size / 2)
	bg_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	overlay_container.add_child(bg_rect)
	overlay_container.add_child(overlay_sprite)
	highlights_container.add_child(overlay_container)
	return overlay_container

func _dim_target_piece(target_cell: Vector2i, attacker_color: GameManager.PieceColor):
	var theme = _get_theme()
	if board.has(target_cell):
		var piece = board[target_cell]
		dimmed_pieces.append({"piece": piece, "original_a": piece.modulate.a})
		piece.modulate.a = theme.dim_target_alpha
		
		var border_color = theme.get_border_color(int(attacker_color))
		var border_width = 3
		var cell_pixel = Vector2(target_cell.x * cell_size, target_cell.y * cell_size)
		
		var top = ColorRect.new()
		top.position = cell_pixel
		top.size = Vector2(cell_size, border_width)
		top.color = border_color
		top.mouse_filter = Control.MOUSE_FILTER_IGNORE
		highlights_container.add_child(top)
		dim_border_nodes.append(top)
		
		var bottom = ColorRect.new()
		bottom.position = Vector2(cell_pixel.x, cell_pixel.y + cell_size - border_width)
		bottom.size = Vector2(cell_size, border_width)
		bottom.color = border_color
		bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
		highlights_container.add_child(bottom)
		dim_border_nodes.append(bottom)
		
		var left = ColorRect.new()
		left.position = cell_pixel
		left.size = Vector2(border_width, cell_size)
		left.color = border_color
		left.mouse_filter = Control.MOUSE_FILTER_IGNORE
		highlights_container.add_child(left)
		dim_border_nodes.append(left)
		
		var right = ColorRect.new()
		right.position = Vector2(cell_pixel.x + cell_size - border_width, cell_pixel.y)
		right.size = Vector2(border_width, cell_size)
		right.color = border_color
		right.mouse_filter = Control.MOUSE_FILTER_IGNORE
		highlights_container.add_child(right)
		dim_border_nodes.append(right)

func _restore_dimmed_pieces():
	for entry in dimmed_pieces:
		if is_instance_valid(entry.piece):
			entry.piece.modulate.a = entry.original_a
	dimmed_pieces.clear()
	for node in dim_border_nodes:
		if is_instance_valid(node):
			node.queue_free()
	dim_border_nodes.clear()

func _clear_highlights():
	for node in highlight_nodes:
		if is_instance_valid(node):
			node.queue_free()
	highlight_nodes.clear()

func move_piece(piece, target: Vector2i):
	var from_pos: Vector2i = piece.grid_position
	var moved_piece_type: int = piece.piece_type
	var moved_piece_color: int = piece.piece_color

	board.erase(from_pos)

	if is_trap(target):
		last_sacrificed_piece_color = moved_piece_color
		piece.queue_free()
		deselect_piece()
		piece_sacrificed.emit(from_pos, target, moved_piece_type)
		return
	
	var captured_piece = null
	var captured_piece_type := -1
	if board.has(target):
		captured_piece = board[target]
		captured_piece_type = captured_piece.piece_type
		remove_piece(target)
	
	piece.grid_position = target
	piece.position = _get_cell_local_position(target)
	
	board[target] = piece
	
	deselect_piece()
	
	piece_moved.emit(from_pos, target)
	if captured_piece:
		capture_made.emit(piece, target, captured_piece_type)

func has_legal_moves() -> bool:
	for piece in board.values():
		var moves = piece.get_legal_moves(board)
		var captures = piece.get_legal_captures(board)
		if moves.size() > 0 or captures.size() > 0:
			return true
	return false

func get_piece_count() -> int:
	return board.size()

func get_empty_cells():
	var empty = []
	for y in range(board_size):
		for x in range(board_size):
			var pos: Vector2i = Vector2i(x, y)
			if not board.has(pos) and not is_trap(pos):
				empty.append(pos)
	return empty

func can_spawn_piece_type_for_color(piece_type: GameManager.PieceType, color: GameManager.PieceColor) -> bool:
	return SpawnPlannerScript.can_spawn_identity(board, piece_type, color, get_empty_cells())

func get_available_piece_types_for_color(color: GameManager.PieceColor) -> Array:
	var available_types: Array = []
	for piece_type in GameManager.PieceType.values():
		if can_spawn_piece_type_for_color(piece_type, color):
			available_types.append(piece_type)
	return available_types

func get_available_colors_for_spawn() -> Array:
	var available_colors: Array = []
	for color in GameManager.PieceColor.values():
		if not get_available_piece_types_for_color(color).is_empty():
			available_colors.append(color)
	return available_colors

func can_spawn_any_piece() -> bool:
	return not get_available_colors_for_spawn().is_empty()

func get_weighted_random_piece_type(available_types: Array) -> int:
	var weights := GameManager.get_piece_spawn_weights()
	var total_weight := 0.0

	for piece_type in available_types:
		total_weight += weights[piece_type]

	if total_weight <= 0.0:
		return available_types[0]

	var threshold := randf() * total_weight
	var cumulative := 0.0
	for piece_type in available_types:
		cumulative += weights[piece_type]
		if threshold <= cumulative:
			return piece_type

	return available_types[available_types.size() - 1]

func resolve_spawn_piece_data(piece_type, color) -> Dictionary:
	if can_spawn_piece_type_for_color(piece_type, color):
		return {"piece_type": piece_type, "color": color}

	var available_types := get_available_piece_types_for_color(color)
	if available_types.is_empty():
		return {}

	return {"piece_type": get_weighted_random_piece_type(available_types), "color": color}

func get_random_spawn_piece_data() -> Dictionary:
	var available_colors := get_available_colors_for_spawn()
	if available_colors.is_empty():
		return {}

	available_colors.shuffle()
	var color = available_colors[0]
	var piece_type = GameManager.get_random_piece_type()
	return resolve_spawn_piece_data(piece_type, color)

func get_preferred_spawn_cell(piece_type: int, color: int) -> Vector2i:
	var empty_cells: Array = get_empty_cells()
	return SpawnPlannerScript.get_preferred_spawn_cell(board, empty_cells, piece_type, color)

func spawn_piece_with_preferred_placement(spawn_data: Dictionary) -> bool:
	if spawn_data.is_empty():
		return false

	var grid_pos: Vector2i = get_preferred_spawn_cell(spawn_data["piece_type"], spawn_data["color"])
	if grid_pos == Vector2i(-1, -1):
		return false

	add_piece(spawn_data["piece_type"], spawn_data["color"], grid_pos)
	return true

func spawn_random_pieces(count: int) -> int:
	var spawn_count: int = mini(count, get_empty_cells().size())
	var spawned_count := 0

	for i in range(spawn_count):
		var spawn_data: Dictionary = get_random_spawn_piece_data()
		if spawn_data.is_empty():
			return spawned_count
		if not spawn_piece_with_preferred_placement(spawn_data):
			return spawned_count
		spawned_count += 1

	return spawned_count

func fill_empty_cells_with_kings():
	var empty_cells: Array = get_empty_cells()
	if empty_cells.is_empty():
		return

	var king_colors: Array = GameManager.PieceColor.values()
	king_colors.shuffle()

	for i in range(empty_cells.size()):
		var grid_pos: Vector2i = empty_cells[i]
		var king_color: int = king_colors[i % king_colors.size()]
		add_piece(GameManager.PieceType.KING, king_color, grid_pos)
