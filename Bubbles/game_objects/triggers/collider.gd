# Подцепляется к шарам
extends "emitter.gd"

export (String) var targets
var target_array

func _enter_scene():
	target_array = targets.split(",")
	get_parent().connect("collide", self, "collide")
	
func collide( name ):
	for target_name in target_array:
		if target_name == name:
			.run()