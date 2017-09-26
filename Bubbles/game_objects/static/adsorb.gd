extends RigidBody2D

var type = "adsorb_wall"
#var player

func _integrate_forces( state ):
	var contact_count = state.get_contact_count()
	for i in range( contact_count ):
		var collider = state.get_contact_collider_object( i )
		#новый радиус
		var r2 = ( state.get_contact_local_pos( i ) - collider.get_pos() ).length()
		#а вот столько придётся вычесть, при полном проникновении чуть больше, но так и нужно для полного уничтожения
		var dm = abs( collider.mass - r2 * r2 * PI * collider.DENCITY )
		#print(collider.mass, ", ", dm, ", ", r2, ", ", collider.radius - r2 )
		collider.add_mass( -dm )