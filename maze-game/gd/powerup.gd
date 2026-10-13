extends StaticBody2D
class_name PowerUp

enum POWERUP_TYPE {
	FULLHEAL,
	HEAL,
	ATTACKUP,
	RANGEDATTACK,
	SHIELD
}

@export var powerup_id = 0

func _ready() -> void:
	if powerup_id > 4 or powerup_id < 0:
		powerup_id = 0
	$AnimatedSprite2D.frame = powerup_id

func collect_powerup():
	match powerup_id:
		0: #fullheal
			pass
		1: #heal
			pass
		2: #attackup
			pass
		3: #rangedattack
			pass
		4: #shield
			pass
	queue_free()
