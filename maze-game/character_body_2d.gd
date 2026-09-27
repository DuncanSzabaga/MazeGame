extends CharacterBody2D

enum TileEffects {
	NOTHING = 0,
	PUSH_LEFT = 1,
	PUSH_RIGHT = 2
}

const tile_size: Vector2 = Vector2(64, 64)
var sprite_node_pos_tween: Tween

func _physics_process(delta: float) -> void:
	if !sprite_node_pos_tween or !sprite_node_pos_tween.is_running():
		if Input.is_action_just_pressed("move_up"):
			await _move(Vector2.UP)
		elif Input.is_action_just_pressed("move_down"):
			await _move(Vector2.DOWN)
		elif Input.is_action_just_pressed("move_left"):
			await _move(Vector2.LEFT)
		elif Input.is_action_just_pressed("move_right"):
			await _move(Vector2.RIGHT)
		
func _perform_move(dir: Vector2):
	global_position += dir * tile_size
	$Sprite2D.global_position -= dir * tile_size
		
	sprite_node_pos_tween = create_tween()
	sprite_node_pos_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	sprite_node_pos_tween.tween_property($Sprite2D, "global_position", global_position, 0.185).set_trans(Tween.TRANS_SINE)
	$AudioStreamPlayer2D.set_pitch_scale(randf_range(0.85, 1.15))
	$AudioStreamPlayer2D.play()
	
	await sprite_node_pos_tween.finished
	
func _move(dir: Vector2):
	if _can_move(dir):
		await _perform_move(dir)
		await _apply_tile_effect()
	
func _can_move(dir):
	if dir == Vector2.UP:
		return !$up.is_colliding()
	if dir == Vector2.DOWN:
		return !$down.is_colliding()
	if dir == Vector2.LEFT:
		return !$left.is_colliding()
	if dir == Vector2.RIGHT:
		return !$right.is_colliding()
	
	
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
