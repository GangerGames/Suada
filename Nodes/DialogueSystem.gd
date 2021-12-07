extends Node2D

# Imports
const Types = preload("res://addons/Suada/Nodes/Objects/Types.gd")
const BBCParser = preload("res://addons/Suada/Nodes/BBCParser/BBCParser.gd")

# Customise (FOR USER)
export(AudioStream) var _voice_snd_effect = null

export(Color) var _default_col: Color = Color.white
export(Color) var _choice_col: Color = Color.yellow
export(Color) var _select_col: Color = Color.orange
export(Color) var _name_col: Color = Color.orange

export(DynamicFont) var _default_font = load("res://Assets/Fonts/FixedsysExcelsior.tres")

var _interact_key: String = "key_a"
var _interact_key_pressed: bool = false
var _up_key: String = "key_up"
var _up_key_pressed: int = 0
var _down_key: String = "key_down"
var _down_key_pressed: int = 0

var _scale_factor = 1
var _offset: Vector2 = Vector2(10 * _scale_factor, 14 * _scale_factor)

var _dialogue_box: Node2D = null
var _name_box: Node2D = null
var _portrait_box: Node2D = null
var _finished_effect: Node2D = null

var _portrait_frame: AnimatedSprite = null

var _audio_player: AudioStreamPlayer2D = null

# Setup (LEAVE THIS STUFF)
var _target_fps: int = Engine.target_fps if Engine.target_fps != 0 else 60

var _dialogue_box_size: Vector2 = Vector2.ZERO
var _name_box_size: Vector2 = Vector2.ZERO
var _gui_size: Vector2 = Vector2.ZERO
var _gui_diff: int = -1
var _portrait_size: Vector2 = Vector2.ZERO

var _dialog_text_pos: Vector2 = Vector2.ZERO
var _name_box_text_pos: Vector2 = Vector2.ZERO

var _finished_num: int = -1
var _finished_spd: int = -1

var _letter: String = ""

var _char_count: float = 0
var _finished_cnt: int = 0
var _audio_cnt = 0

var _text_speed = 0
# var _text_speed_c = 0

var _page = 0
var _str_len = -1
var _pause = false
var _exiting = false
var _chosen = false
var _choice = 0

var _conversation: Array = []

var _text_ne: String = ""
var _breakpoints: Dictionary = {}
var _next_line: Array = []

var _char_size: Vector2 = Vector2.ZERO

var _animation_cnt: int = -1
var _animation_trigger: int = -1
var _animation_trigger_range: Vector2 = Vector2(1, 1)

# Effect variables
var _effect_cnt: int = 0
var _amplitude: int = 4
var _freq: int = 2


## Add a convesation and setup the dialog system.
##
## @param conversation The conversation.
func add_conversation(conversation: Array) -> void:
	_conversation = conversation
	_setup()


func _ready():
	randomize()

	_dialogue_box = get_node("DialogueBox")
	_portrait_box = get_node("PortraitBox")
	_name_box = get_node("NameBox")
	_finished_effect = get_node("FinishEffect")

	_portrait_frame = get_node("PortraitBox/PortraitSprite")
	_portrait_frame.connect("animation_finished", self, "_on_portrait_animation_finish")

	_audio_player = get_node("DialogueAudioPlayer")

	var portrait_frame_texture = get_node("PortraitBox/PortraitFrameSprite").texture as Texture
	var dialogue_box_texture = get_node("DialogueBox/DialogueBoxSprite").texture as Texture
	var name_box_texture = get_node("NameBox/NameBoxSprite").texture as Texture

	_char_size = _default_font.get_string_size("M")

	_dialogue_box_size = Vector2(
		dialogue_box_texture.get_width() * _scale_factor,
		dialogue_box_texture.get_height() * _scale_factor
	)

	_name_box_size = Vector2(
		name_box_texture.get_width() * _scale_factor,
		name_box_texture.get_height() * _scale_factor
	)

	var viewport = get_viewport().get_visible_rect()
	_gui_size = viewport.size

	_gui_diff = _gui_size.x - _dialogue_box_size.x
	_portrait_size = portrait_frame_texture.get_size() * _scale_factor

	_finished_num = 0
	_finished_spd = 15 / _target_fps

	_dialogue_box.position = Vector2(
		_gui_diff + _portrait_size.x, _gui_size.y - (_dialogue_box_size.y / 2) - 4
	)

	_portrait_box.position = Vector2(
		_dialogue_box.position.x - (_dialogue_box_size.x / 2) - (_portrait_size.x / 2),
		_dialogue_box.position.y
	)

	_name_box.position = Vector2(
		(
			_dialogue_box.position.x
			- (_dialogue_box_size.x / 2)
			+ (name_box_texture.get_width() / 2)
			+ (8 * _scale_factor)
		),
		(
			_dialogue_box.position.y
			- (_dialogue_box_size.y / 2)
			- ((name_box_texture.get_height() - 1) / 2)
		)
	)

	# _finished_effect.position = Vector2(
	# 	_dialogue_box.position.x + _dialogue_box_size.x / 2 - _offset.x,
	# 	_dialogue_box.position.y + _dialogue_box_size.y / 2 - _offset.y
	# )

	_finished_effect.position = Vector2(
		_dialogue_box.position.x + _dialogue_box_size.x / 2 - _offset.x,
		_dialogue_box.position.y + _dialogue_box_size.y / 2 - _offset.y / 2
	)


func _process(_delta):
	if _page < 0 or _page >= _conversation.size():
		if _interact_key_pressed:
			_handle_exit(0.2)
		return

	# We check the type of dialogue to see if it is 1) "normal" or 2) a player choice dialogue.
	if _conversation[_page].get_type() == Types.DialogType.NORMAL:
		if _interact_key_pressed:
			if _char_count < _str_len:
				# If we haven't "typed out" all the letters, immediately "type out" all letters
				# (works as a "skip").
				_char_count = _text_ne.length()
			elif _page + 1 < _conversation.size():
				# Only increase page IF page + 1,is less than the total number of entries.
				# event_perform(ev_other, ev_user0)
				match _next_line[_page][0]:
					-1:
						_handle_exit(0.2)
						return
					0:
						_set_portrait()
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

			# 	# Change Choice
			var change_choice = _down_key_pressed - _up_key_pressed
			if change_choice != 0:
				_choice += change_choice
				# TODO(feserr): Play the choice sound.

			if _choice < 0:
				_choice = _conversation[_page].get_text().length - 1
			elif _choice > _conversation[_page].get_text().length - 1:
				_choice = 0

	_interact_key_pressed = false

	update()


func _draw():
	if _page < 0 or _page >= _conversation.size():
		return

	var name_str = _conversation[_page].get_name()
	if !name_str.empty():
		# Draw name text
		draw_string(_default_font, _name_box_text_pos, name_str, _default_col)

	_animation_cnt += 1
	if (
		_char_count >= _text_ne.length()
		and _portrait_frame.playing
		and _animation_cnt >= _animation_trigger
	):
		_portrait_frame.play()

	if _char_count < _str_len and !_pause:
		# Get current character
		var letter = _text_ne[floor(_char_count)]

		#region Check for Pause, Voice, Animated Sprite
		match letter:
			" ":
				var nothing = 1
			",", ".":
				_handle_pause(0.1)
			"?", "!":
				_handle_pause(0.2)
			_:
				# Play the voice sound every 2 frames (you can change this number if this is too often)
				var audio_increment: int = 2

				# Animated Sprite
				if true:  # TODO(feser): change to check if there is portrait.
					if !_pause:
						# To include the consideration of vowels.
						var l = letter.to_lower()
						if l == "a" or l == "e" or l == "i" or l == "o" or l == "u":
							_portrait_frame.animation = "Talk"
							_portrait_frame.play()
							if _char_count > _audio_cnt:
								_audio_player.stream = _voice_snd_effect
								_audio_player.play()
								_audio_cnt = _char_count + audio_increment

				# elif char_count >= audio_cnt:
				# 	audio_play_sound(voice[_page], 1, false)
				# 	audio_cnt = char_count + audio_increment

		if _char_count < _text_ne.length():
			_char_count += _text_speed

	# Color col = _default_col
	var cc: int = 0
	var xx: float = _dialogue_box.position.x / 2 + _offset.x
	var yy: float = _dialogue_box.position.y - (_dialogue_box_size.y / 2) + _offset.y
	var cx: int = 0
	var cy: int = 0
	# int ty = 0
	var by: int = 0
	var bp_len: int = -1
	var next_space: int = 0
	# var effects_cnt: int = 0
	# int text_col_cnt: int = 0

	var effect: int = 0
	var it_effect: int = 0
	var effects: Array = _conversation[_page].get_effects()

	var colour: Color = Color.white
	var it_colours: int = 0
	var colours: Array = _conversation[_page].get_colours()

	_effect_cnt += 1

	# Check if there are breakpoints in this string, if there are save their lengths.
	if _breakpoints.size() != 0:
		bp_len = _breakpoints.size()
		next_space = _breakpoints[by]
		by += 1

	var char_cnt: int = 0
	while char_cnt < _char_count:
		# Get current effect.
		if it_effect < effects.size() and char_cnt >= effects[it_effect].position:
			effect = effects[it_effect].effect
			it_effect += 1

		# Get current colour.
		if it_colours < colours.size() and char_cnt >= colours[it_colours].position:
			colour = colours[it_colours].colour
			it_colours += 1

		# Get current letter.
		_letter = _text_ne[cc]

		# Get next space, deal with new lines.
		if bp_len != -1 and cc == next_space:
			cy += 1
			cx = 0
			if by < bp_len:
				next_space = _breakpoints[by]
				by += 1

		# Set the position for drawing.
		var draw_vector: Vector2 = Vector2.ZERO
		draw_vector.x = xx + (cx * _char_size.x)
		draw_vector.y = yy + (cy * _char_size.y)
		var draw_colour = colour
		var effect_vector = Vector2.ONE

		var rotation: float = 0

		match effect:
			1:  # Shake
				draw_vector.x += rand_range(-1.0, 1.0)
				draw_vector.y += rand_range(-1.0, 1.0)
			2:  # Wave
				var shift: float = sin(_effect_cnt * PI * _freq / _target_fps) * _amplitude
				draw_vector.y += shift
			3:  # Colour shift
				var color_value: float = _effect_cnt / 255
				var color_normalized: float = color_value - floor(color_value)
				draw_colour = Color.from_hsv(color_normalized, 1, 1)
			4:  # Wave and colour shift
				var shift: float = sin(_effect_cnt * PI * _freq / _target_fps) * _amplitude
				draw_vector.y += shift
				var color_value: float = _effect_cnt / 255
				var color_normalized: float = color_value - floor(color_value)
				draw_colour = Color.from_hsv(color_normalized, 1, 1)
			5:  # Spin
				var val: float = _effect_cnt + cc
				var shift: float = sin(val * PI * _freq / _target_fps)
				rotation = shift / 4
			6:  # Pulse
				var val: float = _effect_cnt + cc
				var shift: float = 0.5 * (1 + sin(val * PI * _freq / _target_fps))
				effect_vector.x = shift
				effect_vector.y = shift
			7:  # Flicker
				var val: float = _effect_cnt + cc
				var shift: float = sin(val * PI * _freq / _target_fps) + rand_range(-1.0, 1.0)
				draw_colour.a = shift

		draw_set_transform(draw_vector, rotation, effect_vector)
		draw_string(_default_font, Vector2.ZERO, _letter, draw_colour)

		cc += 1
		cx += 1

		char_cnt += 1

	# Draw "Finished" effect
	if _char_count >= _str_len:
		var shift: float = sin((_effect_cnt + cc) * PI * _freq / _target_fps) * 0.1
		_finished_cnt += _finished_spd
		if _finished_cnt >= _finished_num:
			_finished_cnt = 0

		_finished_effect.position.y = _finished_effect.position.y + shift
		_finished_effect.show()

		# draw_sprite(finished_effect, _finishedeCount, finishede_x + shift, finishede_y)
	else:
		_finished_effect.hide()


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


func _on_portrait_animation_finish():
	_portrait_frame.stop()
	_portrait_frame.animation = "Idle"
	_animation_cnt = 0
	_animation_trigger = (
		randi() % _animation_trigger_range.y as int
		+ _animation_trigger_range.x as int
	)


func _setup() -> void:
	if _page < 0 or _page >= _conversation.size():
		return

	# Must be done AFTER the handover occurs, so frame after created, and after every text page change.

	# Reset variables
	_char_count = 0
	_finished_cnt = 0
	_text_speed = 0.25
	# _text_speed_c = 0
	_audio_cnt = 0
	# charCount_f = 0
	# effects_p = effects[page]
	# text_col_p = text_col[page]

	# text_speed_al = array_length_non_excp(text_speed[page]) / 2
	# effects_al = array_length_non_excp(effects[page]) / 2
	# text_col_al = array_length_non_excp(text_col[page]) / 2

	if _conversation[_page].get_portrait() == null:
		_dialogue_box.position.x = _gui_diff
		_finished_effect.position.x = (
			_dialogue_box.position.x
			+ _dialogue_box_size.x / 2
			- _offset.x
		)
	else:
		_dialogue_box.position.x = _gui_diff + _portrait_size.x
		_finished_effect.position.x = (
			_dialogue_box.position.x
			+ _dialogue_box_size.x / 2
			- _offset.x
		)

	var name_str = _conversation[_page].get_name()
	_name_box.visible = !name_str.empty()
	if _name_box.visible:
		_name_box_text_pos = _name_box.position - _default_font.get_string_size(name_str) / 2
		_name_box_text_pos.y += _default_font.get_ascent()

	# draw_set_font(font[page])
	_char_size = _default_font.get_string_size("M")  # Gets new charSize under current font.

	# GET THE BREAKPOINTS AND TEXT EFFECTS
	# Again only need to do this if our CURRENT page is "normal". Separated from above for readability.
	if _conversation[_page].get_type() == 0:
		_text_ne = _conversation[_page].get_text()
		_str_len = _text_ne.length()

		# Get variables ready
		var by = 0
		var cc = 1
		var breakpnt = 0
		var next_space = 0
		var txtwidth = _dialogue_box_size.x - (2 * _offset.x)

		# Reset the text effects and breakpoints arrays
		# text_effects = -1
		_breakpoints = {}

		# Loop through and save the effect positions and breakpoints
		var it_str_len = _str_len
		while it_str_len > 0:
			# Get next space, deal with new lines
			if cc >= next_space:
				next_space = cc
				while next_space < _str_len && _text_ne[next_space] != " ":
					next_space += 1
				var linewidth = (next_space - breakpnt) * _char_size.x
				if linewidth >= txtwidth:
					breakpnt = cc
					_breakpoints[by] = cc
					by += 1

			cc += 1
			it_str_len -= 1

	_set_portrait()


func _set_portrait() -> void:
	var portrait: Portrait = _conversation[_page].get_portrait()

	if portrait == null:
		return

	_portrait_frame.frames = load(portrait.get_portrait_path())
	_portrait_frame.animation = "Idle"
	_animation_trigger = portrait.get_animation_trigger()
	_animation_trigger_range = portrait.get_animation_trigger_range()


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
	yield(get_tree().create_timer(time), "timeout")
	_pause = false


func _handle_exit(time: float) -> void:
	if _exiting:
		return

	_exiting = true
	yield(get_tree().create_timer(time), "timeout")
	queue_free()
