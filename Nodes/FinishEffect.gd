extends Sprite2D


const _TRIGGER: float = 2
const _MAX_SPEED: float = 15.0 / SuadaGlobals.TARGET_FPS

var _cnt : int = 0
var _spd: float = 0


func _ready():
	visible = false
	pass # Replace with function body.


func _process(delta):
	if visible:
		_cnt += 1
		var shift: float = sin((_cnt) * PI * SuadaGlobals.FREQUENCY / SuadaGlobals.TARGET_FPS) * 0.1
		
		_spd += _MAX_SPEED
		if _spd >= _TRIGGER:
			_spd = 0

		position.y += shift
