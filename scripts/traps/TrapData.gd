extends Resource
class_name TrapData

enum Behavior { SWALLOW_AND_EMIT, RECOLOR_AND_EMIT }

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var display_name_key: String = ""
@export var description_key: String = ""
@export var behavior: Behavior = Behavior.SWALLOW_AND_EMIT
@export var level_spawn_counts: PackedInt32Array = PackedInt32Array([2, 3, 3])
@export var base_color: Color = Color(0.84, 0.84, 0.78, 0.72)
@export var wave_color: Color = Color(0.08, 0.1, 0.13, 0.28)
@export var border_color: Color = Color(0.08, 0.08, 0.08, 0.55)
@export var shadow_dark_color: Color = Color(0.03, 0.035, 0.045, 0.22)
@export var shadow_light_color: Color = Color(1.0, 0.96, 0.82, 0.16)
@export var light_cell_tint: Color = Color(1.08, 1.08, 1.04, 1.0)
@export var dark_cell_tint: Color = Color(0.78, 0.82, 0.9, 1.0)
@export var wave_strength: float = 0.16
@export var wave_speed: float = 0.35
@export var wave_frequency: float = 7.0

func get_spawn_count(level_index: int) -> int:
	if level_spawn_counts.is_empty():
		return 2
	var safe_level := maxi(level_index, 0)
	if safe_level < level_spawn_counts.size():
		return maxi(level_spawn_counts[safe_level], 0)
	return maxi(level_spawn_counts[level_spawn_counts.size() - 1], 0)
