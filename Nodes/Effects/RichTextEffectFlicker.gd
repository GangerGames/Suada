@tool
extends RichTextEffect
class_name RichTextEffectFlicker

# Syntax: [flicker freq=5.0 span=10.0][/flicker]

# Define the tag name.
var bbcode = "flicker"

func _process_custom_fx(char_fx):
	# Get parameters, or use the provided default value if missing.
	var speed = char_fx.env.get("freq", 5.0)
	
	var val: float = char_fx.elapsed_time * 100
	var shift: float = sin(val * PI * speed / SuadaGlobals.TARGET_FPS) + randf_range(-1.0, 1.0)
	char_fx.color.a = shift

	return true
