@tool
class_name RichTextEffectShift
extends RichTextEffect

# Syntax: [shift freq=5.0 span=10.0][/shift]

# Define the tag name.
var bbcode = "shift"


func _process_custom_fx(char_fx):
	# Get parameters, or use the provided default value if missing.
	var speed = char_fx.env.get("freq", 5.0)

	var color_value: float = char_fx.elapsed_time * speed / 255
	var color_normalized: float = color_value - floor(color_value)
	char_fx.color = Color.from_hsv(color_normalized, 1, 1)

	return true
