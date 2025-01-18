class_name DialogueSystem
extends Control

# Customise (FOR USER)
@export
var _voice_snd_effect: AudioStream = load("res://addons/Suada/Assets/Sounds/vocal_sound_1.ogg")
@export var _default_font: Font = load("res://addons/Suada/Assets/Fonts/FixedsysExcelsior.tres")
@export var _default_color: Color = Color.WHITE
@export var _default_choice: Color = Color.YELLOW
@export var _interact_key: String = "key_a"
@export var _up_key: String = "key_up"
@export var _down_key: String = "key_down"

# Setup
var _interact_key_pressed: bool = false
var _up_key_pressed: int = 0
var _down_key_pressed: int = 0
var _scale_factor = 1
var _offset: Vector2 = Vector2(10 * _scale_factor, 14 * _scale_factor)

var _page = 0
var _next_line: Array = []
var _pause = false
var _exiting = false
var _chosen = false
var _choice = 0
var _conversation: Dictionary[int, Dialog] = {}

@onready var _dialogue_box: DialogueTextBox = $DialogueContainer/TextBox
@onready var _name_box: MarginContainer = $NameBox
@onready var _name_box_text: NameTextBox = $NameBox/TextBox/Text
@onready var _portrait_box: MarginContainer = $DialogueContainer/PortraitBox


## Add a convesation and setup the dialog system.
func add_conversation(conversation: Dictionary[int, Dialog]) -> void:
	_conversation = conversation
	_setup()


func _set_portrait(portrait: Portrait) -> void:
	_portrait_box.setup(load(portrait.portrait_path) as SpriteFrames, _voice_snd_effect)


func _reset_keys_states() -> void:
	_interact_key_pressed = false
	_up_key_pressed = 0
	_down_key_pressed = 0


func _process(_delta):
	if _page < 0 or _page >= _conversation.size():
		if _interact_key_pressed:
			_handle_exit(0.2)
		return

	if not _dialogue_box.is_complete():
		if _interact_key_pressed:
			_dialogue_box.show_all_text()
			_reset_keys_states()
		return

	# Interact behaviour
	if _interact_key_pressed:
		if _conversation[_page].type == Types.DialogType.NORMAL:
			_page = _conversation[_page].next
			if _page != -1:
				_set_portrait(_conversation[_page].portrait)
				_setup()
			else:
				_handle_exit(0.5)
		elif _conversation[_page].type == Types.DialogType.CHOICE and not _chosen:
			_chosen = true
			_handle_dialogue_choice()
	# Change Choice
	elif _down_key_pressed or _up_key_pressed:
		var change_choice = _down_key_pressed - _up_key_pressed
		if change_choice != 0:
			_choice += change_choice

		if _choice < 0:
			_choice = len(_conversation[_page].choices) - 1
		elif _choice > len(_conversation[_page].choices) - 1:
			_choice = 0

		_handle_dialogue_change_choice(true)

	_reset_keys_states()


func _input(event):
	if event.is_action_pressed(_interact_key):
		_interact_key_pressed = true
	else:
		_interact_key_pressed = false

	# Do not check up/down keys if text is not complete
	if _dialogue_box.is_complete():
		if event.is_action_pressed(_up_key):
			_up_key_pressed = 1
		else:
			_up_key_pressed = 0

		if event.is_action_pressed(_down_key):
			_down_key_pressed = 1
		else:
			_down_key_pressed = 0


func _reset() -> void:
	_choice = 0
	_chosen = false
	_pause = false


func _setup() -> void:
	_reset()

	_portrait_box.setup(
		load(_conversation[0].portrait.portrait_path) as SpriteFrames, _voice_snd_effect
	)

	if _page < 0 or _page >= _conversation.size():
		printerr("Wrong conversation position.")
		return

	var name_str = _conversation[_page].name
	_name_box.visible = !name_str.is_empty()
	if _name_box.visible:
		_name_box_text.change_name(name_str)

	var text = _conversation[_page].text
	if _conversation[_page].type == Types.DialogType.CHOICE:
		_handle_dialogue_change_choice()
		return

	_dialogue_box.set_text(text, _default_font)


## Handle the dialogue choice
func _handle_dialogue_choice() -> void:
	_handle_pause(0.1)

	if _choice > _conversation.size():
		printerr("Choice position out of conversation.")
		queue_free()
		return

	if _choice == -1:
		queue_free()
		return

	_page = _conversation[_page].choices[_choice].next
	_setup()


func _handle_dialogue_change_choice(visible: bool = false) -> void:
	var text = _conversation[_page].text
	for choice_index in _conversation[_page].choices.size():
		var choice_text = _conversation[_page].choices[choice_index].text

		text += "\n"

		if choice_index == _choice:
			text += "[color=" + _default_choice.to_html() + "]" + choice_text + "[/color]"
		else:
			text += choice_text

	_dialogue_box.set_text(text, _default_font, _default_color, visible)


func _handle_pause(time: float) -> void:
	_pause = true
	await get_tree().create_timer(time)
	_pause = false


func _handle_exit(time: float) -> void:
	if _exiting:
		return

	_exiting = true
	await get_tree().create_timer(time)
	queue_free()
