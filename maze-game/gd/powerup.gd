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
	var player_stats = get_tree().current_scene.get_node("playerstats")

	if player_stats:
		player_stats.show_powerup(powerup_id)
	match powerup_id:
		0: #atkUP
			var player = get_tree().current_scene.get_node("player")
			player.atkPowerUp()
		1: #Fullheal
			HealthManager.reset_health()
		2: #partHeal
			HealthManager.heal()
		3: #rangedattack
			var player = get_tree().current_scene.get_node("player")
			player.activateRangedAtk()
		4: #shield
			var player = get_tree().current_scene.get_node("player")
			player.activateShield()
	queue_free()
