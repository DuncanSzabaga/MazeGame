extends CharacterBody2D

const SPEED = 175.0
const LEFT_X = -248
const RIGHT_X = 848
const TOP_Y = 552
const BOTTOM_Y = -296
const COOLDOWN = 10.0
const CENTER = Vector2(288,160)
const MAX_ANGLE_OFFSET = deg_to_rad(25.0)
var health = 3
var curr_speed = 0
var dir : Vector2

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(dir * curr_speed * delta)
	var collider
	if collision:
		collider = collision.get_collider()
		# if bat hit level bounds
		#if collider == $"../LevelBounds":
		#	curr_speed = 0
		#	$AnimatedSprite2D.visible = false
		#	new_bat()

func _ready():
	$AnimatedSprite2D.play("fly_animation")
	new_bat()

func new_bat():
	await get_tree().create_timer(COOLDOWN).timeout
	$AnimatedSprite2D.visible = true
	# randomize position of bat
	position = random_spawn()
	dir = random_direction(position)
	curr_speed = SPEED
	
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
	
func random_direction(pos: Vector2) -> Vector2:
	var toward_center := (CENTER - pos).normalized()
	var random_angle := randf_range(-MAX_ANGLE_OFFSET, MAX_ANGLE_OFFSET)

	return toward_center.rotated(random_angle)
