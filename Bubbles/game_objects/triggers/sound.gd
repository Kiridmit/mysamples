
extends "receiver.gd"

func run():
	if not enabled:
		return
	get_node( "SamplePlayer2D" ).play( "die1" )
