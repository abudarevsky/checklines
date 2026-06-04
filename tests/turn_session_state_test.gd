extends SceneTree

const TurnSessionStateScript = preload("res://scripts/session/TurnSessionState.gd")

func _initialize():
	var failures: Array[String] = []
	var state = TurnSessionStateScript.new()
	state.exclude_spawn_cell(Vector2i(1, 2))
	state.exclude_spawn_cell(Vector2i(1, 2))
	state.complete_turn()
	if state.total_turns != 1 or state.clean_turns != 1:
		failures.append("clean turn was not recorded")
	if not state.spawn_excluded_cells.is_empty():
		failures.append("completed turn kept spawn exclusions")
	state.mark_take()
	state.complete_turn()
	if state.total_turns != 2 or state.clean_turns != 1:
		failures.append("take turn was counted as clean")

	if failures.is_empty():
		print("All turn session state tests passed")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)
