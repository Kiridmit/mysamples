# Подцепляется к шарам
extends "emitter.gd"

func _enter_scene():
	get_parent().connect("delete", self, "delete")
	
	
func delete( ):
	.run()