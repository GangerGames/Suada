## The Conversation class
##
## @desc:
##     An object to hold conversation data.
class_name Conversation
extends Resource

var dialogs: Array[Dialog] = []
var length: int = 0:
	get:
		return dialogs.size()


## Initialise the dialog object.
func _init(dialogs: Array[Dialog]):
	self.dialogs = dialogs
