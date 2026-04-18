extends Node2D
class_name Piece

signal clicked(piece)

@export var piece_type = GameManager.PieceType.PAWN
@export var piece_color = GameManager.PieceColor.WHITE
@export var grid_position: Vector2i = Vector2i(-1, -1)

var is_selected: bool = false
var is_highlighted: bool = false
var capture_targets = []

var piece_size: float = GameManager.CELL_SIZE
var sprite_scale: float = GameManager.CELL_SIZE / 512.0  # Scale 512px PNG to cell size

@onready var sprite: Sprite2D = $Sprite
@onready var selection_indicator: Node2D = $SelectionIndicator
@onready var highlight_overlay: ColorRect = $HighlightOverlay

const SVG_PATH = "res://assets/sprites/png/%s_%s.png"

func _ready():
	clicked.connect(_on_clicked)
	_load_sprite()

func _load_sprite():
	if not sprite:
		return
	
	var color_str = "white" if piece_color == GameManager.PieceColor.WHITE else "black"
	var type_str = _get_type_string()
	var path = SVG_PATH % [color_str, type_str]
	
	sprite.texture = load(path)
	sprite.scale = Vector2(sprite_scale, sprite_scale)

func _get_type_string() -> String:
	match piece_type:
		GameManager.PieceType.PAWN: return "pawn"
		GameManager.PieceType.KNIGHT: return "knight"
		GameManager.PieceType.BISHOP: return "bishop"
		GameManager.PieceType.ROOK: return "rook"
		GameManager.PieceType.QUEEN: return "queen"
		GameManager.PieceType.KING: return "king"
	return "pawn"

func setup(type, color, pos: Vector2i):
	piece_type = type
	piece_color = color
	grid_position = pos
	_load_sprite()

func update_visual():
	if sprite:
		sprite.visible = true
	
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