extends Control

const OFFSET: int = 10

var _text_diff: int = -1

@onready var _name_box_panel: Panel = $NameBoxPanel
@onready var _name_box_text: RichTextLabel = $NameTextBox


func _ready():
	_text_diff = (_name_box_panel.size.x - ceil(_name_box_text.size.x * _name_box_text.scale.x))


func _resize_box(width: int) -> void:
	var new_width = width + OFFSET

	_name_box_panel.rect_size.x = new_width
	_name_box_text.rect_size.x = ceil((new_width - _text_diff) / _name_box_text.rect_scale.x)


func set_name_label(name: String, font: Font) -> void:
	var name_width = font.get_string_size(name).x

	if name_width > _name_box_text.rect_size.x:
		_resize_box(name_width)

	_name_box_text.bbcode_text = "[center]" + name + "[/center]"
