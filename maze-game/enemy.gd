extends CharacterBody2D

@export var enemy_path: Array[Vector2] = []
var move_num = 0
const tile_size: Vector2 = Vector2(64, 64)
var sprite_node_pos_tween = Tween

func _move_enemy():
	var dir = enemy_path[move_num]
	if dir == Vector2.UP:
		$AnimatedSprite2D.play("up_animation")
	elif dir == Vector2.DOWN:
		$AnimatedSprite2D.play("down_animation")
	elif dir == Vector2.LEFT:
		$AnimatedSprite2D.play("left_animation")
	elif dir == Vector2.RIGHT:
		$AnimatedSprite2D.play("right_animation")
	
	global_position += dir * tile_size
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
	
	move_num += 1
	
	if move_num >= enemy_path.size():
		move_num = 0
		
func _ready():
	$AnimatedSprite2D.play("down_idle")
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finished)


func _on_animation_finished():
	if $AnimatedSprite2D.animation == "up_animation":
		$AnimatedSprite2D.play("up_idle")
	elif $AnimatedSprite2D.animation == "down_animation":
		$AnimatedSprite2D.play("down_idle")
	elif $AnimatedSprite2D.animation == "left_animation":
		$AnimatedSprite2D.play("left_idle")
	elif $AnimatedSprite2D.animation == "right_animation":
		$AnimatedSprite2D.play("right_idle")
