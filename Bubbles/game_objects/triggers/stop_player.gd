
extends "emitter.gd"
# Скрипт для триггера, который запускает таймер как только игрок полностью входит в область. По истечении таймера, триггер срабатывает

var type = "stop_player"
export (String) var track_bubble = "Player"
export (float) var timer_0 = 5
var timer = timer_0
var body_1_colliding = false
var body_2_colliding = false
var label

func _enter_scene():
	label = Globals.scene.get_node( "Interface" ).get_node( "Timer" )
	track_bubble = Globals.scene.get_node( "Bubbles" ).get_node( track_bubble )
	set_fixed_process( true )

func _fixed_process( delta ):
	if not enabled:
		return
	if timer <= 0:
		.run()
		label.hide()
		set_fixed_process( false )
		return
	if body_1_colliding:
		if not body_2_colliding:
			timer -= delta
			label.set_text( str( timer ) )
			label.show()
		else:
			label.hide()
			timer = timer_0
