class_name DialogueTextBox
extends Control

var _text_next_char_it: float = 0
var _parsed_dialog: ParsedDialog = null
var _pause: bool = false

@onready var _text_label = $Panel/Text as RichTextLabel
@onready var _portrait_box: PortraitBox = $"../PortraitBox"
@onready var _finished_effect: Sprite2D = $FinishEffect


func _ready():
	if SuadaConfig.text_speed == -1:
		_text_label.visible_characters = -1


func _process(_delta):
	if _text_label.text.is_empty() or !_text_label.visible:
		return

	if _text_label.visible_ratio == 1:
		_finished_effect.visible = true
		return

	if _pause:
		return

	_text_next_char_it = (
		SuadaConfig.text_speed
		if _text_next_char_it >= 1
		else _text_next_char_it + SuadaConfig.text_speed
	)
	_text_label.visible_characters += _text_next_char_it

	var letter = _text_label.text[_text_label.visible_characters - 1].to_lower()
	_handle_effects(_text_label.visible_characters as int)
	_handle_letter_pauses(letter)

	if SuadaConfig.vocal_sound:
		if letter == "a" or letter == "e" or letter == "i" or letter == "o" or letter == "u":
			_portrait_box.play_voice()
	else:
		_portrait_box.play_voice()


func set_text(text: String, font: Font, colour: Color = Color.WHITE, visible: bool = false) -> void:
	var text_without_suada_effect = BBCParser.bbc_remover(text, BBCCodes.BBC_REXP)
	_text_label.text = text
	_parsed_dialog = BBCParser.parse(_text_label.get_parsed_text())
	_text_label.text = text_without_suada_effect

	_text_label.add_theme_font_override("normal_font", font)
	_text_label.add_theme_color_override("default_color", colour)
	_text_label.visible_characters = -1 if visible else 0


func show_all_text():
	_text_label.visible_characters = -1


func is_complete() -> bool:
	return _text_label.visible_ratio == 1


func _handle_effects(pos: int):
	if not _parsed_dialog.effects.has(pos):
		return

	var curr_effect: EffectLocation = _parsed_dialog.effects[pos]
	_parsed_dialog.effects.erase(pos)

	match curr_effect.effect:
		BBCCodes.BBC_EFFECT.WAIT:
			_handle_pause(curr_effect.value.to_int())
		_:
			pass


func _handle_letter_pauses(letter: String):
	match letter:
		",", ".":
			_handle_pause(0.1)
		"?", "!":
			_handle_pause(0.2)
		_:
			pass


func _handle_pause(time: float) -> void:
	_pause = true
	await get_tree().create_timer(time).timeout
	_pause = false
