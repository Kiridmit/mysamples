
extends Node2D

export (String) var triggers
export (bool) var enabled = true
var trigger_array

func _enter_scene():
	#if triggers == null:
		#print( get_name(), ": string Triggers is empty" )
		#return
	trigger_array = triggers.split(",")

func run():
	if not enabled:
		return
	for trigger_name in trigger_array:
		for trigger in Globals.triggers:
			if trigger.name == trigger_name:
				trigger.run()
