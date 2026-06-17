extends RefCounted
class_name TrapProfile

const DEFAULT_PROFILE: Dictionary = {
	"trap_counts_by_level": [0, 1, 2, 3],
	"trap_rotation_enabled": false,
	"trap_rotation_limits_by_level": [0, 1, 2, -1],
	"trap_rotation_chances_by_level": [0, 0.18, 0.18, 0.3],
	"big_swamp_pulse_probabilities_by_level": [0, 0.20, 0.40, 1],
	"pulse_duration_seconds": 5.0,
	"failed_pulse_spawn_count": 2,
	"allow_king_target": false,
	"max_active_pulses": 1,
	"big_swamp_max_target_distance_cells": 1,
}
const PROFILES_BY_KINGDOM: Dictionary = {
	"default": DEFAULT_PROFILE,
	"neon": DEFAULT_PROFILE,
}

static func get_profile(kingdom_id: String) -> Dictionary:
	return PROFILES_BY_KINGDOM.get(kingdom_id.strip_edges(), DEFAULT_PROFILE)

static func get_level_int(key: String, level_index: int, kingdom_id: String = "", fallback: int = 0) -> int:
	if level_index < 0:
		return fallback
	var values: Array = get_profile(kingdom_id).get(key, [])
	if values.is_empty():
		return fallback
	return int(values[mini(level_index, values.size() - 1)])

static func get_level_probability(key: String, level_index: int, kingdom_id: String = "", fallback: float = 0.0) -> float:
	if level_index < 0:
		return fallback
	var values: Array = get_profile(kingdom_id).get(key, [])
	if values.is_empty():
		return fallback
	return clampf(float(values[mini(level_index, values.size() - 1)]), 0.0, 1.0)

static func get_value(key: String, kingdom_id: String = "", fallback: Variant = null) -> Variant:
	return get_profile(kingdom_id).get(key, fallback)
