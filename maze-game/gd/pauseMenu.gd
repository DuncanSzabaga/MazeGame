extends CanvasLayer

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if get_tree().paused:
			get_tree().paused = false
			TransitionScreen.transition()
			await TransitionScreen.on_transition_finished
			visible = false
			
		else:
			TransitionScreen.transition()
			await TransitionScreen.on_transition_finished
			visible = true
			await get_tree().create_timer(0.51).timeout
			get_tree().paused = true

func _ready() -> void:
	visible = false
	get_tree().paused = false

func _process(delta: float) -> void:
	pass


func _on_resume_pressed() -> void:
	get_tree().paused = false
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	visible = false


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	visible = false
	get_tree().change_scene_to_file("res://main_menu.tscn")
