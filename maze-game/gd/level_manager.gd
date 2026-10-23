extends Node2D
var current_level: int = 1
var audio_stream_player = AudioStreamPlayer.new()
var lvlComplete = preload("res://Music/levelwin.mp3")
func reset_game():
	current_level = 1
	
func _ready():
	add_child(audio_stream_player)
	
func complete_level():
	current_level += 1
	audio_stream_player.stream = lvlComplete
	audio_stream_player.play()
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	var scene = get_tree().current_scene.name
	if scene == "LevelInf":
		get_tree().change_scene_to_file("res://Levels/LevelINF.tscn")
	if scene == "Tutorial":
		current_level = 1
		get_tree().change_scene_to_file("res://Levels/Level1.tscn")
		
	elif current_level == 2:
		get_tree().change_scene_to_file("res://Levels/Level2.tscn")
	
