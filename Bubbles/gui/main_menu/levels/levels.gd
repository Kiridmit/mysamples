
extends Node



func _on_main_menu_pressed():
	Globals.goto_scene("res://gui/main_menu/main_menu.scn")

func _on_level_1_pressed():
	Globals.goto_scene("res://levels/level_1.scn")


func _on_level_2_pressed():
	Globals.goto_scene("res://levels/")
	print("not working now")
