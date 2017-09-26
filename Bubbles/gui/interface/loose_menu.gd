
extends Node2D

func _ready():
	var player = Globals.scene.get_node( "Bubbles/Player" )



func activate():
	show()
	Globals.loop.set_pause(true)


# Те же функции, что и в game menu и в win menu
func _on_Go_to_menu_pressed():
	hide()
	Globals.goto_scene("res://gui/main_menu/main_menu.scn")
	Globals.loop.set_pause(false)


func _on_Restart_pressed():
	hide()
	Globals.loop.set_pause(false)
	Globals.reload_scene()

