## The Choice class
##
## @desc:
##     An object to hold choice data.
class_name Choice
extends Resource

var text: String = ""
var next: int = -1


## Initialise the dialog object.
func _init(text: String, next: int = -1):
	self.text = text
	self.next = next
