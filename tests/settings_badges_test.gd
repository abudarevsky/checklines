extends SceneTree

const SettingsScript = preload("res://autoload/Settings.gd")

func _initialize():
	var failures: Array[String] = []

	_run_test("loss does not change tactical badge value", _test_loss_does_not_change_tactical_badge_value, failures)
	_run_test("win replaces tactical badge value with latest session", _test_win_replaces_tactical_badge_value, failures)
	_run_test("legacy best clean turn stats migrate to last won value", _test_legacy_best_clean_turn_stats_migrate_to_last_won_value, failures)
	_run_test("kingdom start level advances and resets", _test_kingdom_start_level_advances_and_resets, failures)
	_run_test("completed level stars never decrease", _test_completed_level_stars_never_decrease, failures)
	_run_test("completed level progress normalizes from saved settings", _test_completed_level_progress_normalizes_from_saved_settings, failures)
	_run_test("progress badge level starts at one", _test_progress_badge_level_starts_at_one, failures)
	_run_test("progress badge level keeps completed level four", _test_progress_badge_level_keeps_completed_level_four, failures)
	_run_test("start level repairs missing completed progress", _test_start_level_repairs_missing_completed_progress, failures)
	_run_test("survival rounds persist and do not decrease", _test_survival_rounds_persist_and_do_not_decrease, failures)
	_run_test("reset keeps badge and survival progress", _test_reset_keeps_badge_and_survival_progress, failures)

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

func _test_completed_level_stars_never_decrease() -> String:
	var settings = SettingsScript.new()
	settings.kingdom_progress_levels = {"neon": 3}
	settings.record_kingdom_completed_level("neon", 1)

	var error_message := ""
	if settings.get_kingdom_max_completed_level("neon") != 3:
		error_message = "lower completion removed permanent progression stars"
	elif settings.get_kingdom_progress_badge_tier("neon") != 3:
		error_message = "lower completion reduced the progression badge tier"

	settings.free()
	return error_message

func _test_completed_level_progress_normalizes_from_saved_settings() -> String:
	var settings = SettingsScript.new()
	var normalized: Dictionary = settings._normalize_kingdom_progress_levels({
		"neon": 4,
		"": 3
	})
	settings.kingdom_progress_levels = normalized

	var error_message := ""
	if not normalized.has("neon"):
		error_message = "saved completed level was not normalized"
	elif settings.get_kingdom_max_completed_level("neon") != 4:
		error_message = "saved completed level did not survive normalization"
	elif settings.get_kingdom_progress_badge_tier("neon") != 3:
		error_message = "saved Level 4 progress should still render the gold progression badge"
	elif normalized.has(""):
		error_message = "empty kingdom id was preserved during normalization"

	settings.free()
	return error_message

func _test_progress_badge_level_starts_at_one() -> String:
	var settings = SettingsScript.new()

	var error_message := ""
	if settings.get_kingdom_max_completed_level("neon") != 0:
		error_message = "empty kingdom unexpectedly has completed progress"
	elif settings.get_kingdom_progress_badge_tier("neon") != 0:
		error_message = "empty kingdom should keep an empty badge tier"
	elif settings.get_kingdom_progress_badge_level("neon") != 1:
		error_message = "empty kingdom should display Level 1 on the badge"

	settings.free()
	return error_message

func _test_progress_badge_level_keeps_completed_level_four() -> String:
	var settings = SettingsScript.new()
	settings.kingdom_progress_levels = {"neon": 4}

	var error_message := ""
	if settings.get_kingdom_progress_badge_tier("neon") != 3:
		error_message = "completed Level 4 should still use the gold badge tier"
	elif settings.get_kingdom_progress_badge_level("neon") != 4:
		error_message = "completed Level 4 was not exposed to the menu badge"

	settings.free()
	return error_message

func _test_start_level_repairs_missing_completed_progress() -> String:
	var settings = SettingsScript.new()
	settings.kingdom_progress_levels = {}
	settings.kingdom_start_levels = {"default": 3, "neon": 0}
	settings._reconcile_completed_levels_with_start_levels()

	var error_message := ""
	if settings.get_kingdom_start_level_index("default") != 3:
		error_message = "expected default kingdom to keep Level 4 start"
	elif settings.get_kingdom_max_completed_level("default") != 3:
		error_message = "Level 4 start did not repair missing completed progress"
	elif settings.get_kingdom_progress_badge_tier("default") != 3:
		error_message = "repaired Level 4 start did not render the gold progression badge"
	elif settings.get_kingdom_max_completed_level("neon") != 0:
		error_message = "Level 1 start should not create neon progress"

	settings.free()
	return error_message

func _test_survival_rounds_persist_and_do_not_decrease() -> String:
	var settings = SettingsScript.new()
	settings.kingdom_survival_rounds = {"neon": 2}

	var error_message := ""
	if settings._record_kingdom_survival_rounds_in_memory("neon", 1):
		error_message = "lower survival round count replaced saved progress"
	elif not settings._record_kingdom_survival_rounds_in_memory("neon", 3):
		error_message = "higher survival round count was not recorded"
	elif settings.get_kingdom_survival_rounds("neon") != 3:
		error_message = "survival round count did not persist in memory"

	settings.free()
	return error_message

func _test_reset_keeps_badge_and_survival_progress() -> String:
	var settings = SettingsScript.new()
	settings.kingdom_start_levels = {"neon": 3}
	settings.kingdom_progress_levels = {"neon": 4}
	settings.kingdom_survival_rounds = {"neon": 2}

	settings.kingdom_start_levels.erase("neon")

	var error_message := ""
	if settings.get_kingdom_start_level_index("neon") != 0:
		error_message = "reset did not clear start level"
	elif settings.get_kingdom_max_completed_level("neon") != 4:
		error_message = "reset cleared completed badge progress"
	elif settings.get_kingdom_survival_rounds("neon") != 2:
		error_message = "reset cleared survival progress"

	settings.free()
	return error_message
