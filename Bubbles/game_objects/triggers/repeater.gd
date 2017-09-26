
extends "transmitter.gd"


export ( float ) var delay = 1
var timer = 0

func run():
	set_fixed_process( not is_fixed_processing() )
	timer = 0

func _fixed_process( delta ):
	if not enabled:
		return
	timer += delta
	if timer >= delay:
		timer -= delay
		.run()
		
	