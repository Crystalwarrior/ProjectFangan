extends Node

func fadeout_previous(duration = 1.0):
	for audio in get_children():
		var audioplayer: AudioStreamPlayer = audio
		if not audioplayer:
			continue
		var tween = audioplayer.create_tween()
		tween.tween_property(audioplayer, "volume_db", -80, duration)
		tween.tween_callback(audioplayer.queue_free)

func create_song(song: AudioStream, duration = 1.0):
	var audioplayer := AudioStreamPlayer.new()
	self.add_child(audioplayer)
	audioplayer.set_bus("Music")
	audioplayer.stream = song
	audioplayer.volume_db = -10
	audioplayer.play()
	var tween = audioplayer.create_tween()
	tween.tween_property(audioplayer, "volume_db", 0, duration)

func play_music(song: AudioStream, duration = 1.0):
	fadeout_previous(duration)
	if song == null:
		return
	create_song(song, duration)

func stop_music(duration = 1.0):
	fadeout_previous(duration)
