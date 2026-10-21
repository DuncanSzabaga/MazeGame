extends Node


func play_sound(sound: AudioStream, volume: float = -20.0):
	$AudioStreamPlayer.stop()
	$AudioStreamPlayer.volume_db = volume
	$AudioStreamPlayer.stream = sound
	$AudioStreamPlayer.play()
	pass
