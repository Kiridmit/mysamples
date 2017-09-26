
extends Node2D

#export (bool) var camera_follow_player = false

func _fixed_process(delta):
	if Globals.player == null or Globals.camera == null:
		#set_pos( Vector2( Globals.camera.map_x * 0.5, Globals.camera.map_y * 0.5 ) )
		set_scale( Vector2( 1, 1 ) )
		return
	if Globals.camera.follow_player:
		set_pos( Globals.camera.get_pos() )
		set_scale( Vector2( Globals.camera.zoom, Globals.camera.zoom ) )
	#else:
	#	set_pos( Vector2( Globals.camera.map_x * 0, Globals.camera.map_y * 0 ) )
	
func _ready():
	if Globals.player == null:
		print("Interface: player not found")
	Globals.interface = self
	#print( Globals.camera.get_name() )
	set_fixed_process(true)

#func _exit_scene():
#	Globals.interface = null
