extends Node2D

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var player_stats: CanvasLayer = $playerstats

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if LevelManager.level_complete:
		audio_stream_player.stop()
		
