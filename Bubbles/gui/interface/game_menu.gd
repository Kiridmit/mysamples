
extends Node2D

var paused = false
var esc_timer = 0

# При нажатии на клавишу Продолжить
func _on_Resume_pressed():
	paused = false
	hide()
	Globals.loop.set_pause(false)

# При нажатии на клавишу Перезагрузить уровень
func _on_Restart_pressed():
	hide()
	Globals.loop.set_pause(false)
	Globals.reload_scene()

# При нажатии на клавишу Идти в главное меню
func _on_Go_to_menu_pressed():
	hide()
	Globals.goto_scene("res://gui/main_menu/main_menu.scn")
	Globals.loop.set_pause(false)

# При нажатии на клавишу Выход из игры
func _on_Exit_game_pressed():
	hide()
	Globals.quit()


func _fixed_process(delta):
	# Всплывание и удаление меню по нажатии на Esc
	var esc_pressed = Input.is_action_pressed("Esc")
	if esc_pressed and esc_timer == 0:
		if not paused:
			paused = true
			show()
			get_scene().set_pause(true)
		else:
			paused = false
			hide()
			get_scene().set_pause(false)
		esc_timer += 1
	elif not esc_pressed and esc_timer != 0:
		esc_timer = 0
		
func _enter_scene():
	set_fixed_process(true)
	
