extends "res://game_objects/bubbles/simple/bubble.gd"

var G = 0.5 # Гравитационная постоянная

func _fixed_process( delta ):
	# Притягивание всех шариков, кроме себя
	for another_object in parent.get_children():
		if another_object != self:
			var vector = get_pos() - another_object.get_pos()
			another_object.velocity += G * vector.normalized() * mass / ( vector.length() * vector.length() )
			
func _ready():
	set_fixed_process( true )
