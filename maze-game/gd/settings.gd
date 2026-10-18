extends CanvasLayer
signal arrow_keys_active
signal awsd_keys_active

static var _arrow_keys_active = false
static var _awsd_keys_active = true

@onready var arrow_keys: Button = $arrowKeys
@onready var awsd_keys: Button = $awsdKeys

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	arrow_keys.modulate = Color(0.722, 0.576, 0.271, 1.0)
	awsd_keys.modulate = Color(0.722, 0.576, 0.271, 1.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_pressed() -> void:
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	get_tree().change_scene_to_file("res://main_menu.tscn")


func _on_awsd_button_pressed() -> void:
	awsd_keys_active.emit()
	arrow_keys.modulate = Color(0.722, 0.576, 0.271, 1.0)


func _on_arrow_button_pressed() -> void:
	arrow_keys_active.emit()
