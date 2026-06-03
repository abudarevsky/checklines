extends RefCounted
class_name BoardStateRules

const NORMAL_SPAWN_COUNT: int = 3

static func is_loss_board_state(empty_cells: Array, required_spawn_count: int = 3) -> bool:
	return empty_cells.size() < required_spawn_count
