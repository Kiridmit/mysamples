
extends Node

var loading_level = null

func _enter_scene():
	get_node("/root/scene_loader").goto_scene(loading_level)

