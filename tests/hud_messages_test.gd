extends SceneTree

func _initialize():
	_run.call_deferred()

func _run():
	var failures: Array[String] = []
	var board_scene: PackedScene = load("res://scenes/board/GameBoard.tscn")
	var game_board = board_scene.instantiate()
	root.add_child(game_board)
	await process_frame
	await process_frame

	var message_label: Label = game_board.get_node("CanvasLayer/ScoreClip/MessageLabel")

	game_board._queue_message("Pawn Sacrifice   -2")
	await process_frame
	if message_label.text != "Pawn Sacrifice   -2":
		failures.append("expected first HUD message immediately, got '%s'" % message_label.text)

	game_board._queue_message("Color Line   +10")
	await process_frame
	if message_label.text != "Pawn Sacrifice   -2 * Color Line   +10":
		failures.append("expected single-line joined HUD log, got '%s'" % message_label.text)

	game_board.hud_message_log.clear()
	game_board.hud_message_log.append({
		"text": "Old Message",
		"time": Time.get_ticks_msec() / 1000.0 - 3.0
	})
	game_board._queue_message("Fresh Message")
	await process_frame
	if message_label.text != "Fresh Message":
		failures.append("expected old HUD message to expire, got '%s'" % message_label.text)

	var game_manager = root.get_node("GameManager")
	game_manager.current_score = 20
	game_board.hud_message_log.clear()
	game_board._on_capture_made(null, Vector2i.ZERO, game_manager.PieceType.PAWN)
	await process_frame
	if message_label.text.strip_edges().is_empty():
		failures.append("expected capture sacrifice HUD message, got '%s'" % message_label.text)

	game_manager.current_score = 0
	game_board.hud_message_log.clear()
	game_board._on_capture_made(null, Vector2i.ZERO, game_manager.PieceType.PAWN)
	await process_frame
	if message_label.text.strip_edges().is_empty():
		failures.append("expected zero-score capture HUD message, got '%s'" % message_label.text)

	var title_label: Label = game_board.get_node("CanvasLayer/UI/GameOverOverlay/CenterContainer/GameOverPanel/VBox/TitleLabel")
	var summary_label: Label = game_board.get_node("CanvasLayer/UI/GameOverOverlay/CenterContainer/GameOverPanel/VBox/SummaryLabel")
	game_board.is_final_survival_dialog = true
	game_board.survived_rounds = 2
	game_board._update_game_over_dialog(0, game_manager.GAME_RESULT_WIN, false)
	if title_label.text != "You fell, but heroes never die!":
		failures.append("expected survival fall title, got '%s'" % title_label.text)
	if summary_label.text != "Survived 2 times":
		failures.append("expected survival summary, got '%s'" % summary_label.text)

	var board_manager = game_board.get_node("BoardManager")
	var effects_container = board_manager.get_node("EffectsContainer")
	var trap_visuals_container = board_manager.get_node("TrapVisualsContainer")
	board_manager.play_board_fog_effect()
	board_manager.set_traps([Vector2i(0, 0)], "swallow")
	game_board._queue_message("Moving under dialog")
	await process_frame
	if effects_container.get_child_count() <= 0:
		failures.append("expected setup to create an active board effect")
	if trap_visuals_container.get_child_count() <= 0:
		failures.append("expected setup to create an active trap visual")
	game_board._on_game_over(0, game_manager.GAME_RESULT_LOSS, false)
	await process_frame
	if effects_container.get_child_count() != 0:
		failures.append("expected game over to clear board effects")
	if trap_visuals_container.get_child_count() != 0:
		failures.append("expected game over to clear trap visuals")
	if message_label.text != "":
		failures.append("expected game over to stop HUD message animation")

	game_board.queue_free()
	await process_frame
	if failures.is_empty():
		print("All HUD message tests passed")
		quit(0)
		return

	for failure in failures:
		push_error(failure)
	quit(1)
