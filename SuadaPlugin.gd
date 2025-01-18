@tool
extends EditorPlugin


func _enter_tree():
	add_autoload_singleton("SuadaConfig", "res://addons/Suada/Nodes/Globals/SuadaConfig.gd")


func _exit_tree():
	remove_autoload_singleton("SuadaConfig")
