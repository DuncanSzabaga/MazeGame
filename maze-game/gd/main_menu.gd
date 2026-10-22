extends Control

class_name MainMenu

@onready var background: AudioStreamPlayer = $background

static var playback_pos = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	background.play(playback_pos+.11)

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
	get_tree().change_scene_to_file("res://Scenes/cutscene.tscn")
	
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
