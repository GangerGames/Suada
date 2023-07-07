class_name DialogueTextBox
extends Control

var _text_next_char_it: float = 0

@onready var _text_label = $Panel/Text as RichTextLabel
@onready var _portrait_box: PortraitBox = $"../PortraitBox"
@onready var _finished_effect: Sprite2D = $FinishEffect


func _ready():
	if SuadaGlobals.text_speed == -1:
		_text_label.visible_characters = -1


func _process(_delta):
	if _text_label.text.is_empty():
		return

	if _text_label.visible_ratio == 1:
		_finished_effect.visible = true
		return

	var text = _text_label.text

	_text_next_char_it = (
		SuadaGlobals.text_speed
		if _text_next_char_it >= 1
		else _text_next_char_it + SuadaGlobals.text_speed
	)
	_text_label.visible_characters += _text_next_char_it

	var letter = text[_text_label.visible_characters - 1]
	if SuadaGlobals.vocal_sound:
		if letter == "a" or letter == "e" or letter == "i" or letter == "o" or letter == "u":
			_portrait_box.play_voice()
	else:
		_portrait_box.play_voice()


func set_text(text: String, font: Font, colour: Color = Color.WHITE, visible: bool = false) -> void:
	_text_label.text = text
	_text_label.add_theme_font_override("normal_font", font)
	_text_label.add_theme_color_override("default_color", colour)
	_text_label.visible_characters = -1 if visible else 0


func show_all_text():
	_text_label.visible_characters = -1


func is_complete() -> bool:
	return _text_label.visible_ratio == 1
