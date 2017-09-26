var loop
var root
var scene
var triggers = []
var player
var camera
var interface

func _init():
	loop = OS.get_main_loop()
	root = loop.get_root()
	scene = root.get_child( root.get_child_count() -1 )
	start_load()
	

#########################################
########## Загрузка / Сохрание ##########
#########################################

# Загрузка данных в начале
func start_load():
	load_game()
	
# Сменить сцену
func goto_scene(new_scene):
	var s = ResourceLoader.load(new_scene)
	scene.set_name("null")
	scene.queue_free()
	scene = s.instance()
	root.add_child(scene)
	#print(current_scene.get_name())

# Перезагрузить сцену
func reload_scene():
	goto_scene(scene.get_filename())

# Выйти из игры
func quit():
	loop.quit()

#########################################
########## Загрузка / Сохрание ##########
######################################### 

var save_arr = {}
var level_requires = { "res://Levels/Hard/Lvl_01.scn": [], "res://Levels/Hard/Lvl_02.scn": ["res://Levels/Hard/Lvl_02.scn"] }


# Проверка, открыт ли уровень
func level_opened( path ):
	if level_requires.has(path):
		var rec_levels = level_requires[path]
		for rec_lvl in rec_levels:
			var lvl = get_level(rec_lvl)
			if lvl["wins"] == 0:
				return false
		return true
	return false

# При проигрыше игрока сохраняем ещё один проигрыш
func player_lost():
	var level = get_level()
	level["losts"] += 1
	save_game()
	scene.get_node("Interface/Loose_menu").activate()
	
# При выигрыше игрока сохраняем ещё один выигрыше
func player_won():
	var level = get_level()
	level["wins"] += 1
	save_game()
	scene.get_node("Interface/Win_menu").activate()

# Загружает данные по прохождению уровня.
# Если путь не указан, возвращает текущий загруженный уровень.
# Если по указанному пути нет сохранения, создаёт новое, нулевое.
func get_level( path = null ):
	var uid
	if path == null:
		uid = scene.get_filename()
	else:
		uid = path
	var level
	if save_arr.has(uid):
		level = save_arr[uid]
	else:
		level = { wins = 0, losts = 0 }
		save_arr[uid] = level
	return level

# Сохраняет массив
func save_game():
	var f = File.new()
	#var err = f.open("C:/dev/godot/Trying/Bubbles/Files/file.txt", File.WRITE)
	var err = f.open("user://file.txt", File.WRITE)	
	if err == 0:
		f.store_var(save_arr)
	f.close()

# Загружает массив
func load_game():
	var f = File.new()
	#var err = f.open("C:/dev/godot/Trying/Bubbles/Files/file.txt", File.READ)
	var err = f.open("user://file.txt", File.READ)
	if err == 0:
		save_arr = f.get_var()
	f.close()


