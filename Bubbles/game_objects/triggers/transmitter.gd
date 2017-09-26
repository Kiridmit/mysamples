
extends Node2D

var name
export (String) var triggers
export (bool) var enabled = true
var trigger_array

func _enter_scene():
	name = get_name()
	var n = name.find(" ")
	if n != -1:
		name = name.left( n )
	trigger_array = triggers.split(",")
	Globals.triggers.push_back( self )

func run():
	if not enabled:
		return
	print("run trigger: ", name)
	for trigger_name in trigger_array:
		for trigger in Globals.triggers:
			if trigger.name == trigger_name:
				trigger.run()

func _exit_scene():
	Globals.triggers.remove( Globals.triggers.find( self ) )
