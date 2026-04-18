extends Node2D
class_name Piece

signal clicked(piece)

@export var piece_type = GameManager.PieceType.PAWN
@export var piece_color = GameManager.PieceColor.WHITE
@export var grid_position: Vector2i = Vector2i(-1, -1)

var is_selected: bool = false
var is_highlighted: bool = false
var capture_targets = []

var piece_size := 56.0

@onready var selection_indicator: Node2D = $SelectionIndicator
@onready var highlight_overlay: ColorRect = $HighlightOverlay

func _ready():
	clicked.connect(_on_clicked)
	queue_redraw()

func _draw():
	_draw_piece()

func _draw_piece():
	var outline_color: Color = Color.WHITE if piece_color == GameManager.PieceColor.WHITE else Color.BLACK
	var fill_color: Color = Color.WHITE if piece_color == GameManager.PieceColor.WHITE else Color(0.2, 0.2, 0.2)
	
	match piece_type:
		GameManager.PieceType.PAWN:
			_draw_pawn(outline_color, fill_color)
		GameManager.PieceType.KNIGHT:
			_draw_knight(outline_color, fill_color)
		GameManager.PieceType.BISHOP:
			_draw_bishop(outline_color, fill_color)
		GameManager.PieceType.ROOK:
			_draw_rook(outline_color, fill_color)
		GameManager.PieceType.QUEEN:
			_draw_queen(outline_color, fill_color)
		GameManager.PieceType.KING:
			_draw_king(outline_color, fill_color)

func _draw_pawn(outline: Color, fill: Color):
	draw_circle(Vector2(0, 10), 10, fill)
	draw_circle(Vector2(0, -5), 7, fill)
	draw_line(Vector2(0, -12), Vector2(0, 3), fill, 4)
	draw_circle(Vector2(0, -15), 4, fill)

func _draw_knight(outline: Color, fill: Color):
	draw_circle(Vector2(0, 12), 14, fill)
	draw_circle(Vector2(4, -8), 8, fill)
	var pts := PackedVector2Array([
		Vector2(-6, -6), Vector2(14, -6), Vector2(10, -16), Vector2(-2, -16)
	])
	draw_polygon(pts, [fill])
	draw_line(Vector2(-4, -16), Vector2(8, 8), fill, 4)

func _draw_bishop(outline: Color, fill: Color):
	var pts := PackedVector2Array([
		Vector2(-14, 20), Vector2(14, 20), Vector2(10, -10),
		Vector2(-10, -10)
	])
	draw_polygon(pts, [fill])
	draw_circle(Vector2(0, -5), 8, fill)
	draw_circle(Vector2(0, -18), 5, fill)
	draw_line(Vector2(-6, -2), Vector2(6, -2), fill, 2)

func _draw_rook(outline: Color, fill: Color):
	var pts := PackedVector2Array([
		Vector2(-16, 20), Vector2(16, 20), Vector2(16, -10),
		Vector2(12, -14), Vector2(12, -20), Vector2(-12, -20),
		Vector2(-12, -14), Vector2(-16, -10)
	])
	draw_polygon(pts, [fill])
	draw_rect(Rect2(-10, -18, 6, 10), fill)
	draw_rect(Rect2(4, -18, 6, 10), fill)

func _draw_queen(outline: Color, fill: Color):
	draw_circle(Vector2(0, 12), 16, fill)
	draw_rect(Rect2(-6, -18, 12, 30), fill)
	draw_circle(Vector2(0, -20), 6, fill)
	draw_circle(Vector2(-8, -8), 3, fill)
	draw_circle(Vector2(8, -8), 3, fill)
	draw_circle(Vector2(0, 0), 3, fill)
	draw_line(Vector2(-6, -22), Vector2(-6, -26), fill, 2)
	draw_line(Vector2(0, -26), Vector2(0, -30), fill, 2)
	draw_line(Vector2(6, -22), Vector2(6, -26), fill, 2)

func _draw_king(outline: Color, fill: Color):
	draw_circle(Vector2(0, 12), 16, fill)
	draw_rect(Rect2(-7, -18, 14, 30), fill)
	draw_rect(Rect2(-14, -24, 28, 8), fill)
	draw_line(Vector2(0, -20), Vector2(0, -28), fill, 4)
	draw_line(Vector2(-8, -24), Vector2(-12, -30), fill, 3)
	draw_line(Vector2(8, -24), Vector2(12, -30), fill, 3)

func setup(type, color, pos: Vector2i):
	piece_type = type
	piece_color = color
	grid_position = pos
	queue_redraw()

func update_visual():
	queue_redraw()
	
	if selection_indicator:
		selection_indicator.visible = is_selected
	
	if highlight_overlay:
		highlight_overlay.visible = is_highlighted

func _on_clicked(_piece: Piece):
	clicked.emit(self)

func _on_area_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(self)

func set_selected(selected: bool):
	is_selected = selected
	if selection_indicator:
		selection_indicator.visible = selected

func set_highlighted(highlighted: bool):
	is_highlighted = highlighted
	if highlight_overlay:
		highlight_overlay.visible = highlighted

func get_legal_captures(board: Dictionary):
	var captures = []
	var directions = _get_attack_directions()
	
	match piece_type:
		GameManager.PieceType.PAWN:
			captures = _get_pawn_captures(board)
		GameManager.PieceType.KNIGHT:
			captures = _get_knight_captures(board)
		GameManager.PieceType.KING:
			captures = _get_king_captures(board)
		_:
			captures = _get_sliding_captures(board, directions)
	
	return captures

func get_legal_moves(board: Dictionary):
	var moves = []
	var directions = _get_attack_directions()
	
	match piece_type:
		GameManager.PieceType.PAWN:
			moves = _get_pawn_moves(board)
		GameManager.PieceType.KNIGHT:
			moves = _get_knight_moves(board)
		GameManager.PieceType.KING:
			moves = _get_king_moves(board)
		_:
			moves = _get_sliding_moves(board, directions)
	
	return moves

func _get_attack_directions():
	match piece_type:
		GameManager.PieceType.BISHOP:
			return [Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)]
		GameManager.PieceType.ROOK:
			return [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
		GameManager.PieceType.QUEEN:
			return [Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1),
					 Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	return []

func _get_sliding_captures(board: Dictionary, directions):
	var captures = []
	
	for dir in directions:
		var current: Vector2i = grid_position + dir
		var board_size = GameManager.board_size
		
		while current.x >= 0 and current.x < board_size and current.y >= 0 and current.y < board_size:
			if board.has(current):
				var other_piece = board[current]
				if other_piece.piece_color != piece_color:
					captures.append(current)
				break
			current += dir
	
	return captures

func _get_knight_captures(board: Dictionary):
	var captures = []
	var offsets = [Vector2i(2, 1), Vector2i(2, -1), Vector2i(-2, 1), Vector2i(-2, -1),
					Vector2i(1, 2), Vector2i(1, -2), Vector2i(-1, 2), Vector2i(-1, -2)]
	var board_size = GameManager.board_size
	
	for offset in offsets:
		var target: Vector2i = grid_position + offset
		if target.x >= 0 and target.x < board_size and target.y >= 0 and target.y < board_size:
			if board.has(target):
				var other_piece = board[target]
				if other_piece.piece_color != piece_color:
					captures.append(target)
	
	return captures

func _get_king_captures(board: Dictionary):
	var captures = []
	var offsets = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
					Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)]
	var board_size = GameManager.board_size
	
	for offset in offsets:
		var target: Vector2i = grid_position + offset
		if target.x >= 0 and target.x < board_size and target.y >= 0 and target.y < board_size:
			if board.has(target):
				var other_piece = board[target]
				if other_piece.piece_color != piece_color:
					captures.append(target)
	
	return captures

func _get_pawn_captures(board: Dictionary):
	var captures = []
	var direction: int = -1 if piece_color == GameManager.PieceColor.WHITE else 1
	var board_size = GameManager.board_size
	
	var targets = [Vector2i(grid_position.x - 1, grid_position.y + direction),
					Vector2i(grid_position.x + 1, grid_position.y + direction)]
	
	for target in targets:
		if target.x >= 0 and target.x < board_size and target.y >= 0 and target.y < board_size:
			if board.has(target):
				var other_piece = board[target]
				if other_piece.piece_color != piece_color:
					captures.append(target)
	
	return captures

func can_attack(target: Vector2i, board: Dictionary) -> bool:
	var captures = get_legal_captures(board)
	return target in captures

func _get_sliding_moves(board: Dictionary, directions):
	var moves = []
	var board_size = GameManager.board_size
	
	for dir in directions:
		var current: Vector2i = grid_position + dir
		
		while current.x >= 0 and current.x < board_size and current.y >= 0 and current.y < board_size:
			if board.has(current):
				break
			moves.append(current)
			current += dir
	
	return moves

func _get_knight_moves(board: Dictionary):
	var moves = []
	var offsets = [Vector2i(2, 1), Vector2i(2, -1), Vector2i(-2, 1), Vector2i(-2, -1),
					Vector2i(1, 2), Vector2i(1, -2), Vector2i(-1, 2), Vector2i(-1, -2)]
	var board_size = GameManager.board_size
	
	for offset in offsets:
		var target: Vector2i = grid_position + offset
		if target.x >= 0 and target.x < board_size and target.y >= 0 and target.y < board_size:
			if not board.has(target):
				moves.append(target)
	
	return moves

func _get_king_moves(board: Dictionary):
	var moves = []
	var offsets = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
					Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)]
	var board_size = GameManager.board_size
	
	for offset in offsets:
		var target: Vector2i = grid_position + offset
		if target.x >= 0 and target.x < board_size and target.y >= 0 and target.y < board_size:
			if not board.has(target):
				moves.append(target)
	
	return moves

func _get_pawn_moves(board: Dictionary):
	var moves = []
	var direction: int = -1 if piece_color == GameManager.PieceColor.WHITE else 1
	var board_size = GameManager.board_size
	
	var forward: Vector2i = Vector2i(grid_position.x, grid_position.y + direction)
	if forward.y >= 0 and forward.y < board_size and not board.has(forward):
		moves.append(forward)
		
		var start_row = 1 if piece_color == GameManager.PieceColor.WHITE else board_size - 2
		if grid_position.y == start_row:
			var double_forward: Vector2i = Vector2i(grid_position.x, grid_position.y + 2 * direction)
			if not board.has(double_forward):
				moves.append(double_forward)
	
	return moves