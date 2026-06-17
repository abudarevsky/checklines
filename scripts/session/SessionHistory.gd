extends RefCounted
class_name SessionHistory

var entries: Array[Dictionary] = []
var depth: int

func _init(history_depth: int):
	depth = maxi(history_depth, 0)

func add(text: String, snapshot: Dictionary, metadata: Dictionary = {}):
	if text.strip_edges().is_empty() or snapshot.is_empty():
		return
	entries.push_front({
		"text": text,
		"snapshot": snapshot.duplicate(true),
		"metadata": metadata.duplicate(true)
	})
	while entries.size() > depth:
		entries.pop_back()

func clear():
	entries.clear()

func is_empty() -> bool:
	return entries.is_empty()

func size() -> int:
	return entries.size()

func get_entry(index: int) -> Dictionary:
	if index < 0 or index >= entries.size():
		return {}
	return entries[index]
