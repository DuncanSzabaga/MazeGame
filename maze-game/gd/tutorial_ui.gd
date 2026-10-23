
extends CanvasLayer

@onready var instruction_label: Label = $Panel/instructions
@onready var player = get_tree().get_first_node_in_group("player")
@onready var enemy = get_tree().get_first_node_in_group("enemies")
@onready var tilemap = get_tree().current_scene.get_node("MazeLayout")
var tutorialSteps := 0


func _ready() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		enemy.tutorialMode = true
	instruction_label.text = "Press WASD or arrow keys to move. This can be changed in the settings"


func _process(_delta: float) -> void:
	var player_tile = tilemap.local_to_map(
		tilemap.to_local(player.global_position)
	)
	#print("Player tile: ", player_tile)
	if tutorialSteps == 0:
		if (
			Input.is_action_just_pressed("move_left")
			or Input.is_action_just_pressed("move_right")
			or Input.is_action_just_pressed("move_up")
			or Input.is_action_just_pressed("move_down")
			or Input.is_action_just_pressed("move_left_arrow")
			or Input.is_action_just_pressed("move_right_arrow")
			or Input.is_action_just_pressed("move_up_arrow")
			or Input.is_action_just_pressed("move_down_arrow")
		):
			instruction_label.text = "Great! Move towards the other rat"
			if player.global_position.distance_to(enemy.global_position) <= 80:
				tutorialSteps = 1

	elif tutorialSteps == 1:
		instruction_label.text = "To attack we have to press SPACE to get ready, then the 
		direction you want to attack. PRESS SPACE"
		if Input.is_action_just_pressed("attack"):
			tutorialSteps = 2
			instruction_label.text = "Now press the direction you want to attack"

	elif tutorialSteps == 2:
		if enemy.tutorialTakenDMG:
			tutorialSteps = 3
			instruction_label.text = "See how the enemy changed color? That's how you know it hit! Now go
			to the next room"
	elif tutorialSteps == 3:
		#var tilemap = get_tree().get_first_node_in_group("tilemap")
		#var player_tile = tilemap.local_to_map()
		tilemap.to_local(player.global_position)
		if player_tile == Vector2i(14, 1):
			#tutorialSteps = 4
			instruction_label.text = "Now lets learn the powerups, Stand over them to learn about it. When your done collect the cheese to move to the real levels!"
		if player_tile == Vector2i(34, 1):
			instruction_label.text = "That was the ranged attack, it shoots in any direction no matter the distance. You only get 2 shots with it"
		if player_tile == Vector2i(38, 1):
			instruction_label.text = "That was the shield. become invincible for a only 15 steps"
		if player_tile == Vector2i(22, 1):
			instruction_label.text = "This powerup gives you a +1 attack bonus"
		if player_tile == Vector2i(26, 1):
			instruction_label.text = "this sets your health to full"
		if player_tile == Vector2i(30, 1):
			instruction_label.text = "this increases your health by 1"
			
			

func _on_skip_pressed() -> void:
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	get_tree().change_scene_to_file("res://Levels/Level1.tscn")
