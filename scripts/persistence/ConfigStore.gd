extends RefCounted
class_name ConfigStore

const DEFAULT_PATH := "user://settings.cfg"

static func load_config(path: String = DEFAULT_PATH) -> ConfigFile:
	var config := ConfigFile.new()
	config.load(path)
	return config

static func save_values(section: String, values: Dictionary, path: String = DEFAULT_PATH) -> Error:
	return save_sections({section: values}, path)

static func save_sections(sections: Dictionary, path: String = DEFAULT_PATH) -> Error:
	var config := load_config(path)
	for section in sections:
		var values: Dictionary = sections[section]
		for key in values:
			config.set_value(str(section), str(key), values[key])
	return config.save(path)
