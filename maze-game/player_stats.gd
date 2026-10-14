extends CanvasLayer

@onready var heart1 = $Hearts/Heart1
@onready var heart2 = $Hearts/Heart2
@onready var heart3 = $Hearts/Heart3
@onready var powerup_text = $powerText
@onready var steps_text = $steps
var last_health = 3


var full_heart = preload("res://Assets/itemsANDextras/filledHeart.png")
var empty_heart = preload("res://Assets/itemsANDextras/noHeart.png")


func _process(delta):
	if HealthManager.current_health != last_health:
		update_hearts()
		last_health = HealthManager.current_health
	
	var player = get_tree().current_scene.get_node("player")
	
	if player.atkDmg == 2:
		steps_text.text = "Steps: " + str(player.stepsTaken) + "/15"
	elif player.stepsTaken == 0:
		steps_text.text = "PowerUp Deactivated"

func _ready():
	update_hearts()

func update_hearts():
	heart1.texture = full_heart if HealthManager.current_health >= 1 else empty_heart
	heart2.texture = full_heart if HealthManager.current_health >= 2 else empty_heart
	heart3.texture = full_heart if HealthManager.current_health >= 3 else empty_heart
	
func show_powerup(powerup_id):
	match powerup_id:
		0:
			powerup_text.text = "PowerUp Activated: attack Up"
		1:
			powerup_text.text = "PowerUp Activated: Full heal"
		2:
			powerup_text.text = "PowerUp Activated: partial heal"
		3:
			powerup_text.text = "PowerUp Activated: Ranged Attack"
		4:
			powerup_text.text = "PowerUp Activated: Shield"
	
	
