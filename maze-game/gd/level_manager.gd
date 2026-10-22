extends Node2D
var current_level: int = 1

func reset_game():
	current_level = 1
	
func complete_level():
	current_level += 1
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
	
