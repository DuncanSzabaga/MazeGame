extends Control

class_name MainMenu

@onready var background: AudioStreamPlayer = $background

static var playback_pos = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(Settings.from_settings)
	if Settings.from_settings:
		background.play(playback_pos+.11)
	else:
		background.play(0.0)
	Settings.from_settings = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_exit_button_pressed() -> void:
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	get_tree().quit()

func _on_start_button_pressed() -> void:
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	if Settings.show_cutscene:
		get_tree().change_scene_to_file("res://Scenes/cutscene.tscn")
	elif Settings.show_tutorial:
		get_tree().change_scene_to_file("res://Levels/tutorial.tscn")
	else:
		get_tree().change_scene_to_file("res://Levels/Level1.tscn")
		
	
func _on_endless_button_pressed() -> void:
	LevelManager.current_level = 2
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	get_tree().change_scene_to_file("res://Levels/LevelINF.tscn")
	

func _on_settings_button_pressed() -> void:
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	playback_pos = background.get_playback_position()
	get_tree().change_scene_to_file("res://Scenes/settings.tscn")
