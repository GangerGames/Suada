extends RichTextLabel

class_name NameTextBox


var character_name: String = "Name":
	get:
		return character_name


func _ready():
	update()


func update():
	text = "[center]" + character_name + "[/center]"


func change_name(character_name: String):
	self.character_name = character_name
	update()
