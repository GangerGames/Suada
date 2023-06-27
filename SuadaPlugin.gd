@tool

extends EditorPlugin


const AUTOLOAD_NAME = "SuadaGlobals"


func _enter_tree():
	add_autoload_singleton(AUTOLOAD_NAME, "res://addons/Suada/Nodes/SuadaGlobals.gd")


func _exit_tree():
	remove_autoload_singleton(AUTOLOAD_NAME)
