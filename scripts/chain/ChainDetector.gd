extends Node
class_name ChainDetector

static func find_chains(board: Dictionary):
	var all_chains = []
	var pieces = board.values()
	
	if pieces.size() < 5:
		return all_chains
	
	var adjacency = _build_attack_graph(board)
	
	for piece in pieces:
		var visited = [piece]
		_dfs_find_chains(piece, adjacency, visited, all_chains)
	
	var valid_chains = []
	for chain in all_chains:
		if chain.size() >= 5:
			valid_chains.append(chain)
	
	return valid_chains

static func _build_attack_graph(board: Dictionary):
	var adjacency = {}
	var pieces = board.values()
	
	for piece in pieces:
		adjacency[piece] = []
	
	for piece in pieces:
		var targets = piece.get_legal_captures(board)
		for target in targets:
			if board.has(target):
				var target_piece = board[target]
				if target_piece.piece_color != piece.piece_color:
					adjacency[piece].append(target_piece)
	
	return adjacency

static func _dfs_find_chains(current, adjacency, visited, all_chains):
	if visited.size() >= 5:
		var chain_copy = []
		for p in visited:
			chain_copy.append(p)
		all_chains.append(chain_copy)
	
	if visited.size() >= 9:
		return
	
	var neighbors = adjacency[current]
	for neighbor in neighbors:
		if not neighbor in visited:
			visited.append(neighbor)
			_dfs_find_chains(neighbor, adjacency, visited, all_chains)
			visited.pop_back()

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
	if chain.size() < 5:
		return false
	
	for i in range(chain.size() - 1):
		if chain[i].piece_color == chain[i + 1].piece_color:
			return false
		if not chain[i].can_attack(chain[i + 1].grid_position, {}):
			return false
	
	return true