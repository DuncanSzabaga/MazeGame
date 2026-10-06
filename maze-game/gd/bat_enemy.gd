extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0


func _ready():
	$AnimatedSprite2D.play("fly_animation")
