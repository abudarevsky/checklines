extends Node
class_name ChainDetector

static func find_chains(board: Dictionary):
	# Find all possible lines (horizontal, vertical, diagonal) of same-color pieces
	var lines = []
	var pieces = board.values()
	
	if pieces.size() < 5:
		return lines
	
	# Check for horizontal lines
	for y in range(GameManager.BOARD_SIZE):
		var line = []
		var last_color = -1
		for x in range(GameManager.BOARD_SIZE):
			var pos = Vector2i(x, y)
			if board.has(pos):
				var piece = board[pos]
				if last_color != -1 and last_color != piece.piece_color:
					if line.size() >= 5:
						lines.append(line)
					line = []
				line.append(piece)
				last_color = piece.piece_color
		if line.size() >= 5:
			lines.append(line)
	
	# Check for vertical lines
	for x in range(GameManager.BOARD_SIZE):
		var line = []
		var last_color = -1
		for y in range(GameManager.BOARD_SIZE):
			var pos = Vector2i(x, y)
			if board.has(pos):
				var piece = board[pos]
				if last_color != -1 and last_color != piece.piece_color:
					if line.size() >= 5:
						lines.append(line)
					line = []
				line.append(piece)
				last_color = piece.piece_color
		if line.size() >= 5:
			lines.append(line)
	
	# Check for diagonal lines (top-left to bottom-right)
	for i in range(GameManager.BOARD_SIZE * 2 - 1):
		var line = []
		var last_color = -1
		var start_y = max(0, i - GameManager.BOARD_SIZE + 1)
		var end_y = min(GameManager.BOARD_SIZE, i + 1)
		
		for y in range(start_y, end_y):
			var x = i - y
			if x >= 0 and x < GameManager.BOARD_SIZE:
				var pos = Vector2i(x, y)
				if board.has(pos):
					var piece = board[pos]
					if last_color != -1 and last_color != piece.piece_color:
						if line.size() >= 5:
							lines.append(line)
						line = []
					line.append(piece)
					last_color = piece.piece_color
		if line.size() >= 5:
			lines.append(line)
	
	# Check for diagonal lines (top-right to bottom-left)
	for i in range(GameManager.BOARD_SIZE * 2 - 1):
		var line = []
		var last_color = -1
		var start_y = max(0, i - GameManager.BOARD_SIZE + 1)
		var end_y = min(GameManager.BOARD_SIZE, i + 1)
		
		for y in range(start_y, end_y):
			var x = GameManager.BOARD_SIZE - 1 - (i - y)
			if x >= 0 and x < GameManager.BOARD_SIZE:
				var pos = Vector2i(x, y)
				if board.has(pos):
					var piece = board[pos]
					if last_color != -1 and last_color != piece.piece_color:
						if line.size() >= 5:
							lines.append(line)
						line = []
					line.append(piece)
					last_color = piece.piece_color
		if line.size() >= 5:
			lines.append(line)
	
	# Filter out lines that are less than 5 pieces
	var valid_lines = []
	for line in lines:
		if line.size() >= 5:
			valid_lines.append(line)
	
	return valid_lines

static func select_random_chain(chains):
	if chains.is_empty():
		return []
	
	chains.shuffle()
	return chains[0]

static func get_chain_positions(chain):
	var positions = []
	for piece in chain:
		positions.append(piece.grid_position)
	return positions

static func is_valid_chain(chain):
	# For color line detection, a valid chain is any chain of 5+ same-color pieces
	if chain.size() < 5:
		return false
	
	# All pieces in chain must have the same color
	var first_color = chain[0].piece_color
	for piece in chain:
		if piece.piece_color != first_color:
			return false
	
	# Check if pieces form a valid line (consecutive positions)
	return _is_consecutive_line(chain)

static func _is_consecutive_line(chain):
	# Check if pieces form a straight line (horizontal, vertical, or diagonal)
	if chain.size() < 5:
		return false
	
	# Get positions and sort them
	var positions = []
	for piece in chain:
		positions.append(piece.grid_position)
	
	# Sort by x, then y
	positions.sort_custom(func(a, b): return a.x < b.x)
	
	# Check if line is horizontal
	var is_horizontal = true
	var first_y = positions[0].y
	for pos in positions:
		if pos.y != first_y:
			is_horizontal = false
			break
	
	if is_horizontal:
		# Check if positions are consecutive
		positions.sort_custom(func(a, b): return a.x < b.x)
		for i in range(1, positions.size()):
			if positions[i].x != positions[i-1].x + 1:
				return false
		return true
	
	# Check if line is vertical 
	var is_vertical = true
	var first_x = positions[0].x
	for pos in positions:
		if pos.x != first_x:
			is_vertical = false
			break
	
	if is_vertical:
		# Check if positions are consecutive
		positions.sort_custom(func(a, b): return a.y < b.y)
		for i in range(1, positions.size()):
			if positions[i].y != positions[i-1].y + 1:
				return false
		return true
	
	# Check if line is diagonal (top-left to bottom-right)
	var is_diagonal_1 = true
	for i in range(1, positions.size()):
		if positions[i].x != positions[i-1].x + 1 or positions[i].y != positions[i-1].y + 1:
			is_diagonal_1 = false
			break
	
	if is_diagonal_1:
		return true
	
	# Check if line is diagonal (top-right to bottom-left)
	var is_diagonal_2 = true
	for i in range(1, positions.size()):
		if positions[i].x != positions[i-1].x - 1 or positions[i].y != positions[i-1].y + 1:
			is_diagonal_2 = false
			break
	
	if is_diagonal_2:
		return true
	
	return false
