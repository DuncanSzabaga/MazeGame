extends CanvasLayer

class_name Settings

static var music_volume = 1.0

static var _arrow_keys_active = false
static var _awsd_keys_active = true

static var show_tutorial = true
static var show_cutscene = true

static var from_settings = false

@export
var bus_name: String = "Master"
var bus_index: int

@onready var arrow_keys: Button = $arrowKeys
@onready var awsd_keys: Button = $awsdKeys
@onready var music_slider: HSlider = $musicSlider
@onready var arrow_keys_text: Label = $ArrowKeysText
@onready var awsd_keys_text: Label = $AwsdKeysText
@onready var arrow_selected: Polygon2D = $ArrowSelected
@onready var awsd_selected: Polygon2D = $AwsdSelected
@onready var background: AudioStreamPlayer = $background
@onready var tutorial: CheckBox = $Tutorial
@onready var cutscene: CheckBox = $Cutscene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tutorial.button_pressed = show_tutorial
	cutscene.button_pressed = show_cutscene
	bus_index = AudioServer.get_bus_index(bus_name)
	music_slider.set_value_no_signal(music_volume)
	AudioServer.set_bus_volume_db(
		bus_index,
		linear_to_db(music_volume)
	)
	music_slider.value_changed.connect(_on_music_slider_value_changed)
	background.play(MainMenu.playback_pos+.11)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _awsd_keys_active:
		awsd_selected.visible = true
		arrow_selected.visible = false
		awsd_keys.modulate = Color(0.926, 0.739, 0.274, 1.0)
		arrow_keys.modulate = Color(0.539, 0.488, 0.388, 1.0)
	elif _arrow_keys_active:
		awsd_selected.visible = false
		arrow_selected.visible = true
		arrow_keys.modulate = Color(0.926, 0.739, 0.274, 1.0)
		awsd_keys.modulate = Color(0.651, 0.615, 0.536, 1.0)
	
	if tutorial.button_pressed:
		show_tutorial = true
	else:
		show_tutorial = false
		
	if cutscene.button_pressed:
		show_cutscene = true
	else:
		show_cutscene = false


func _on_back_pressed() -> void:
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	background.get_playback_position()
	MainMenu.playback_pos = background.get_playback_position()
	from_settings = true
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	from_settings = false


func _on_awsd_button_pressed() -> void:
	print("awsd active")
	_awsd_keys_active = true
	_arrow_keys_active = false

func _on_music_slider_value_changed(value: float) -> void:
	music_volume = value
	AudioServer.set_bus_volume_db(
		bus_index,
		linear_to_db(music_volume)
	)


func _on_arrow_keys_pressed() -> void:
	print("arrows active")
	_awsd_keys_active = false
	_arrow_keys_active = true
