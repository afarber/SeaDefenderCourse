extends Node

func play_sound(sound):
	var audio_stream_player = AudioStreamPlayer.new()
	audio_stream_player.stream = sound
	add_child(audio_stream_player)
	audio_stream_player.play()
