extends RefCounted
class_name TrapLibrary

const TrapDataScript = preload("res://scripts/traps/TrapData.gd")

const SWALLOW_TRAP_ID := "swallow"
const LIGHT_TRAP_ID := "light"

static func get_trap(trap_id: String) -> Resource:
	match trap_id:
		SWALLOW_TRAP_ID:
			return _build_swallow_trap()
		LIGHT_TRAP_ID:
			return _build_light_trap()
	return _build_swallow_trap()

static func get_default_trap_id() -> String:
	return SWALLOW_TRAP_ID

static func _build_swallow_trap() -> Resource:
	var trap := TrapDataScript.new()
	trap.id = SWALLOW_TRAP_ID
	trap.display_name = "Big Swamp"
	trap.description = "I'll chew you up and spit you out."
	trap.display_name_key = "trap_swallow_name"
	trap.description_key = "trap_swallow_description"
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

static func _build_light_trap() -> Resource:
	var trap := TrapDataScript.new()
	trap.id = LIGHT_TRAP_ID
	trap.display_name = "Light Trap"
	trap.description = "Rotating light beams replace a piece with a random absent identity and call in one more."
	trap.display_name_key = "trap_light_name"
	trap.description_key = "trap_light_description"
	trap.behavior = TrapDataScript.Behavior.RECOLOR_AND_EMIT
	trap.level_spawn_counts = PackedInt32Array([1, 1, 1])
	trap.base_color = Color(0.02, 0.42, 0.62, 0.42)
	trap.wave_color = Color(0.0, 1.0, 1.0, 0.58)
	trap.border_color = Color(1.0, 0.0, 1.0, 0.62)
	trap.shadow_dark_color = Color(0.0, 0.02, 0.05, 0.22)
	trap.shadow_light_color = Color(1.0, 1.0, 0.2, 0.28)
	trap.light_cell_tint = Color(1.0, 1.24, 1.32, 1.0)
	trap.dark_cell_tint = Color(0.56, 0.9, 1.22, 1.0)
	trap.wave_strength = 0.22
	trap.wave_speed = 0.62
	trap.wave_frequency = 11.0
	return trap
