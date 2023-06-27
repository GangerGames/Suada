## The Portrait class.
##
## @desc:
##     An object to hold portrait data.
##     The trigger values is meant to be use for idle animation, like eye blink
##     so it triggers the animation in a random time number between the range.
##
class_name Portrait

var portrait_path: String = "":
	get:
		return portrait_path

var animation_trigger: int = 120:
	get:
		return animation_trigger

var animation_trigger_range: Vector2 = Vector2(100, 200):
	get:
		return animation_trigger_range


func _init(
	portrait_path: String,
	animation_trigger: int = 100,
	animation_trigger_range: Vector2 = Vector2(100, 200)
):
	self.portrait_path = portrait_path
	self.animation_trigger = animation_trigger
	self.animation_trigger_range = animation_trigger_range
