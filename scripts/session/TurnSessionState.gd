extends RefCounted
class_name TurnSessionState

var total_turns: int = 0
var clean_turns: int = 0
var current_turn_had_take: bool = false
var pending_kingdom_completion_win: bool = false
var pending_survival_round_completion: bool = false
var spawn_excluded_cells: Array[Vector2i] = []

func reset():
	total_turns = 0
	clean_turns = 0
	current_turn_had_take = false
	pending_kingdom_completion_win = false
	pending_survival_round_completion = false
	spawn_excluded_cells.clear()

func mark_take():
	current_turn_had_take = true

func complete_turn():
	total_turns += 1
	if not current_turn_had_take:
		clean_turns += 1
	current_turn_had_take = false
	spawn_excluded_cells.clear()

func exclude_spawn_cell(cell: Vector2i):
	if cell not in spawn_excluded_cells:
		spawn_excluded_cells.append(cell)

func has_pending_completion() -> bool:
	return pending_kingdom_completion_win or pending_survival_round_completion
