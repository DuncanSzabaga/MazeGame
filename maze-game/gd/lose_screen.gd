extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_again_pressed() -> void:
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	if LevelManager.endless_mode:
		get_tree().change_scene_to_file("res://Levels/LevelINF.tscn")
		return
	else:
		get_tree().change_scene_to_file("res://Levels/Level1.tscn")

func _on_main_menu_pressed() -> void:
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
