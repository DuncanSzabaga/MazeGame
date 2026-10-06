extends CanvasLayer

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if get_tree().paused:
			visible = false
			get_tree().paused = false
		else:
			visible = true
			get_tree().paused = true

func _ready() -> void:
	visible = false
	get_tree().paused = false

func _process(delta: float) -> void:
	pass


func _on_resume_pressed() -> void:
	visible = false
	get_tree().paused = false


func _on_main_menu_pressed() -> void:
	visible = false
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu.tscn")
