extends SceneTree

const HudMessageLogScript = preload("res://scripts/ui/HudMessageLog.gd")
const SessionHistoryScript = preload("res://scripts/session/SessionHistory.gd")

func _initialize():
	var failures: Array[String] = []
	var messages = HudMessageLogScript.new(2.0, 2)
	messages.add_message("old", 0.0)
	messages.add_message("first", 3.0)
	messages.add_message("second", 3.5)
	if messages.get_text() != "first\nsecond":
		failures.append("HUD message log did not expire and limit entries")

	var history = SessionHistoryScript.new(2)
	history.add("one", {"pieces": [1]})
	history.add("two", {"pieces": [2]})
	history.add("three", {"pieces": [3]})
	if history.size() != 2 or history.get_entry(0).get("text") != "three":
		failures.append("session history did not preserve newest entries")

	if failures.is_empty():
		print("All session model tests passed")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)
