extends Node2D

@onready var menu: VBoxContainer = $CanvasLayer/UI/MenuPanel/MenuCenter/MenuVBox
@onready var how_to_play_panel: PanelContainer = $CanvasLayer/UI/HowToPlayPanel

func _ready():
	$CanvasLayer/UI/MenuPanel/MenuCenter/MenuVBox/PlayButton.pressed.connect(_on_play_pressed)
	$CanvasLayer/UI/MenuPanel/MenuCenter/MenuVBox/HowToPlayButton.pressed.connect(_on_how_to_play_pressed)
	$CanvasLayer/UI/MenuPanel/MenuCenter/MenuVBox/QuitButton.pressed.connect(_on_quit_pressed)
	$CanvasLayer/UI/HowToPlayPanel/ContentCenter/InstructionsContainer/BackButton.pressed.connect(_on_back_pressed)
	$BoardManager.show_borders = false

func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/board/GameBoard.tscn")

func _on_how_to_play_pressed():
	how_to_play_panel.visible = true

func _on_close_how_to_play():
	how_to_play_panel.visible = false

func _on_back_pressed():
	how_to_play_panel.visible = false

func _on_quit_pressed():
	get_tree().quit()

func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel") and how_to_play_panel.visible:
		how_to_play_panel.visible = false