extends Node2D

@onready var screen_1: TextureRect = $Screen1
@onready var screen_2: TextureRect = $Screen2
@onready var screen_3: TextureRect = $Screen3
@onready var screen_4: TextureRect = $Screen4
@onready var screen_5: TextureRect = $Screen5
@onready var sprite_1: Sprite2D = $Screen1/Sprite1
@onready var sprite_2: Sprite2D = $Screen2/Sprite2
@onready var sprite_3: Sprite2D = $Screen3/Sprite3
@onready var sprite_4: Sprite2D = $Screen4/Sprite4
@onready var sprite_5: Sprite2D = $Screen5/Sprite5


var skip: bool = false
var is_ending: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await play_cutscene()
	skip_to_level()

# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	pass

func _on_skip_pressed() -> void:
	skip_to_level()

func screens_visible() -> void:
	screen_1.visible = true
	screen_2.visible = true
	screen_3.visible = true
	screen_4.visible = true
	screen_5.visible = true
	
func screens_invisible() -> void:
	screen_1.visible = false
	screen_2.visible = false
	screen_3.visible = false
	screen_4.visible = false
	screen_5.visible = false
	
func sprites_invisible() -> void:
	sprite_1.visible = false
	sprite_2.visible = false
	sprite_3.visible = false
	sprite_4.visible = false
	sprite_5.visible = false

func skip_to_level() -> void:
	if is_ending:
		return

	is_ending = true

	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished

	if is_inside_tree():
		get_tree().change_scene_to_file("res://Levels/Level1.tscn")
	
func play_cutscene() -> void:
	await play_screen(screen_1, sprite_1)
	if is_ending:
		return
		
	await play_screen(screen_2, sprite_2)
	if is_ending:
		return

	await play_screen(screen_3, sprite_3)
	if is_ending:
		return

	await play_screen(screen_4, sprite_4)
	if is_ending:
		return

	await play_screen(screen_5, sprite_5)

	if not is_ending:
		skip_to_level()

func play_screen(screen: TextureRect, sprite: Sprite2D) -> void:
	if screen == screen_3:
		sprite.position = Vector2(620.0, 335.0)
	else:
		sprite.position = Vector2(615.0, 350.0)
	screen.visible = true
	sprite.visible = true

	var start_position = sprite.position
	var tween = create_tween()

	for i in 2:
		tween.tween_property(
			sprite,
			"position",
			start_position + Vector2(randi_range(-2,2), randi_range(6,10)),
			1.0
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(
			sprite,
			"position",
			start_position + Vector2(randi_range(-2,2), randi_range(-6,-10)),
			1.0
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished

	if is_ending:
		return

	if screen != screen_5:
		sprite.visible = false
		sprite.position = start_position
		screen.visible = false
