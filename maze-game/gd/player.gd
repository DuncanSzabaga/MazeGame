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
var rangedAtk = false
var shield = false
var start_pos: Vector2 = global_position
var level_finished = false
const tile_size: Vector2 = Vector2(64, 64)
const ATTACK_DETECTOR = preload("res://Scenes/attack_detector.tscn")
var sprite_node_pos_tween: Tween
var last_move = AttackDirection.DOWN
var sibling

func _physics_process(delta: float) -> void:
	if !sprite_node_pos_tween or !sprite_node_pos_tween.is_running():
		if not waiting:
			return
		if Input.is_action_just_pressed("move_up"):
			last_move = AttackDirection.UP
			waiting = false
			if attack_ready:
				await _do_attack(AttackDirection.UP)
			else:
				await _move(Vector2.UP)
			waiting = true
			damaged_this_move = false
		elif Input.is_action_just_pressed("move_down"):
			last_move = AttackDirection.DOWN
			waiting = false
			if attack_ready:
				await _do_attack(AttackDirection.DOWN)
			else:
				await _move(Vector2.DOWN)
			waiting = true
			damaged_this_move = false
		elif Input.is_action_just_pressed("move_left"):
			last_move = AttackDirection.LEFT
			waiting = false
			if attack_ready:
				await _do_attack(AttackDirection.LEFT)
			else:
				await _move(Vector2.LEFT)
			waiting = true
			damaged_this_move = false
		elif Input.is_action_just_pressed("move_right"):
			last_move = AttackDirection.RIGHT
			waiting = false
			if attack_ready:
				await _do_attack(AttackDirection.RIGHT)
			else:
				await _move(Vector2.RIGHT)
			waiting = true
			damaged_this_move = false
		elif Input.is_action_just_pressed("attack"):
			_readyAttackAnimation(last_move)
			waiting = false
			await _ready_attack()
			waiting = true
			damaged_this_move = false
		
func _readyAttackAnimation(last_move: AttackDirection):
	if last_move == AttackDirection.DOWN:
		$AnimatedSprite2D.play("back_attack")
	elif last_move == AttackDirection.UP:
		$AnimatedSprite2D.play("forward_attack")
	elif last_move == AttackDirection.LEFT:
		$AnimatedSprite2D.play("left_attack")
	elif last_move == AttackDirection.RIGHT:
		$AnimatedSprite2D.play("right_attack")
		
func _attackAnimation(last_move: AttackDirection):
	var tween = create_tween()
	var start_position = $AnimatedSprite2D.position
	if last_move == AttackDirection.DOWN:
		$AnimatedSprite2D.play("back_attack")
		tween.tween_property(
			$AnimatedSprite2D,
			"position",
			start_position + Vector2(0, 6),
			0.05
		)
		tween.tween_property(
			$AnimatedSprite2D,
			"position",
			start_position,
			0.1
		)
	elif last_move == AttackDirection.UP:
		$AnimatedSprite2D.play("forward_attack")
		tween.tween_property(
			$AnimatedSprite2D,
			"position",
			start_position + Vector2(0, -6),
			0.05
		)
		tween.tween_property(
			$AnimatedSprite2D,
			"position",
			start_position,
			0.1
		)
	elif last_move == AttackDirection.LEFT:
		$AnimatedSprite2D.play("left_attack")
		tween.tween_property(
			$AnimatedSprite2D,
			"position",
			start_position + Vector2(-6, 0),
			0.05
		)
		tween.tween_property(
			$AnimatedSprite2D,
			"position",
			start_position,
			0.1
		)
	elif last_move == AttackDirection.RIGHT:
		$AnimatedSprite2D.play("right_attack")
		tween.tween_property(
			$AnimatedSprite2D,
			"position",
			start_position + Vector2(6, 0),
			0.05
		)
		tween.tween_property(
			$AnimatedSprite2D,
			"position",
			start_position,
			0.1
		)
		
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
			if not shield and not attack_ready:
				HealthManager.take_damage()

			if HealthManager.current_health <= 0:
				set_global_position(start_pos)
				HealthManager.reset_health()
				
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
	
func _move(dir: Vector2):
	if _can_move(dir):
		await _perform_move(dir)
		await _apply_tile_effect()
	if level_finished:
		LevelManager.complete_level()
	
func _can_move(dir):
	var is_colliding = null
	var target_position = global_position + dir * tile_size
	var target_cell = sibling.local_to_map(sibling.to_local(target_position))
	var tile_data = sibling.get_cell_tile_data(target_cell)
	if dir == Vector2.UP:
		$AnimatedSprite2D.play("forward_animation")
		is_colliding = $up.get_collider()
		if is_colliding is GoalObject:
			level_finished = true
			return true
		elif is_colliding is PowerUp:
			is_colliding.collect_powerup()
			return true
		else:
			if tile_data == null:
				return !$up.is_colliding()
			if tile_data.get_custom_data("TileValue") != 0:
				return false
			return !$up.is_colliding()
	if dir == Vector2.DOWN:
		$AnimatedSprite2D.play("back_animation")
		is_colliding = $down.get_collider()
		if is_colliding is GoalObject:
			level_finished = true
			return true
		elif is_colliding is PowerUp:
			is_colliding.collect_powerup()
			return true
		else:
			if tile_data == null:
				return !$down.is_colliding()
			if tile_data.get_custom_data("TileValue") != 0:
				return false
			return !$down.is_colliding()
	if dir == Vector2.LEFT:
		$AnimatedSprite2D.play("left_animation")
		is_colliding = $left.get_collider()
		if is_colliding is GoalObject:
			level_finished = true
			return true
		elif is_colliding is PowerUp:
			is_colliding.collect_powerup()
			return true
		else:
			if tile_data == null:
				return !$left.is_colliding()
			if tile_data.get_custom_data("TileValue") != 0:
				return false
			return !$left.is_colliding()
	if dir == Vector2.RIGHT:
		$AnimatedSprite2D.play("right_animation")
		is_colliding = $right.get_collider()
		if is_colliding is GoalObject:
			level_finished = true
			return true
		elif is_colliding is PowerUp:
			is_colliding.collect_powerup()
			return true
		else:
			if tile_data == null:
				return !$right.is_colliding()
			if tile_data.get_custom_data("TileValue") != 0:
				return false
			return !$right.is_colliding()
	
func _ready_attack():
	# Code for attack stuff will go here
	attack_ready = true
	await _call_enemies()
	#_check_enemy_overlap()
	
func atkPowerUp():
	atkDmg = 2;
	stepsTaken = 0;
	shield = false
	rangedAtk = false

func countSteps():
	stepsTaken +=1
	
	if atkDmg == 2 and stepsTaken == 15:
		atkDmg = 1
		stepsTaken = 0
	if shield and stepsTaken == 5:
		shield = false
		stepsTaken = 0

func activateRangedAtk():
	rangedAtk = true
	atkDmg = 1
	shield = false
	print("rangedACTIVE")
	
func activateShield():
	shield = true
	atkDmg = 1
	rangedAtk = false
	stepsTaken = 0
	
func _ranged_attack(dir: AttackDirection):
	var direction := Vector2.ZERO

	match dir:
		AttackDirection.UP:
			direction = Vector2.UP
		AttackDirection.DOWN:
			direction = Vector2.DOWN
		AttackDirection.LEFT:
			direction = Vector2.LEFT
		AttackDirection.RIGHT:
			direction = Vector2.RIGHT
		_:
			return

	print("Ranged attack fired!")

	var closest_enemy = null
	var closest_distance: float = INF

	for enemy in get_tree().get_nodes_in_group("enemies"):
		var offset: Vector2 = enemy.global_position - global_position
		var forward_distance: float = offset.dot(direction)
		var sideways_distance: float = absf(offset.cross(direction))

		# Only consider enemies ahead, in the same row or column.
		if forward_distance <= 0 or sideways_distance >= 32:
			continue

		if forward_distance < closest_distance:
			closest_distance = forward_distance
			closest_enemy = enemy

	if closest_enemy != null:
		closest_enemy.take_damage(atkDmg)
		print("Hit enemy: ", closest_enemy.name)
	else:
		print("No enemy in that direction.")

func _do_attack(dir: AttackDirection):
	await _call_enemies()
	
	if rangedAtk:
		_attackAnimation(dir)
		_ranged_attack(dir)
		attack_ready = false
		return
	var detector = ATTACK_DETECTOR.instantiate()
	detector.global_position = global_position
	
	_attackAnimation(dir)
	
	match dir:
		AttackDirection.UP:
			detector.global_position.y -= 64
			$AnimatedSprite2D.play("forward_idle")
		AttackDirection.DOWN:
			detector.global_position.y += 64
			$AnimatedSprite2D.play("back_animation")
		AttackDirection.LEFT:
			detector.global_position.x -= 64
			$AnimatedSprite2D.play("left_idle")
		AttackDirection.RIGHT:
			detector.global_position.x += 64
			$AnimatedSprite2D.play("right_idle")
			
	get_tree().root.add_child(detector)
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		var detector_pos = detector.global_position
		var enemy_pos = enemy.global_position
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
	HealthManager.on_take_damage.connect(on_take_damage)
	sibling = $"../MazeLayout"
	
func on_take_damage():
	_flash_red()
	
func _on_animation_finished():
	if $AnimatedSprite2D.animation == "forward_animation":
		$AnimatedSprite2D.play("forward_idle")
	elif $AnimatedSprite2D.animation == "back_animation":
		$AnimatedSprite2D.play("back_idle")
	elif $AnimatedSprite2D.animation == "left_animation":
		$AnimatedSprite2D.play("left_idle")
	elif $AnimatedSprite2D.animation == "right_animation":
		$AnimatedSprite2D.play("right_idle")
	
