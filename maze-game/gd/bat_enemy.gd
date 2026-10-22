extends CharacterBody2D

@export var dectection_radius: float = 200
@export var lose_radius: float = 200
@export var health = 3

var player : Node2D

var move_turn = false
const tile_size: Vector2 = Vector2(64, 64)
var sprite_node_pos_tween = create_tween()
var chase = true
var tutorialMode = false

func _move_enemy():
	if not move_turn:
		move_turn = true
	else:
		var dir
		if chase:
			dir = direction_player()
			
		global_position += dir * tile_size
		var player = get_tree().get_first_node_in_group("player")
		if global_position.distance_to(player.global_position) < 32:
			global_position -= dir * tile_size
			if !player.damaged_this_move:
				HealthManager.take_damage()
				player.damaged_this_move = true
				if HealthManager.current_health <= 0:
					player.set_global_position(player.start_pos)
					HealthManager.reset_health()
		else:
			$Sprite2D.global_position -= dir * tile_size
			
			sprite_node_pos_tween = create_tween()
			sprite_node_pos_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
			sprite_node_pos_tween.tween_property(
				$Sprite2D,
				"global_position",
				global_position,
				0.185
			).set_trans(Tween.TRANS_SINE)
			
			await sprite_node_pos_tween.finished
			move_turn = false
		
func _process(_delta):
	var distance = global_position.distance_to(player.global_position)
	$AnimatedSprite2D.play("fly_animation")
		
func _ready():
	player = get_tree().get_first_node_in_group("player")
	$AnimatedSprite2D.play("fly_animation")

func direction_player():
	var difference = player.global_position - global_position
	if abs(difference.x) > abs(difference.y):
		if difference.x > 0:
			return Vector2.RIGHT
		else:
			return Vector2.LEFT
	else:
		if difference.y > 0:
			return Vector2.DOWN
		else:
			return Vector2.UP

func take_damage(damage):
	health -= damage
	print("taken damage: ", health)
	if health <= 0:
		SFXManager.play_sound(preload("res://soundEffects/enemydie.mp3"), -14.0)
		queue_free()
