extends RefCounted
class_name TrapLibrary

const TrapDataScript = preload("res://scripts/traps/TrapData.gd")

const SWALLOW_TRAP_ID := "swallow"

static func get_trap(trap_id: String) -> Resource:
	match trap_id:
		SWALLOW_TRAP_ID:
			return _build_swallow_trap()
	return _build_swallow_trap()

static func get_default_trap_id() -> String:
	return SWALLOW_TRAP_ID

static func _build_swallow_trap() -> Resource:
	var trap := TrapDataScript.new()
	trap.id = SWALLOW_TRAP_ID
	trap.display_name = "Swallow"
	trap.behavior = TrapDataScript.Behavior.SWALLOW_AND_EMIT
	trap.level_spawn_counts = PackedInt32Array([2, 2, 3])
	trap.base_color = Color(0.42, 0.56, 0.66, 0.3)
	trap.wave_color = Color(0.05, 0.1, 0.18, 0.3)
	trap.border_color = Color(0.02, 0.05, 0.08, 0.3)
	trap.shadow_dark_color = Color(0.01, 0.02, 0.035, 0.3)
	trap.shadow_light_color = Color(0.95, 0.98, 1.0, 0.3)
	trap.light_cell_tint = Color(1.18, 1.16, 1.08, 1.0)
	trap.dark_cell_tint = Color(0.62, 0.7, 0.86, 1.0)
	trap.wave_strength = 0.14
	trap.wave_speed = 0.32
	trap.wave_frequency = 6.5
	return trap
