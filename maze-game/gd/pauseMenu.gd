extends CanvasLayer

var is_changing_pause = false

func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel") or event.is_echo():
		return

	if is_changing_pause:
		return

	pause()

func pause() -> void:
	is_changing_pause = true

	if get_tree().paused:
		get_tree().paused = false
		TransitionScreen.transition()
		await TransitionScreen.on_transition_finished
		visible = false
	else:
		TransitionScreen.transition()
		await TransitionScreen.on_transition_finished
		visible = true
		get_tree().paused = true
		
	is_changing_pause = false

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
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
