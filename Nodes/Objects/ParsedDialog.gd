## Parse return class.
##
## Holds the parsed text data.
class_name ParsedDialog
extends Resource

var orig_text: String = ""
var text: String = ""
var effects: Dictionary[int, EffectLocation] = {}

var text_len: int:
	get:
		return text.length()

var effects_len: int:
	get:
		return effects.size()


func _init(text: String):
	orig_text = text
