extends Node2D
class_name BoardManager

const SpawnPlannerScript = preload("res://scripts/board/SpawnPlanner.gd")
const TrapLibraryScript = preload("res://scripts/traps/TrapLibrary.gd")
const TrapVisualScript = preload("res://scripts/traps/TrapVisual.gd")
const TrapMessageCloudScript = preload("res://scripts/effects/TrapMessageCloud.gd")

signal piece_selected(piece)
signal piece_deselected
signal piece_moved(from, to)
signal capture_made(piece, target, captured_piece_type)
signal piece_sacrificed(from, to, piece_type)

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
	var resolved_trap_type_id := trap_type_id
	if resolved_trap_type_id.is_empty():
		resolved_trap_type_id = TrapLibraryScript.get_default_trap_id()
	for cell in cells:
		var grid_pos: Vector2i = cell
		if _is_grid_in_bounds(grid_pos) and not board.has(grid_pos) and not (grid_pos in traps):
			traps.append(grid_pos)
			trap_type_by_cell[grid_pos] = resolved_trap_type_id
	if selected_piece != null:
		deselect_piece()
	_refresh_trap_visuals()
	queue_redraw()

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

func _clear_trap_visuals():
	if trap_visuals_container == null:
		return
	for child in trap_visuals_container.get_children():
		child.queue_free()

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

func select_piece(piece):
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
		if moves.size() > 0:
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
