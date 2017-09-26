
extends Camera2D

var temp_zoom = null
var zoom = null
var player_radius = null
var map_x = 800
var map_y = 600
var map_limit
var camera_limit
export (bool) var follow_player = true
var zoom_min = 5
var zoom_max = 1.5

func _fixed_process(delta):
	if follow_player == false:
		return
	var new_player_radius = Globals.player.radius
	var zoomed_up = Input.is_action_pressed("ui_up")
	var zoomed_down = Input.is_action_pressed("ui_down")
	#var zoomed_up = Input.is_action_pressed("Zoom_Up")
	#var zoomed_down = Input.is_action_pressed("Zoom_Down")
	# Самостоятельное изменение зума в момент изменения радиуса игрока
	if new_player_radius > player_radius:
		temp_zoom *= new_player_radius / player_radius
	if new_player_radius < player_radius:
		temp_zoom /= player_radius / new_player_radius
	player_radius = new_player_radius
	# Плавное изменение зума
	zoom = ( temp_zoom + get_zoom().x * 97 ) * 0.01
	var camera_rect = get_scene().get_root().get_rect()
	# Ограничение зума снизу. Понятия не имею, как это работает
	if camera_rect.size.x < zoom_min * Globals.player.radius / zoom:
		temp_zoom = zoom_min * PI * Globals.player.radius / camera_rect.size.x
	if camera_rect.size.y < zoom_min * Globals.player.radius / zoom:
		temp_zoom = zoom_min * PI * Globals.player.radius / camera_rect.size.y
	# Ещё один образец чернейшей магии для оценки ограничения зума сверху
	if camera_rect.size.x >= camera_rect.size.y:
		map_limit = map_y * zoom_max
		camera_limit = camera_rect.size.y
	else:# camera_rect.size.x < camera_rect.size.y:
		map_limit = map_x * zoom_max
		camera_limit = camera_rect.size.x
	# Ограничение зума сверху
	if map_limit / zoom < camera_limit:
		zoom = map_limit / camera_limit
		temp_zoom /= 1.1
	elif zoomed_up:
		temp_zoom /= 1.1
	elif zoomed_down:
		temp_zoom *= 1.1
	# Применение зума и позиции камеры
	set_zoom( Vector2( zoom, zoom ) )
	set_pos( Globals.player.get_pos() )
	#print( get_pos() )

func _enter_scene():
	Globals.camera = self
	print(Globals.camera.get_name())

func _ready():
	if Globals.player != null:
		player_radius = Globals.player.radius
		temp_zoom = Globals.player.radius * 0.05
		zoom = 1
	set_fixed_process( true )

#func _exit_scene():
#	Globals.camera = null
