extends SceneTree

const ConfigStoreScript = preload("res://scripts/persistence/ConfigStore.gd")
const TEST_PATH := "res://tmp/persistence_store_test.cfg"

func _initialize():
	var failures: Array[String] = []
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://tmp"))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH))

	ConfigStoreScript.save_values("game", {"high_score": 42}, TEST_PATH)
	ConfigStoreScript.save_values("settings", {"theme_id": "neon"}, TEST_PATH)
	ConfigStoreScript.save_values("progress", {"level": 3}, TEST_PATH)

	var config := ConfigStoreScript.load_config(TEST_PATH)
	if int(config.get_value("game", "high_score", 0)) != 42:
		failures.append("settings write erased game section")
	if str(config.get_value("settings", "theme_id", "")) != "neon":
		failures.append("progress write erased settings section")
	if int(config.get_value("progress", "level", 0)) != 3:
		failures.append("progress section was not saved")

	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH))
	if failures.is_empty():
		print("All persistence store tests passed")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)
