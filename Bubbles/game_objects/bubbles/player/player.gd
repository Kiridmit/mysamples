
extends "res://game_objects/bubbles/simple/bubble.gd"

var bubble = preload( "res://game_objects/bubbles/simple/bubble.scn" )
var MAX_SHOOTING_TIME = 20
var shooting_time = 0
var Ctrl_time = 0
var win_mass = 0
#var camera_follow_player
var stopped = false
#var viewport_rect

func _fixed_process( delta ):

	# Зажатие Ctrl
	var Ctrl_pressed = Input.is_action_pressed("Ctrl")
	if Ctrl_pressed:
		Ctrl_time += delta
	#	print(Ctrl_time)
	elif Ctrl_time != 0:
		Ctrl_time = 0
	
	# Остановка игрока (чисто для теста)
	var space_pressed = Input.is_action_pressed("Space")
	if space_pressed and not stopped:
		stopped = true
		velocity = Vector2( 0, 0 )
		set_linear_velocity( velocity ) 
		print( "player stopped" )
	if velocity != Vector2( 0, 0 ):
		stopped = false
	var viewport_rect = get_scene().get_root().get_rect()
	
	# Управление мышкой
	var shoot = Input.is_mouse_button_pressed( 1 )
	if shoot and shooting_time % MAX_SHOOTING_TIME == 0:
		var mouse_pos = Input.get_mouse_pos()
		#print(Globals.interface.get_pos())
		#if Globals.camera.follow_player:
		mouse_pos +=  Globals.camera.get_pos() - viewport_rect.size * 0.5
		#else:
		#	mouse_pos += Vector2( 400, 300 ) - viewport_rect.size * 0.5
		#var object_pos = get_pos()
		#print( "mouse ", mouse_pos, "; player ", object_pos )
		var shoot_vector = ( mouse_pos - get_pos() ).normalized()
		
		# Создание нового шарика
		var new_bubble = bubble.instance()
		var new_bubble_vel = shoot_vector * 300 + velocity
		var new_bubble_mass = mass * ( Ctrl_time * 0.1 + 0.01 )
		var new_bubble_pos = shoot_vector * ( radius * 0.9 ) + get_pos() 
		new_bubble.creator = self
		new_bubble.in_creator = true
		new_bubble.set_params( new_bubble_pos, new_bubble_vel, new_bubble_mass )
		
		# Изменение параметров игрока
		add_mass( - new_bubble_mass, new_bubble_vel )
		get_parent().add_child( new_bubble )
		
		# Поместиться на передний план
		raise()
	elif not shoot:
		shooting_time = 0
	if shoot:
		shooting_time += 1
		#print( shooting_time )

func _enter_scene():
	type = "player"
	Globals.player = self
	if velocity == Vector2( 0, 0 ):
		stopped == true

#func _ready():
	#viewport_rect = get_scene().get_root().get_rect()

#func _exit_scene():
#	Globals.player = null
