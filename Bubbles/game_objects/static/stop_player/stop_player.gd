
extends Node2D

var type = "stop_player"
export (String) var track_bubble = "Player"
export (float) var timer_0 = 5
var timer = timer_0
#var shape_1 = 
#var shape_2 =
#var shape_3 =

func _enter_scene():
	track_bubble = Globals.scene.get_node( "Bubbles").get_node( track_bubble )
	connect("body_enter_shape", track_bubble, "on_body_enter_shape")
#	set_fixed_process( true )

func on_body_enter_shape( body_id, body, body_shape, local_shape ):
	print( body_id, " ",  body.get_name(), " ",  body_shape, " ",  local_shape )

func _integrate_forces( state ):
	var contact_count = state.get_contact_count()
	for i in range( contact_count ):
		var collider = state.get_contact_collider_object( i )
		if collider == track_bubble:
			#var shape_number = collider.get_contact_collider_shape( i )
			#print( "shape_number: ", shape_number )
			pass

#func _fixed_process( delta ):
#	if timer <= 0:
#		Globals.player_won()
#		set_fixed_process( false )
#		return
#	if shape_1_colliding:
#		if not shape_2_colliding:
#			timer -= delta
#		else:
#			timer = timer_0
