extends AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not Settings.show_tutorial and Settings.show_cutscene:
		play(MainMenu.playback_pos+.11)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
