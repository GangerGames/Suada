extends Control

# Imports
const Types = preload("res://addons/Suada/Nodes/Objects/Types.gd")

# Customise (FOR USER)
@export var _voice_snd_effect: AudioStream = null

@export var _default_font: Font = load("res://addons/Suada/Assets/Fonts/FixedsysExcelsior.tres")

var _interact_key: String = "key_a"
var _interact_key_pressed: bool = false
var _up_key: String = "key_up"
var _up_key_pressed: int = 0
var _down_key: String = "key_down"
var _down_key_pressed: int = 0

var _scale_factor = 1
var _offset: Vector2 = Vector2(10 * _scale_factor, 14 * _scale_factor)

@onready var _dialogue_box: DialogueTextBox = $DialogueContainer/TextBox
@onready var _name_box: MarginContainer = $NameBox
@onready var _name_box_text: NameTextBox = $NameBox/TextBox/Text
@onready var _portrait_box: MarginContainer = $DialogueContainer/PortraitBox

# Setup (LEAVE THIS STUFF)
var _page = 0
var _next_line: Array = []
var _pause = false
var _exiting = false
var _chosen = false
var _choice = 0

var _conversation: Array[Dialog] = []


## Add a convesation and setup the dialog system.
func add_conversation(conversation: Array) -> void:
	_conversation = conversation
	_setup()


func _set_portrait(portrait: Portrait) -> void:
	_portrait_box.setup(
		load(portrait.portrait_path) as SpriteFrames, _voice_snd_effect
	)


func _process(_delta):
	if _page < 0 or _page >= _conversation.size():
		if _interact_key_pressed:
			_handle_exit(0.2)
		return

	# We check the type of dialogue to see if it is 1) "normal" or 2) a player choice dialogue.
	if _conversation[_page].type == Types.DialogType.NORMAL:
		if _interact_key_pressed:
			if not _dialogue_box.is_complete():
				_dialogue_box.show_all_text()
			elif _page + 1 < _conversation.size():
				# Only increase page IF page + 1,is less than the total number of entries.
				match _next_line[_page][0]:
					-1:
						_handle_exit(0.2)
						return
					0:
						_set_portrait(_conversation[_page].portrait)
						_page += 1
					_:
						_page = _next_line[_page][0]

				_setup()
			else:
				_handle_exit(0.5)
	else:
		if _chosen:
			return

		if _interact_key_pressed:
			_chosen = true
			_handle_dialogue_choice()

			# Change Choice
			var change_choice = _down_key_pressed - _up_key_pressed
			if change_choice != 0:
				_choice += change_choice

			if _choice < 0:
				_choice = _conversation[_page].get_text().length - 1
			elif _choice > _conversation[_page].get_text().length - 1:
				_choice = 0

	_interact_key_pressed = false

	queue_redraw()


func _draw():
	if _page < 0 or _page >= _conversation.size():
		return


func _input(event):
	if event.is_action_pressed(_interact_key):
		_interact_key_pressed = true
	else:
		_interact_key_pressed = false

	if event.is_action_pressed(_up_key):
		_up_key_pressed = 1
	else:
		_up_key_pressed = 0

	if event.is_action_pressed(_down_key):
		_down_key_pressed = 1
	else:
		_down_key_pressed = 0


func _setup() -> void:
	_portrait_box.setup(
		load(_conversation[0].portrait.portrait_path) as SpriteFrames, _voice_snd_effect
	)

	if _page < 0 or _page >= _conversation.size():
		return

	var name_str = _conversation[_page].name
	_name_box.visible = !name_str.is_empty()
	if _name_box.visible:
		_name_box_text.change_name(name_str)

	if _conversation[_page].type == 0:
		_dialogue_box.set_text(_conversation[_page].text, _default_font)


## Handle the dialogue choice
func _handle_dialogue_choice() -> void:
	_handle_pause(0.1)

	if _page + 1 < _conversation.size():
		var nl = _next_line[_page]
		match nl[_choice]:
			-1:
				queue_free()
				return
			0:
				_page += 1
			_:
				_page = nl[_choice]

		_setup()
	else:
		queue_free()

	_chosen = false


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
