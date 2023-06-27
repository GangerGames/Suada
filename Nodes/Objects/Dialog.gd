## The Dialog class
##
## @desc:
##     An object to hold dialog data.
class_name Dialog

const Types = preload("res://addons/Suada/Nodes/Objects/Types.gd")

var text: String = "":
	get:
		return text

var name: String = "":
	get:
		return name

var portrait: Portrait = null:
	get:
		return portrait

var type: int = Types.DialogType.NORMAL:
	get:
		return type


## Initialise the dialog object.
func _init(text: String, name: String, portrait_path: String, type: int):
	self.text = text
	self.name = name

	if !portrait_path.is_empty():
		portrait = Portrait.new(portrait_path)

	self.type = type
