## The Dialog class
##
## @desc:
##     An object to hold dialog data.
##
class_name Dialog

const Types = preload("res://addons/Suada/Nodes/Objects/Types.gd")

var _text: String = "" setget , get_text
var _name: String = "" setget , get_name
var _portrait: Portrait = null setget , get_portrait
var _type: int = Types.DialogType.NORMAL setget , get_type
var _effects: Array = [] setget , get_effects
var _colours: Array = [] setget , get_colours


func _init(
	text: String, name: String, portrait_path: String, type: int, effects: Array, colours: Array
):
	_text = text
	_name = name

	if !portrait_path.empty():
		_portrait = Portrait.new(portrait_path)

	_type = type
	_effects = effects
	_colours = colours


func get_text() -> String:
	return _text


func get_name() -> String:
	return _name


func get_portrait() -> Portrait:
	return _portrait


func get_type() -> int:
	return _type


func get_effects() -> Array:
	return _effects


func get_colours() -> Array:
	return _colours
