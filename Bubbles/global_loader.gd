extends Node

func _enter_scene():
	Globals.set_script(preload("res://global.gd"))
	Globals._init()
	queue_free()