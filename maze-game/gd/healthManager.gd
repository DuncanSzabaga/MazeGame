extends Node

var max_health: int = 3
var current_health: int = 3
func reset_health():
	current_health = max_health
	print("player reset health ", current_health)
	

func take_damage():
	current_health -= 1
	current_health = max(current_health,0)
	print("Player lost health! Current health: ", current_health)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("health loaded", current_health)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
