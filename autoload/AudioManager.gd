extends Node

var _sfx_players: Array[AudioStreamPlayer] = []
var _music_player: AudioStreamPlayer
var _current_music: AudioStream

const MAX_SFX_PLAYERS := 8

func _ready():
	_music_player = AudioStreamPlayer.new()
	add_child(_music_player)
	_music_player.bus = "Master"
	
	for i in range(MAX_SFX_PLAYERS):
		var player := AudioStreamPlayer.new()
		add_child(player)
		player.bus = "Master"
		_sfx_players.append(player)

func play_sound(sound_name: String, volume_db: float = 0.0):
	if not Settings.sound_enabled:
		return
	
	var stream: AudioStream = null
	var path := "res://assets/sounds/" + sound_name + ".wav"
	if ResourceLoader.exists(path):
		stream = load(path)
	
	if stream:
		_play_sfx(stream, volume_db)

func _play_sfx(stream: AudioStream, volume_db: float):
	for player in _sfx_players:
		if not player.playing:
			player.stream = stream
			player.volume_db = volume_db
			player.play()
			return

func play_music(music_name: String, fade_duration: float = 1.0):
	if not Settings.sound_enabled:
		return
	
	var new_music: AudioStream = null
	var path := "res://assets/sounds/" + music_name + ".ogg"
	if ResourceLoader.exists(path):
		new_music = load(path)
	
	if new_music:
		_cross_fade_music(new_music, fade_duration)

func _cross_fade_music(new_music: AudioStream, duration: float):
	_current_music = new_music
	if _music_player.playing:
		var tween := create_tween()
		tween.tween_property(_music_player, "volume_db", -80.0, duration)
		tween.tween_callback(_music_player.stop)
		tween.tween_callback(_music_player.play)
		tween.tween_property(_music_player, "volume_db", 0.0, duration)
	_music_player.stream = new_music
	_music_player.play()

func stop_music():
	_music_player.stop()

func vibrate():
	if Settings.vibration_enabled:
		Input.vibrate_handheld(100)
