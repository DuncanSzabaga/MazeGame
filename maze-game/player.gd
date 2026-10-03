extends CharacterBody2D

enum TileEffects {
	NOTHING = 0,
	PUSH_LEFT = 1,
	PUSH_RIGHT = 2
}

var waiting = true
var start_pos: Vector2 = global_position
const tile_size: Vector2 = Vector2(64, 64)
var sprite_node_pos_tween: Tween

func _physics_process(delta: float) -> void:
	if !sprite_node_pos_tween or !sprite_node_pos_tween.is_running():
		if not waiting:
			return
		if Input.is_action_just_pressed("move_up"):
			waiting = false
			await _move(Vector2.UP)
			waiting = true
		elif Input.is_action_just_pressed("move_down"):
			waiting = false
			await _move(Vector2.DOWN)
			waiting = true
		elif Input.is_action_just_pressed("move_left"):
			waiting = false
			await _move(Vector2.LEFT)
			waiting = true
		elif Input.is_action_just_pressed("move_right"):
			waiting = false
			await _move(Vector2.RIGHT)
			waiting = true
		elif Input.is_action_just_pressed("attack"):
			waiting = false
			await _ready_attack()
			waiting = true
		
func _perform_move(dir: Vector2):
	_call_enemies()
	
	global_position += dir * tile_size
	$Sprite2D.global_position -= dir * tile_size
		
	sprite_node_pos_tween = create_tween()
	sprite_node_pos_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	sprite_node_pos_tween.tween_property($Sprite2D, "global_position", global_position, 0.185).set_trans(Tween.TRANS_SINE)
	$AudioStreamPlayer2D.set_pitch_scale(randf_range(0.85, 1.15))
	$AudioStreamPlayer2D.play()
	
	await sprite_node_pos_tween.finished
	_check_enemy_overlap()

func _call_enemies():
	var enemies = get_tree().get_nodes_in_group("enemies")

	for enemy in enemies:
		enemy._move_enemy()

	for enemy in enemies:
		await enemy.sprite_node_pos_tween.finished
		

func _check_enemy_overlap():
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if (enemy.global_position == global_position):
			set_global_position(start_pos)
	
func _move(dir: Vector2):
	if _can_move(dir):
		await _perform_move(dir)
		await _apply_tile_effect()
	
func _can_move(dir):
	if dir == Vector2.UP:
		$AnimatedSprite2D.play("forward_animation")
		return !$up.is_colliding()
	if dir == Vector2.DOWN:
		$AnimatedSprite2D.play("back_animation")
		return !$down.is_colliding()
	if dir == Vector2.LEFT:
		$AnimatedSprite2D.play("left_animation")
		return !$left.is_colliding()
	if dir == Vector2.RIGHT:
		$AnimatedSprite2D.play("right_animation")
		return !$right.is_colliding()
	
func _ready_attack():
	# Code for attack stuff will go here
	await _call_enemies()
	_check_enemy_overlap()
	
func _apply_tile_effect():
	var tilemap: TileMapLayer = get_tree().get_first_node_in_group("tilemap")
	
	if not tilemap:
		return
		
	var cell :=  tilemap.local_to_map(position)
	var data: TileData = tilemap.get_cell_tile_data(cell)
	
	if not data:
		return
	
	var effect = data.get_custom_data("effect")
	
	if effect:
		match effect:
			TileEffects.NOTHING:
				pass
			TileEffects.PUSH_LEFT:
				await _move(Vector2(-1, 0))
			TileEffects.PUSH_RIGHT:
				await _move(Vector2(1, 0))
	else:
		return


# Animation Related Functions

func _ready():
	$AnimatedSprite2D.play("back_idle")
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finished)
	
func _on_animation_finished():
	if $AnimatedSprite2D.animation == "forward_animation":
		$AnimatedSprite2D.play("forward_idle")
	elif $AnimatedSprite2D.animation == "back_animation":
		$AnimatedSprite2D.play("back_idle")
	elif $AnimatedSprite2D.animation == "left_animation":
		$AnimatedSprite2D.play("left_idle")
	elif $AnimatedSprite2D.animation == "right_animation":
		$AnimatedSprite2D.play("right_idle")
	
