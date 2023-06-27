extends AnimatedSprite2D

class_name PortraitFrame


## Portrait states.
const PORTRAIT_STATES: Dictionary = {
	"idle": 0,  ## Idle.
	"talk": 1,  ## Talking.
}

## Portrait animations names
const PORTRAIT_ANIM_NAMES: Dictionary = {
	"idle": "idle",  ## Idle.
	"talk": "talk",  ## Talk
}

var _state: int = PORTRAIT_STATES.idle

var _animation_cnt: float = -1
var _animation_trigger: int = -1
var _animation_trigger_range: Vector2 = Vector2(1, 1)


func _ready():
	connect("animation_finished", Callable(self, "_on_portrait_animation_finish"))


func _process(delta):
	_animation_cnt += 1 * delta
	if _state == PORTRAIT_STATES.idle and is_playing() and _animation_cnt >= _animation_trigger:
		play()


func setup(portrait: SpriteFrames, animation_trigger: int, anim_trigger_range: Vector2) -> void:
	set_portrait_sprite(portrait)
	_animation_trigger = animation_trigger
	_animation_trigger_range = anim_trigger_range


func set_portrait_sprite(portrait: SpriteFrames) -> void:
	sprite_frames = portrait
	animation = PORTRAIT_ANIM_NAMES.idle
	_state = PORTRAIT_STATES.idle


func play_animation(animation_str: String) -> void:
	if animation_str in PORTRAIT_ANIM_NAMES and animation_str in PORTRAIT_STATES:
		stop()
		animation = PORTRAIT_ANIM_NAMES[animation_str]
		_state = PORTRAIT_STATES[animation]
		play()
	else:
		printerr("Wrong animation name.")


func _on_portrait_animation_finish() -> void:
	stop()
	animation = PORTRAIT_ANIM_NAMES.idle
	_state = PORTRAIT_STATES.idle
	_animation_cnt = 0
	_animation_trigger = (
		randi() % (_animation_trigger_range.y as int)
		+ _animation_trigger_range.x as int
	)
