extends CanvasLayer
signal arrow_keys_active
signal awsd_keys_active

static var music_volume = 1.5

static var _arrow_keys_active = false
static var _awsd_keys_active = true

@export
var bus_name: String = "Master"
var bus_index: int

@onready var arrow_keys: Button = $arrowKeys
@onready var awsd_keys: Button = $awsdKeys
@onready var music_slider: HSlider = $musicSlider

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	arrow_keys.modulate = Color(0.722, 0.576, 0.271, 1.0)
	awsd_keys.modulate = Color(0.722, 0.576, 0.271, 1.0)
	bus_index = AudioServer.get_bus_index(bus_name)
	music_slider.set_value_no_signal(music_volume)
	AudioServer.set_bus_volume_db(
		bus_index,
		linear_to_db(music_volume)
	)
	music_slider.value_changed.connect(_on_music_slider_value_changed)

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


func _on_music_slider_value_changed(value: float) -> void:
	music_volume = value
	AudioServer.set_bus_volume_db(
		bus_index,
		linear_to_db(music_volume)
	)
