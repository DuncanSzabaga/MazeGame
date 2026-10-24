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
	
	if player.atkUp:
		steps_text.text = "Attack up shots " + str(player.atkUpHits) + "/4"
		powerup_text.text = "PowerUp Activated: Attack Up"
	elif player.shield:
		steps_text.text = "Shield hits avaliable" + str(player.shieldHits) + "/4"
		powerup_text.text = "PowerUp Activated: Shield"
	elif player.rangedAtk:
		steps_text.text = "Shots: " + str(player.num_attacks) + "/2"
		powerup_text.text = "PowerUp Activated: Ranged Attack"
	else:
		steps_text.text = ""
		powerup_text.text = "PowerUp Activated: None"

func _ready():
	# use fill_hearts if you want to start each level at full health
	fill_hearts()
	# use update_hearts if you want to maintain health across levels
	# update_hearts()

func update_hearts():
	heart1.texture = full_heart if HealthManager.current_health >= 1 else empty_heart
	heart2.texture = full_heart if HealthManager.current_health >= 2 else empty_heart
	heart3.texture = full_heart if HealthManager.current_health >= 3 else empty_heart
	
func fill_hearts():
	HealthManager.current_health = 3
	heart1.texture = full_heart
	heart2.texture = full_heart
	heart3.texture = full_heart
	
