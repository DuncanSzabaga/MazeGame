extends Node2D
var current_level: int = 1

func reset_game():
	current_level = 1
	
func complete_level():
	current_level += 1
	if current_level == 2:
		get_tree().change_scene_to_file("res://Levels/Level2.tscn")
