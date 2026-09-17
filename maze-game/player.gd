extends CharacterBody2D

@export var speed: float = 100.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta):
	var direction = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)

	if direction.length() > 0:
		direction = direction.normalized()

	velocity = direction * speed
	move_and_slide()

	if direction.y < 0:
		animated_sprite.play("forward_animation")
	elif direction.y > 0:
		animated_sprite.play("back_animation")
	elif direction.x < 0:
		animated_sprite.play("left_animation")
	elif direction.x > 0:
		animated_sprite.play("right_animation")
