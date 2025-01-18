## The Dialog class
##
## @desc:
##     An object to hold dialog data.
class_name Dialog
extends Resource

var id: int = -1
var text: String = ""
var name: String = ""
var portrait: Portrait = null
var type: int = Types.DialogType.NORMAL
var choices: Array[Choice] = []
var next: int = -1


## Initialise the dialog object.
func _init(
	id: int,
	text: String,
	name: String,
	portrait_path: String,
	type: int,
	next = -1,
	choices: Array[Choice] = []
):
	self.id = id
	self.text = text
	self.name = name

	if !portrait_path.is_empty():
		portrait = Portrait.new(portrait_path)

	self.type = type
	self.next = next
	self.choices = choices
