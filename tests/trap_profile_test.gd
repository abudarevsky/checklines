extends SceneTree

const TrapProfileScript = preload("res://scripts/traps/TrapProfile.gd")

func _initialize():
	var failures: Array[String] = []
	if TrapProfileScript.get_level_int("trap_counts_by_level", 0, "default") != 0:
		failures.append("expected level zero to have no traps")
	if TrapProfileScript.get_level_int("trap_counts_by_level", 20, "default") != 3:
		failures.append("expected later levels to reuse final trap count")
	if not is_equal_approx(TrapProfileScript.get_level_probability("big_swamp_pulse_probabilities_by_level", 1, "default"), 0.2):
		failures.append("expected configured pulse probability")
	if TrapProfileScript.get_profile("missing") != TrapProfileScript.DEFAULT_PROFILE:
		failures.append("expected missing kingdom to use default profile")
	var neon_theme := load("res://themes/neon_theme.tres") as ThemeData
	if neon_theme == null or neon_theme.trap_type_id != "light":
		failures.append("expected neon kingdom to use Light Trap")

	if failures.is_empty():
		print("All trap profile tests passed")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)
