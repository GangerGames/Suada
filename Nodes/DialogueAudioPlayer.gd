extends AudioStreamPlayer2D


## Sets the audio of the voice.
##
## @param audio The voice.
func set_voice_sound(audio: AudioStream):
	stream = audio


## Play the voice sound.
##
## @param wait_to_play If true, waits until the last sound was played.
func play_voice_sound(wait_to_play: bool = true):
	if wait_to_play:
		if !self.playing:
			self.play()
	else:
		self.play()
