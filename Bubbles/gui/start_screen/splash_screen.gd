
extends Node

func _on_next_pressed():
	get_node("/root/scene_loader").goto_scene("res://GUI/Main menu/main_menu.scn")
	#print( get_node("/root/scene_loader") )


