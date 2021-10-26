extends Node2D

# Customise (FOR USER)
var interact_key = KEY_E
var interact_key_pressed = false
var up_key = KEY_UP  # For dialogue choices
var up_key_pressed = 0
var down_key = KEY_DOWN  # For dialogue choices
var down_key_pressed = 0

var scale_factor = 1
var x_buffer = 10 * scale_factor
var y_buffer = 18 * scale_factor

var portrait_frame
var dialogue_box
var name_box
var finished_effect
var emote_sprite

var choice_snd_effect
var select_snd_effect

export(Color) var default_col = Color.white
export(Color) var choice_col = Color.yellow
export(Color) var select_col = Color.orange
export(Color) var name_col = Color.orange

var name_font

var priority_snd_effect = 5
# You only need to change this if you are using animated sprites
# Set this to equal the frame where the mouth is OPEN for talking sprites
var open_mouth_frame = 1

# Setup (LEAVE THIS STUFF)
var portrait_talk = -1
var portrait_talk_n = -1
var portrait_talk_s = -1
var portrait_talk_c = 0

var portrait_idle = -1
var portrait_idle_n = -1
var portrait_idle_s = -1
var portrait_idle_c = 0

var emotes = -1
var speaker = null

var boxHeight
var boxWidth
var gui_width
var gui_height
var gb_diff
var portraitWidth
var finishede_num
var finishede_spd

var pos_x
var pos_y

var name_box_x
var name_box_y
var name_box_text_x
var name_box_text_y

var finishede_x
var finishede_y

var letter = 0
var charCount = 0
var charCount_f = 0
var finishede_count
var text_speed = 0
var text_speed_c = 0
var audio_c = 0
var page = 0
var str_len = -1
var pause = false
var chosen = false
var choice = 0

var creator = null
var type = 0
var text = -1
var text_NE = -1
var breakpoints = {}
var nextline = 0
var text_col = Color.white
var emotion = 0

var portrait = 1
var voice = 1
var font = 1

var charSize = 1
var stringHeight = 1

# Effect variables
var effects_p
var t = 0
var amplitude = 4
var freq = 2
var ec = 0  # Effect c


func _ready():
	dialogue_box = get_node("DialogueBox")
	portrait_frame = get_node("PortraitFrame")
	name_box = get_node("NameBox")

	var portrait_frame_texture = get_node("PortraitFrame/PortraitFrameSprite").texture as Texture
	var dialogue_box_texture = get_node("DialogueBox/DialogueBoxSprite").texture as Texture
	var name_box_texture = get_node("NameBox/NameBoxSprite").texture as Texture
	finished_effect = load("res://addons/Suada/Assets/indicator.png") as Texture

	name_font = load("res://Assets/Fonts/FixedsysExcelsior.tres")

	charSize = name_font.get_string_size("M").x

	boxWidth = dialogue_box_texture.get_width() * scale_factor
	boxHeight = dialogue_box_texture.get_height() * scale_factor

	var viewport = get_viewport().get_visible_rect()
	gui_width = viewport.size.x
	gui_height = viewport.size.y

	gb_diff = gui_width - boxWidth
	portraitWidth = (portrait_frame_texture.get_width()) * scale_factor
	finishede_num = 0
	finishede_spd = 15 / 60

	pos_x = gb_diff + portraitWidth
	pos_y = gui_height - (boxHeight / 2) - 4

	name_box_x = pos_x - (boxWidth / 2) + (name_box_texture.get_width() / 2) + (8 * scale_factor)
	name_box_y = pos_y - (boxHeight / 2) - ((name_box_texture.get_height() - 1) / 2)  # - (23 * scale_factor)
	name_box_text_x = name_box_x + ((name_box_texture.get_width() * scale_factor) / 2)
	name_box_text_y = name_box_y + y_buffer

	finishede_x = pos_x + boxWidth - x_buffer
	finishede_y = pos_y + boxHeight - y_buffer

	# Set dialogue box position
	dialogue_box.position = Vector2(pos_x, pos_y)

	# Set portrait position
	portrait_frame.position = Vector2(pos_x - (boxWidth / 2) - (portraitWidth / 2), pos_y)

	name_box.position = Vector2(name_box_x, name_box_y)

	text = ["Exactly! Thank you!"]
	type = [0]
	portrait = [0]

	setup()

	pass


func _process(delta):
	# We check the type of dialogue to see if it is 1) "normal" or 2) a player choice dialogue.
	if type[page] == 0:
		if interact_key_pressed:
			if charCount < str_len:
				# If we haven't "typed out" all the letters, immediately "type out" all letters (works as a "skip").
				charCount = text_NE.length()
			elif page + 1 < text.length:
				# Only increase page IF page + 1,is less than the total number of entries.
				# event_perform(ev_other, ev_user0)
				match nextline[page]:
					-1:
						# instance_destroy()
						return
					0:
						page += 1
					_:
						page = nextline[page]

				# event_perform(ev_alarm, 0)
			# else:
			# 	event_perform(ev_other, ev_user0)
			# 	instance_destroy()
	else:
		if chosen:
			return
		if interact_key_pressed:
			chosen = true
			# alarm[2] = 10;
			# audio_play_sound(select_snd_effect, priority_snd_effect, false)

		# Change Choice
		var change_choice = down_key_pressed - up_key_pressed
		if change_choice != 0:
			choice += change_choice
			# audio_play_sound(choice_snd_effect, priority_snd_effect, false)

		if choice < 0:
			choice = text[page].length - 1
		elif choice > text[page].length - 1:
			choice = 0

	update()

	pass


func _draw():
	if charCount < text_NE.length():
		charCount += 1

	var col = default_col
	var cc = 0
	var xx = pos_x + x_buffer
	var yy = pos_y - (boxHeight / 2) + y_buffer
	var cx = 0
	var cy = 0
	var ty = 0
	var by = 0
	var bp_len = -1
	var effect = 0
	var next_space
	var effects_c = 0
	var text_col_c = 0

	var char_cnt = 0
	while char_cnt < charCount:
		# Get current letter
		letter = text_NE.substr(cc, 1)

		# Get next space, deal with new lines
		if bp_len != -1 and cc == next_space:
			cy += 1
			cx = 0
			if by < bp_len:
				next_space = breakpoints[by]
				by += 1

		draw_string(
			name_font, Vector2(xx + (cx * charSize), yy + (cy * stringHeight)), letter, default_col
		)

		cc += 1
		cx += 1

		char_cnt += 1

	pass


func _input(event):
	if Input.is_key_pressed(interact_key):
		interact_key_pressed = true
	else:
		interact_key_pressed = false

	if Input.is_key_pressed(up_key):
		up_key_pressed = 1
	else:
		up_key_pressed = 0

	if Input.is_key_pressed(down_key):
		down_key = 1
	else:
		down_key = 0

	pass


func setup():
	# Must be done AFTER the handover occurs, so frame after created, and after every text page change.

	# Reset variables
	charCount = 0
	finishede_count = 0
	portrait_talk_c = 0
	portrait_idle_c = 0
	text_speed_c = 0
	audio_c = 0
	charCount_f = 0
	# effects_p = effects[page]
	# text_col_p = text_col[page]

	# text_speed_al = array_length_non_excp(text_speed[page]) / 2
	# effects_al = array_length_non_excp(effects[page]) / 2
	# text_col_al = array_length_non_excp(text_col[page]) / 2

	if portrait[page] == -1:
		pos_x = (gb_diff / 2)
		finishede_x = pos_x + boxWidth - x_buffer
	else:
		pos_x = (gb_diff / 2) + (portraitWidth / 2)
		finishede_x = pos_x + boxWidth - x_buffer

	# draw_set_font(font[page])
	charSize = name_font.get_string_size("M").x  # Gets new charSize under current font.
	# charHeight = name_font.get_string_size("M").x  # Same for width.

	# GET THE BREAKPOINTS AND TEXT EFFECTS
	# Again only need to do this if our CURRENT page is "normal". Separated from above for readability.
	if type[page] == 0:
		text_NE = text[page]
		str_len = text_NE.length()

		# Get variables ready
		var by = 0
		var ty = 0
		var cc = 1
		var breakpnt = 0
		var next_space = 0
		var char_at = ""
		var txtwidth = boxWidth - (2 * x_buffer)
		var char_max = txtwidth / charSize

		# Reset the text effects and breakpoints arrays
		# text_effects = -1
		breakpoints = {}

		# Loop through and save the effect positions and breakpoints
		var it_str_len = str_len
		while it_str_len > 0:
			# Get next space, deal with new lines
			if cc >= next_space:
				next_space = cc
				while next_space < str_len && text_NE[next_space] != " ":
					next_space += 1
				var linewidth = (next_space - breakpnt) * charSize
				if linewidth >= txtwidth:
					breakpnt = cc
					breakpoints[by] = cc
					by += 1

			cc += 1
			it_str_len -= 1

	pass
