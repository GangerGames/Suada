extends Sprite2D

var _cnt: int = 0


func _ready():
	visible = false


func _process(_delta):
	if visible:
		_cnt += 1
		var shift: float = sin(_cnt * PI * SuadaGlobals.FREQUENCY / SuadaGlobals.TARGET_FPS) * 0.1

		position.y += shift
