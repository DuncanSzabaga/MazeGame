extends Node2D

var level_complete: bool = false
var current_level: int = 1
var audio_stream_player = AudioStreamPlayer.new()
var lvlComplete = preload("res://Music/levelwin.mp3")

func reset_game():
	current_level = 1
	
func _ready():
	add_child(audio_stream_player)
	
func complete_level():
	level_complete = true
	await get_tree().create_timer(0.01).timeout
	level_complete = false
	
	current_level += 1
	
	get_tree().paused = true
	SFXManager.play_sound(preload("res://Music/levelwin.mp3"))
	await get_tree().create_timer(1.7).timeout
	TransitionScreen.transition()
	get_tree().paused = false
	await TransitionScreen.on_transition_finished
	
	var scene = get_tree().current_scene.name
	if scene == "LevelInf":
		await get_tree().create_timer(0.01).timeout
		get_tree().change_scene_to_file("res://Levels/LevelINF.tscn")
		return
	if scene == "Tutorial":
		current_level = 1
		get_tree().change_scene_to_file("res://Levels/Level1.tscn")
	elif current_level == 2:
		get_tree().change_scene_to_file("res://Levels/Level2.tscn")
	elif current_level == 3:
		get_tree().change_scene_to_file("res://Levels/Level3.tscn")
	elif current_level == 4:
		get_tree().change_scene_to_file("res://Scenes/winScreen.tscn")
	
