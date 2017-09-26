
extends RigidBody2D
#Вспомогательный скрипт для отслеживания столкновения с внешней частью шейпа

var type = "stop_player"
var track_bubble


func _enter_scene():
	track_bubble = get_parent().track_bubble

func _integrate_forces( state ):
	var contact_count = state.get_contact_count()
	if contact_count == 0:
		get_parent().body_2_colliding = false
		return
	for i in range( contact_count ):
		var collider = state.get_contact_collider_object( i )
		if collider == track_bubble:
			#print("shape1 collided with target")
			get_parent().body_2_colliding = true
