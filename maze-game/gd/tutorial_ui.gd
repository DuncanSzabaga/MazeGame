
extends CanvasLayer

@onready var instruction_label: Label = $Panel/instructions
@onready var player = get_tree().get_first_node_in_group("player")
@onready var enemy = get_tree().get_first_node_in_group("enemies")

var tutorialSteps := 0


func _ready() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		enemy.tutorialMode = true
	instruction_label.text = "Press WASD or arrow keys to move. This can be changed in the settings"


func _process(_delta: float) -> void:
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
			instruction_label.text = "See how the enemy changed color? That's how you know it hit! Now go to the cheese to go to the next level"
		

func _on_skip_pressed() -> void:
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	get_tree().change_scene_to_file("res://Levels/Level1.tscn")
