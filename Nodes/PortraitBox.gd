extends Control

class_name PortraitBox


var _portrait: AnimatedSprite2D = null
var _audio_player: AudioStreamPlayer2D = null


func _ready():
	_portrait = $Panel/Portrait
	_audio_player = get_node("../../AudioPlayer")


func setup(portrait: SpriteFrames, audio: AudioStream) -> void:
	_portrait.setup(portrait, 1, Vector2(1, 2))
	_audio_player.set_voice_sound(audio)


func set_voice_sound(audio: AudioStream) -> void:
	_audio_player.set_voice_sound(audio)


## Play the voice sound.
## Pass True to wait for previous sound to finish, otherwise False.
func play_voice(talk_anim: String = "talk", wait_to_play: bool = true) -> void:
	_portrait.play_animation(talk_anim)
	_audio_player.play_voice_sound(wait_to_play)
