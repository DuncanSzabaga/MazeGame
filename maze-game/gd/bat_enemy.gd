extends CharacterBody2D
@onready var player: CharacterBody2D = $"../player"
@onready var bat_range: Area2D = $"Bat Range"

const SPEED = 100.0
const LEFT_X = -224
const RIGHT_X = 800
const TOP_Y = -160
const BOTTOM_Y = 480
const COOLDOWN = 20.0
#const CENTER = Vector2(288,160)
#const MAX_ANGLE_OFFSET = deg_to_rad(25.0)
const SCALE_TIME = 1.0
var health = 3
var curr_speed = 0
var dir : Vector2
var is_respawing = false

func _physics_process(delta: float) -> void:
	dir = global_position.direction_to(player.global_position)
	velocity = dir * curr_speed
	move_and_slide()
	check_bounds()
			
func check_bounds() -> void:
	if is_respawing:
		return
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		if collider == $"../LevelBounds":
			is_respawing = true
			await shrink_bat()
			$AnimatedSprite2D.visible = false
			new_bat()
			return

func _ready():
	$AnimatedSprite2D.visible = false
	$AnimatedSprite2D.play("fly_animation")
	new_bat()
	
func shrink_bat():
	print("Shrinking bat")
	curr_speed = 0
	var tween = create_tween()
	tween.tween_property(
		$AnimatedSprite2D, "scale", Vector2(0.01, 0.01), SCALE_TIME
	)
	await tween.finished
	print("Bat done shrinking")

func grow_bat():
	print("Growing Bat")
	curr_speed = 0
	var tween = create_tween()
	tween.tween_property(
		$AnimatedSprite2D, "scale", Vector2.ONE, SCALE_TIME
	)
	await tween.finished
	curr_speed = SPEED
	print("Bat done growing")

func new_bat():
	print("Bat spawned")
	await get_tree().create_timer(COOLDOWN + randi_range(0,COOLDOWN/2)).timeout
	# randomize position of bat
	position = random_spawn()
	#dir = random_direction(position)
	
	$AnimatedSprite2D.scale = Vector2(0.01, 0.01)
	$AnimatedSprite2D.visible = true
	print("bat is visible")
	await grow_bat()
	is_respawing = false
	
func random_spawn() -> Vector2:
	var X_first = [0, 1].pick_random()
	var x := -248
	var y := 552
	if X_first :
		# generate x coordinate first
		x = randi_range(LEFT_X, RIGHT_X)
		y = [0, 1].pick_random()
		if y == 0:
			y = TOP_Y
		else:
			y = BOTTOM_Y
		return Vector2(x,y)
	else:
		# generate y coordinate first
		y = randi_range(TOP_Y, BOTTOM_Y)
		x = randi_range(0,1)
		if x == 0:
			x = LEFT_X
		else:
			x = RIGHT_X
		return Vector2(x,y)
	
#func random_direction(pos: Vector2) -> Vector2:
	#var toward_center := (player.global_position - pos).normalized()
	#var random_angle := randf_range(-MAX_ANGLE_OFFSET, MAX_ANGLE_OFFSET)
#
	#return toward_center.rotated(random_angle)
