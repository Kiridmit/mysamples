# Подцепляется к шарам
extends "emitter.gd"

export ( float ) var value
export ( String, "lower", "greater" ) var mode

func _enter_scene():
	get_parent().connect("change_mass", self, "change_mass")
	
	
func change_mass( old_mass, new_mass ):
	if mode == "lower":
		if new_mass < value and old_mass >= value:
			.run()
	else:
		if new_mass > value and old_mass <= value:
			.run()