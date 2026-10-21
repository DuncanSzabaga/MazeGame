extends CharacterBody2D

@export var enemy_path: Array[Vector2] = []
@export var dectection_radius: float = 200
@export var lose_radius: float = 200
@export var health = 3

var player : Node2D
var tilemap
var move_num = 0
const tile_size: Vector2 = Vector2(64, 64)
var sprite_node_pos_tween = create_tween()
var chase = false
var chase_path = []
var was_chasing = false
var moved = false
var facing = Vector2.DOWN
var dir: Vector2


enum FacingDirection {
	UP,
	DOWN,
	LEFT,
	RIGHT
}

func _move_enemy():
	var new_tile = null
	if chase:
		dir = direction_player()
		while new_tile == null:
			new_tile = global_position + dir * tile_size
			var coords = tilemap.local_to_map(new_tile)
			var tile_data = tilemap.get_cell_tile_data(coords)
			if tile_data.get_custom_data("TileValue") != 0:
				new_tile = null
				var directions = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
				directions.shuffle()
				dir = directions[0]
		chase_path.append(dir)
	elif not chase_path.is_empty():
		dir = chase_path.pop_back()
		dir *= -1
	else:
		dir = enemy_path[move_num]
	if dir == Vector2.UP:
		$AnimatedSprite2D.play("up_animation")
	elif dir == Vector2.DOWN:
		$AnimatedSprite2D.play("down_animation")
	elif dir == Vector2.LEFT:
		$AnimatedSprite2D.play("left_animation")
	elif dir == Vector2.RIGHT:
		$AnimatedSprite2D.play("right_animation")
	if facing != dir and chase:
		facing = dir
		moved = false
		chase_path.pop_back()
	elif facing != dir and not chase and not was_chasing:
		facing = dir
		moved = false
	else:
		global_position += dir * tile_size
		moved = true
		player = get_tree().get_first_node_in_group("player")
		if global_position.distance_to(player.global_position) < 32:
			global_position -= dir * tile_size
			if not chase_path.is_empty():
				chase_path.pop_back()
			if !player.damaged_this_move and not player.shield:
				HealthManager.take_damage()
				player.damaged_this_move = true
				
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
			
			#await sprite_node_pos_tween.finished
		
		if not chase and chase_path.is_empty():
			if not was_chasing:
				move_num += 1
				if move_num >= enemy_path.size():
					move_num = 0
	print("The rat's move_num value is: " + str(move_num))
		
func _process(_delta):
	var distance = global_position.distance_to(player.global_position)
	
	if not chase and distance <= dectection_radius:
		chase = true
		print("chasing!")
	
	elif chase and distance >= lose_radius:
		chase = false
		was_chasing = true
		print("not chasing.")
	elif not chase and chase_path.is_empty():
			was_chasing = false
		
func _ready():
	player = get_tree().get_first_node_in_group("player")
	$AnimatedSprite2D.play("down_idle")
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finished)
	tilemap = get_parent()

func _on_animation_finished():
	if $AnimatedSprite2D.animation == "up_animation":
		$AnimatedSprite2D.play("up_idle")
	elif $AnimatedSprite2D.animation == "down_animation":
		$AnimatedSprite2D.play("down_idle")
	elif $AnimatedSprite2D.animation == "left_animation":
		$AnimatedSprite2D.play("left_idle")
	elif $AnimatedSprite2D.animation == "right_animation":
		$AnimatedSprite2D.play("right_idle")
		
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
func _flash_red():
	var tween = create_tween()
	tween.tween_property(
		$AnimatedSprite2D,
		"modulate",
		Color.RED,
		0.1
	)
	tween.tween_property(
		$AnimatedSprite2D,
		"modulate",
		Color.WHITE,
		0.1
	)
	
func take_damage(damage):
	health -= damage
	_flash_red()
	print("taken damage: ", health)
	if health <= 0:
		SFXManager.play_sound(preload("res://soundEffects/enemydie.mp3"), -14.0)
		queue_free()
