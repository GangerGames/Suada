## The Portrait class.
##
## @desc:
##     An object to hold portrait data.
##
class_name Portrait

var _portrait_path: String = "" setget , get_portrait_path
var _animation_trigger: int = 120 setget , get_animation_trigger
var _animation_trigger_range: Vector2 = Vector2(100, 200) setget , get_animation_trigger_range


func _init(portrait_path: String, animation_trigger: int = 100, animation_trigger_range: Vector2 = Vector2(100, 200)):
	_portrait_path = portrait_path
	_animation_trigger = animation_trigger
	_animation_trigger_range = animation_trigger_range


func get_portrait_path() -> String:
	return _portrait_path


func get_animation_trigger() -> int:
	return _animation_trigger


func get_animation_trigger_range() -> Vector2:
	return _animation_trigger_range
