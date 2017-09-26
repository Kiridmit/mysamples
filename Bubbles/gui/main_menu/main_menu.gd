extends Node

func _on_Levels_pressed():
	Globals.goto_scene("res://gui/main_menu/levels/levels.scn")

func _on_Quit_game_pressed():
	Globals.quit()
