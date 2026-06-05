extends RefCounted
class_name HudMessageLog

var entries: Array[Dictionary] = []
var recent_window_seconds: float
var max_entries: int

func _init(window_seconds: float = 2.0, entry_limit: int = 2):
	recent_window_seconds = window_seconds
	max_entries = entry_limit

func clear():
	entries.clear()

func append(entry: Dictionary):
	entries.append(entry)

func add_message(text: String, now_seconds: float):
	var recent_entries: Array[Dictionary] = []
	for entry in entries:
		if now_seconds - float(entry.get("time", 0.0)) <= recent_window_seconds:
			recent_entries.append(entry)
	recent_entries.append({"text": text, "time": now_seconds})
	while recent_entries.size() > max_entries:
		recent_entries.pop_front()
	entries = recent_entries

func get_text() -> String:
	var lines := PackedStringArray()
	for entry in entries:
		lines.append(str(entry.get("text", "")))
	return " * ".join(lines)
