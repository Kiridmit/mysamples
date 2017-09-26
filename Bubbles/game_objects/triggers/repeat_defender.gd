
extends "transmitter.gd"


export ( float ) var delay = 5
var timer = 0

func run():
	if not is_fixed_processing():
		.run()
		if enabled:
			set_fixed_process( true )

func _fixed_process( delta ):
	if not enabled:
		return
	timer += delta
	if timer >= delay:
		timer = 0
		set_fixed_process( false )