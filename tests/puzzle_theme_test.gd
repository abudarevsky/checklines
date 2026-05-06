extends SceneTree

func _initialize():
	var failures: Array[String] = []

	_run_test("default theme registers three puzzle images", _test_default_theme_puzzle_images, failures)

	if failures.is_empty():
		print("All puzzle theme tests passed")
		quit(0)
		return

	for failure in failures:
		push_error(failure)
	quit(1)

func _run_test(name: String, test_callable: Callable, failures: Array[String]):
	var error_message: String = test_callable.call()
	if error_message != "":
		failures.append(name + ": " + error_message)

func _test_default_theme_puzzle_images() -> String:
	var theme := load("res://themes/default_theme.tres") as ThemeData
	if theme == null:
		return "default theme failed to load"

	var expected_paths: Array[String] = [
		"res://assets/ui/themes/default/level0.png",
		"res://assets/ui/themes/default/level1.png",
		"res://assets/ui/themes/default/level2.png"
	]
	if theme.puzzle_level_images.size() != expected_paths.size():
		return "expected %d puzzle images, got %d" % [expected_paths.size(), theme.puzzle_level_images.size()]

	for i in range(expected_paths.size()):
		var texture := theme.puzzle_level_images[i] as Texture2D
		if texture == null:
			return "puzzle image %d is null" % i
		if texture.resource_path != expected_paths[i]:
			return "expected image %d to be %s, got %s" % [i, expected_paths[i], texture.resource_path]

	return ""
