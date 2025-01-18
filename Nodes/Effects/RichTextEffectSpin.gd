@tool
class_name RichTextEffectSpin
extends RichTextEffect

# Syntax: [spin freq=5.0 span=10.0][/spin]

# Define the tag name.
var bbcode = "spin"


func _process_custom_fx(char_fx: CharFXTransform):
	var freq = char_fx.env.get("freq", 5.0)

	var val: float = char_fx.elapsed_time * 100
	var shift: float = sin(val * PI * freq / SuadaGlobals.TARGET_FPS)
	var rotation = shift / 4
	char_fx.transform = char_fx.transform.rotated_local(rotation)

	return true
