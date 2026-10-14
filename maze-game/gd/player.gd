extends CharacterBody2D

enum TileEffects {
	NOTHING = 0,
	PUSH_LEFT = 1,
	PUSH_RIGHT = 2
}

enum AttackDirection {
	UP,
	DOWN,
	LEFT,
	RIGHT
}

var attack_ready = false
var waiting = true
var damaged_this_move = false
var atkDmg = 1
var stepsTaken = 0
var start_pos: Vector2 = global_position
const tile_size: Vector2 = Vector2(64, 64)
const ATTACK_DETECTOR = preload("res://Scenes/attack_detector.tscn")
var sprite_node_pos_tween: Tween

func _physics_process(delta: float) -> void:
	if !sprite_node_pos_tween or !sprite_node_pos_tween.is_running():
		if not waiting:
			return
		if Input.is_action_just_pressed("move_up"):
			waiting = false
			if attack_ready:
				await _do_attack(AttackDirection.UP)
			else:
				await _move(Vector2.UP)
			waiting = true
			damaged_this_move = false
		elif Input.is_action_just_pressed("move_down"):
			waiting = false
			if attack_ready:
				await _do_attack(AttackDirection.DOWN)
			else:
				await _move(Vector2.DOWN)
			waiting = true
			damaged_this_move = false
		elif Input.is_action_just_pressed("move_left"):
			waiting = false
			if attack_ready:
				await _do_attack(AttackDirection.LEFT)
			else:
				await _move(Vector2.LEFT)
			waiting = true
			damaged_this_move = false
		elif Input.is_action_just_pressed("move_right"):
			waiting = false
			if attack_ready:
				await _do_attack(AttackDirection.RIGHT)
			else:
				await _move(Vector2.RIGHT)
			waiting = true
			damaged_this_move = false
		elif Input.is_action_just_pressed("attack"):
			waiting = false
			await _ready_attack()
			waiting = true
			damaged_this_move = false
		
		
func _perform_move(dir: Vector2):
	global_position += dir * tile_size
	
	countSteps()
	
	_call_enemies()
	$Sprite2D.global_position -= dir * tile_size
		
	sprite_node_pos_tween = create_tween()
	sprite_node_pos_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	sprite_node_pos_tween.tween_property($Sprite2D, "global_position", global_position, 0.185).set_trans(Tween.TRANS_SINE)
	$AudioStreamPlayer2D.set_pitch_scale(randf_range(0.85, 1.15))
	$AudioStreamPlayer2D.play()
	
	await sprite_node_pos_tween.finished
	#_check_enemy_overlap()

func _call_enemies():
	var enemies = get_tree().get_nodes_in_group("enemies")

	for enemy in enemies:
		enemy._move_enemy()

	for enemy in enemies:
		if enemy.sprite_node_pos_tween.is_running():
			await enemy.sprite_node_pos_tween.finished
		

func _check_enemy_overlap():
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if global_position.distance_to(enemy.global_position) < 32:
			HealthManager.take_damage()

			
			if HealthManager.current_health <= 0:
				set_global_position(start_pos)
				HealthManager.reset_health()
	
func _move(dir: Vector2):
	if _can_move(dir):
		await _perform_move(dir)
		await _apply_tile_effect()
	
func _can_move(dir):
	var is_colliding = null
	if dir == Vector2.UP:
		$AnimatedSprite2D.play("forward_animation")
		is_colliding = $up.get_collider()
		if is_colliding is not PowerUp:
			return !$up.is_colliding()
		else:
			is_colliding.collect_powerup()
			return true
	if dir == Vector2.DOWN:
		$AnimatedSprite2D.play("back_animation")
		is_colliding = $down.get_collider()
		if is_colliding is not PowerUp:
			return !$down.is_colliding()
		else:
			is_colliding.collect_powerup()
			return true
	if dir == Vector2.LEFT:
		$AnimatedSprite2D.play("left_animation")
		is_colliding = $left.get_collider()
		if is_colliding is not PowerUp:
			return !$left.is_colliding()
		else:
			is_colliding.collect_powerup()
			return true
	if dir == Vector2.RIGHT:
		$AnimatedSprite2D.play("right_animation")
		is_colliding = $right.get_collider()
		if is_colliding is not PowerUp:
			return !$right.is_colliding()
		else:
			is_colliding.collect_powerup()
			return true
	
func _ready_attack():
	# Code for attack stuff will go here
	attack_ready = true
	await _call_enemies()
	#_check_enemy_overlap()

func atkPowerUp():
	atkDmg = 2;
	stepsTaken = 0;

func countSteps():
	if atkDmg == 2:
		stepsTaken += 1
	if stepsTaken == 15:
		atkDmg = 1;
		stepsTaken = 0


func _do_attack(dir: AttackDirection):
	await _call_enemies()
	
	var detector = ATTACK_DETECTOR.instantiate()
	detector.global_position = global_position
	
	match dir:
		AttackDirection.UP:
			detector.global_position.y -= 64
			$AnimatedSprite2D.play("forward_idle")
		AttackDirection.DOWN:
			detector.global_position.y += 64
			$AnimatedSprite2D.play("back_idle")
		AttackDirection.LEFT:
			detector.global_position.x -= 64
			$AnimatedSprite2D.play("left_idle")
		AttackDirection.RIGHT:
			detector.global_position.x += 64
			$AnimatedSprite2D.play("right_idle")
			
	get_tree().root.add_child(detector)
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if detector.global_position.distance_to(enemy.global_position) < 32:
			enemy.take_damage(atkDmg)
	attack_ready = false
	detector.queue_free()
	
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
	start_pos = global_position
	
func _on_animation_finished():
	if $AnimatedSprite2D.animation == "forward_animation":
		$AnimatedSprite2D.play("forward_idle")
	elif $AnimatedSprite2D.animation == "back_animation":
		$AnimatedSprite2D.play("back_idle")
	elif $AnimatedSprite2D.animation == "left_animation":
		$AnimatedSprite2D.play("left_idle")
	elif $AnimatedSprite2D.animation == "right_animation":
		$AnimatedSprite2D.play("right_idle")
	
