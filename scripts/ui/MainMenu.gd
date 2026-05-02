extends Control

@onready var how_to_play_panel: PanelContainer = $HowToPlayPanel
@onready var button_play: Button = $CenterContainer/MenuPanel/MenuContent/ButtonPlay
@onready var button_how_to_play: Button = $CenterContainer/MenuPanel/MenuContent/ButtonHowToPlay
@onready var button_quit: Button = $CenterContainer/MenuPanel/MenuContent/ButtonQuit
@onready var button_back: Button = $HowToPlayPanel/HowToPlayCenter/InstructionsContainer/ButtonRow/ButtonBack

func _ready():
	_lock_mobile_orientation()
	button_play.pressed.connect(_on_play_pressed)
	button_how_to_play.pressed.connect(_on_how_to_play_pressed)
	button_quit.pressed.connect(_on_quit_pressed)
	button_back.pressed.connect(_on_back_pressed)

func _lock_mobile_orientation():
	if OS.has_feature("android"):
		DisplayServer.screen_set_orientation(DisplayServer.SCREEN_PORTRAIT)

func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/board/GameBoard.tscn")

func _on_how_to_play_pressed():
	how_to_play_panel.visible = true

func _on_back_pressed():
	how_to_play_panel.visible = false

func _on_quit_pressed():
	get_tree().quit()

func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel") and how_to_play_panel.visible:
		how_to_play_panel.visible = false
