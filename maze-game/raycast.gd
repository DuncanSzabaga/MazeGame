extends RayCast2D

func _ready() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	for i in enemies.size():
		add_exception(enemies[i])
