extends SceneTree

const SettingsScript = preload("res://autoload/Settings.gd")

func _initialize():
	var failures: Array[String] = []

	_run_test("loss does not change tactical badge value", _test_loss_does_not_change_tactical_badge_value, failures)
	_run_test("win replaces tactical badge value with latest session", _test_win_replaces_tactical_badge_value, failures)
	_run_test("legacy best clean turn stats migrate to last won value", _test_legacy_best_clean_turn_stats_migrate_to_last_won_value, failures)
	_run_test("kingdom start level advances and resets", _test_kingdom_start_level_advances_and_resets, failures)

	if failures.is_empty():
		print("All settings badge tests passed")
		quit(0)
		return

	for failure in failures:
		push_error(failure)
	quit(1)

func _run_test(name: String, test_callable: Callable, failures: Array[String]):
	var error_message: String = test_callable.call()
	if error_message != "":
		failures.append(name + ": " + error_message)

func _test_loss_does_not_change_tactical_badge_value() -> String:
	var settings = SettingsScript.new()
	settings.kingdom_clean_turn_stats = {
		"neon": {
			"last_won_percent": 20.0,
			"clean_turns": 2,
			"total_turns": 10
		}
	}

	var changed: bool = settings._record_kingdom_clean_turn_session_in_memory("neon", 9, 10, false)
	var error_message := ""
	if changed:
		error_message = "loss reported a changed tactical badge value"
	elif not is_equal_approx(settings.get_kingdom_last_won_clean_turn_percent("neon"), 20.0):
		error_message = "loss changed the stored tactical badge percent"
	elif settings.get_kingdom_tactical_badge_tier("neon") != 2:
		error_message = "loss changed the tactical badge tier"

	settings.free()
	return error_message

func _test_win_replaces_tactical_badge_value() -> String:
	var settings = SettingsScript.new()
	settings.kingdom_clean_turn_stats = {
		"neon": {
			"last_won_percent": 30.0,
			"clean_turns": 3,
			"total_turns": 10
		}
	}

	var changed: bool = settings._record_kingdom_clean_turn_session_in_memory("neon", 1, 10, true)
	var error_message := ""
	if not changed:
		error_message = "win did not report changed tactical badge value"
	elif not is_equal_approx(settings.get_kingdom_last_won_clean_turn_percent("neon"), 10.0):
		error_message = "win did not replace the stored tactical badge percent"
	elif settings.get_kingdom_tactical_badge_tier("neon") != 1:
		error_message = "latest winning session did not downgrade tactical badge tier"

	settings.free()
	return error_message

func _test_legacy_best_clean_turn_stats_migrate_to_last_won_value() -> String:
	var settings = SettingsScript.new()
	var normalized: Dictionary = settings._normalize_kingdom_clean_turn_stats({
		"neon": {
			"best_percent": 25.0,
			"clean_turns": 5,
			"total_turns": 20
		}
	})
	settings.kingdom_clean_turn_stats = normalized

	var error_message := ""
	if not normalized.has("neon"):
		error_message = "legacy stats were not normalized"
	elif not is_equal_approx(settings.get_kingdom_last_won_clean_turn_percent("neon"), 25.0):
		error_message = "legacy best_percent was not used as last won percent"
	elif settings.get_kingdom_tactical_badge_tier("neon") != 3:
		error_message = "legacy tactical badge tier changed during migration"

	settings.free()
	return error_message

func _test_kingdom_start_level_advances_and_resets() -> String:
	var settings = SettingsScript.new()
	var error_message := ""

	if settings.get_kingdom_start_level_index("neon") != 0:
		error_message = "expected missing start level to default to 0"
	elif not settings._record_kingdom_start_level_in_memory("neon", 1):
		error_message = "expected Level 1 completion to advance start level"
	elif settings.get_kingdom_start_level_index("neon") != 1:
		error_message = "expected Level 1 completion to restart at level index 1"
	elif settings._record_kingdom_start_level_in_memory("neon", 0):
		error_message = "expected lower start level to be ignored until reset"
	elif settings.get_kingdom_start_level_index("neon") != 1:
		error_message = "lower start level changed progress"
	elif not settings._record_kingdom_start_level_in_memory("neon", 8):
		error_message = "expected higher start level to be recorded"
	elif settings.get_kingdom_start_level_index("neon") != 3:
		error_message = "expected start level to cap at Level 4 index"
	else:
		settings.kingdom_start_levels.erase("neon")
		if settings.get_kingdom_start_level_index("neon") != 0:
			error_message = "expected reset to clear start level"

	settings.free()
	return error_message
