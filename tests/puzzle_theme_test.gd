extends SceneTree

func _initialize():
	var failures: Array[String] = []

	_run_test("default theme registers three puzzle images", _test_default_theme_puzzle_images, failures)
	_run_test("missing level image falls back to image zero", _test_missing_level_image_uses_zero_index, failures)

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

func _test_missing_level_image_uses_zero_index() -> String:
	var game_board := load("res://scripts/board/GameBoard.gd")
	var images: Array = [ImageTexture.new()]

	var selected_index: int = game_board._get_puzzle_level_image_index(images, 1)
	if selected_index != 0:
		return "expected one-image theme level 1 to use image 0, got %d" % selected_index

	images = [ImageTexture.new(), ImageTexture.new()]
	selected_index = game_board._get_puzzle_level_image_index(images, 2)
	if selected_index != 0:
		return "expected missing level 2 image to use image 0, got %d" % selected_index

	images = [ImageTexture.new(), null]
	selected_index = game_board._get_puzzle_level_image_index(images, 1)
	if selected_index != 0:
		return "expected null level 1 image to use image 0, got %d" % selected_index

	return ""
