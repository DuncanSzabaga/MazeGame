extends CanvasLayer

@onready var heart1 = $Hearts/Heart1
@onready var heart2 = $Hearts/Heart2
@onready var heart3 = $Hearts/Heart3

var full_heart = preload("res://Assets/itemsANDextras/filledHeart.png")
var empty_heart = preload("res://Assets/itemsANDextras/noHeart.png")

func _ready():
	update_hearts()

func update_hearts():
	print("update heart debug -> something wrong with the visual update???", HealthManager.current_health)
	heart1.texture = full_heart if HealthManager.current_health >= 1 else empty_heart
	heart2.texture = full_heart if HealthManager.current_health >= 2 else empty_heart
	heart3.texture = full_heart if HealthManager.current_health >= 3 else empty_heart
