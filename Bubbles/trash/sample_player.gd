
extends SamplePlayer2D


func _enter_scene():
	set_fixed_process( true )

func _fixed_process( delta ):
	play("die1")
