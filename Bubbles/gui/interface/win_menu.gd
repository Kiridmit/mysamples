
extends Node2D

func activate():
	show()
	Globals.loop.set_pause(true)


# Те же функции, что и в game menu и в loose menu
func _on_Go_to_menu_pressed():
	hide()
	Globals.goto_scene("res://gui/main_menu/main_menu.scn")
	Globals.loop.set_pause(false)


#func _on_Next_level_pressed():
#	hide()
#	get_scene().set_pause(false)
#	get_node("/root/scene_loader").reload_scene()
	


func _on_Go_to_map_pressed():
	Globals.goto_scene("res://gui/main_menu/levels/levels.scn")
	Globals.loop.set_pause(false)
	