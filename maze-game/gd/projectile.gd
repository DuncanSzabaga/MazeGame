extends CharacterBody2D

const SPEED = 175.0
const LEFT_X = -224
const RIGHT_X = 800
const TOP_Y = -160
const BOTTOM_Y = 480
const COOLDOWN = 20.0
const CENTER = Vector2(288,160)
const MAX_ANGLE_OFFSET = deg_to_rad(40.0)
const SCALE_TIME = 1.0
var health = 3
var curr_speed = 0
var dir : Vector2
var is_respawning = false

func _physics_process(delta: float) -> void:
	if is_respawning:
		return
	var collision = move_and_collide(dir * curr_speed * delta)
	var collider
	if collision:
		collider = collision.get_collider()
		# if projectile hit level bounds
		if collider == $"../LevelBounds":
			await shrink()
			new_projectile()

func _ready():
	$AnimatedSprite2D.visible = false
	$AnimatedSprite2D.play("fly_animation")
	new_projectile()
	
func shrink():
	print("projectile shrinking")
	curr_speed = 0
	var tween = create_tween()
	tween.tween_property(
		$AnimatedSprite2D, "scale", Vector2(0.01, 0.01), SCALE_TIME
	)
	await tween.finished
	$AnimatedSprite2D.visible = false
	print("projectile done shrinking")

func grow():
	print("projectile growing")
	$AnimatedSprite2D.visible = true
	curr_speed = 0
	var tween = create_tween()
	tween.tween_property(
		$AnimatedSprite2D, "scale", Vector2.ONE/4, SCALE_TIME
	)
	await tween.finished
	curr_speed = SPEED
	print("projectile done growing")

func new_projectile():
	if is_respawning:
		return
	is_respawning = true
	curr_speed = 0
	print("projectile spawned")
	await get_tree().create_timer(COOLDOWN + randi_range(0,COOLDOWN/2)).timeout
	# randomize position of projectile
	position = random_spawn()
	dir = random_direction(position)
	
	$AnimatedSprite2D.scale = Vector2(0.01, 0.01)
	await grow()
	
	curr_speed = SPEED
	is_respawning = false
	
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
