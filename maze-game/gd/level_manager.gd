extends Node2D

signal on_level_complete

var level_complete: bool = false
var current_level: int = 1
var audio_stream_player = AudioStreamPlayer.new()
var lvlComplete = preload("res://Music/levelwin.mp3")
func reset_game():
	current_level = 1
	
func _ready():
	add_child(audio_stream_player)
	
func complete_level():
	on_level_complete.emit()
	current_level += 1
	await get_tree().create_timer(0.1).timeout
	get_tree().paused = true
	SFXManager.play_sound(preload("res://Music/levelwin.mp3"))
	await get_tree().create_timer(2.0).timeout
	TransitionScreen.transition()
	get_tree().paused = false
	await TransitionScreen.on_transition_finished
	var scene = get_tree().current_scene.name
	if scene == "LevelInf":
		get_tree().change_scene_to_file("res://Levels/LevelINF.tscn")
	if scene == "Tutorial":
		current_level = 1
		get_tree().change_scene_to_file("res://Levels/Level1.tscn")
	elif current_level == 2:
		get_tree().change_scene_to_file("res://Levels/Level2.tscn")
	elif current_level == 3:
		get_tree().change_scene_to_file("res://Levels/Level3.tscn")
	

func _on_on_level_complete() -> void:
	level_complete = true
	await get_tree().create_timer(0.01).timeout
	level_complete = false
