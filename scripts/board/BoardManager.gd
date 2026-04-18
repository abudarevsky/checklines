extends Node2D
class_name BoardManager

signal piece_selected(piece)
signal piece_moved(from, to)
signal capture_made(piece, target)
signal chain_cleared(chain)
signal no_moves_available

var board: Dictionary = {}
var board_size: int = 9
var cell_size: float = 56.0
var selected_piece = null
var highlighted_cells = []

@onready var pieces_container: Node2D = $PiecesContainer

var piece_scene: PackedScene

func _ready():
	piece_scene = preload("res://scenes/pieces/Piece.tscn")
	clear_board()

func clear_board():
	for child in pieces_container.get_children():
		child.queue_free()
	board.clear()
	selected_piece = null
	highlighted_cells.clear()

func _process(_delta):
	queue_redraw()

func _draw():
	_draw_board()

func _draw_board():
	for y in range(board_size):
		for x in range(board_size):
			var is_light: bool = (x + y) % 2 == 0
			var color: Color = Color.DARK_SLATE_GRAY if is_light else Color.SADDLE_BROWN
			var rect: Rect2 = Rect2(x * cell_size, y * cell_size, cell_size, cell_size)
			draw_rect(rect, color)

func get_cell_position(grid_pos: Vector2i) -> Vector2:
	return Vector2(grid_pos.x * cell_size + cell_size / 2, grid_pos.y * cell_size + cell_size / 2)

func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return get_cell_position(grid_pos)

func world_to_grid(world_pos: Vector2) -> Vector2i:
	return Vector2i(int(world_pos.x / cell_size), int(world_pos.y / cell_size))

func add_piece(type, color, grid_pos):
	if board.has(grid_pos):
		return null
	
	var piece = piece_scene.instantiate()
	piece.setup(type, color, grid_pos)
	piece.position = get_cell_position(grid_pos)
	pieces_container.add_child(piece)
	board[grid_pos] = piece
	
	return piece

func remove_piece(grid_pos: Vector2i) -> bool:
	if not board.has(grid_pos):
		return false
	
	var piece = board[grid_pos]
	piece.queue_free()
	board.erase(grid_pos)
	return true

func get_piece_at(grid_pos: Vector2i):
	return board.get(grid_pos)

func get_all_pieces():
	return board.values()

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var local_pos = get_local_mouse_position()
		var grid_pos = world_to_grid(local_pos)
		if grid_pos.x >= 0 and grid_pos.x < board_size and grid_pos.y >= 0 and grid_pos.y < board_size:
			if board.has(grid_pos):
				_on_piece_clicked(board[grid_pos])
			else:
				handle_empty_cell_click(grid_pos)

func _on_piece_clicked(piece):
	print("piece_clicked: " + str(piece.grid_position))
	if selected_piece == piece:
		deselect_piece()
		return
	
	print("  calling select_piece")
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
	
	var moves = piece.get_legal_moves(board)
	highlighted_cells = moves
	
	for cell in moves:
		_draw_highlight(cell)
	
	piece_selected.emit(piece)

func deselect_piece():
	if selected_piece:
		selected_piece.set_selected(false)
	selected_piece = null
	highlighted_cells.clear()
	_clear_highlights()

func _draw_highlight(cell: Vector2i):
	var highlight = ColorRect.new()
	highlight.position = Vector2(cell.x * cell_size, cell.y * cell_size)
	highlight.size = Vector2(cell_size, cell_size)
	highlight.color = Color(1, 1, 0, 0.4)
	pieces_container.add_child(highlight)

func _clear_highlights():
	for child in pieces_container.get_children():
		if child is ColorRect:
			child.queue_free()

func move_piece(piece, target: Vector2i):
	var from_pos: Vector2i = piece.grid_position
	
	board.erase(from_pos)
	
	var captured_piece = null
	if board.has(target):
		captured_piece = board[target]
		remove_piece(target)
	
	piece.grid_position = target
	piece.position = get_cell_position(target)
	
	board[target] = piece
	
	deselect_piece()
	
	piece_moved.emit(from_pos, target)
	if captured_piece:
		capture_made.emit(piece, target)

func has_legal_captures() -> bool:
	for piece in board.values():
		var captures = piece.get_legal_captures(board)
		if captures.size() > 0:
			return true
	return false

func has_legal_moves() -> bool:
	for piece in board.values():
		var moves = piece.get_legal_moves(board)
		if moves.size() > 0:
			return true
	return false

func get_all_legal_captures():
	var moves = []
	for piece in board.values():
		var captures = piece.get_legal_captures(board)
		for target in captures:
			moves.append({"piece": piece, "from": piece.grid_position, "to": target})
	return moves

func get_pieces_by_color(color):
	var pieces = []
	for piece in board.values():
		if piece.piece_color == color:
			pieces.append(piece)
	return pieces

func get_piece_count() -> int:
	return board.size()

func get_empty_cells():
	var empty = []
	for y in range(board_size):
		for x in range(board_size):
			var pos: Vector2i = Vector2i(x, y)
			if not board.has(pos):
				empty.append(pos)
	return empty

func spawn_random_pieces(count: int):
	var empty_cells = get_empty_cells()
	empty_cells.shuffle()
	
	for i in range(min(count, empty_cells.size())):
		var cell = empty_cells[i]
		var piece_type = GameManager.get_random_piece_type()
		var color = GameManager.PieceColor.WHITE if randf() > 0.5 else GameManager.PieceColor.BLACK
		add_piece(piece_type, color, cell)