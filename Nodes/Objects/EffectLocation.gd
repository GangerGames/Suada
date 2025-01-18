## Effect location class.
##
## Holds the position and effect.
class_name EffectLocation
extends Resource

var effect: BBCCodes.BBC_EFFECT = BBCCodes.BBC_EFFECT.NONE
var value: String


func _init(ef: BBCCodes.BBC_EFFECT, val: String):
	effect = ef
	value = val
