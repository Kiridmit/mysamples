
extends Node2D

var name
export (bool) var enabled = true

func _enter_scene():
	name = get_name()
	Globals.triggers.push_back( self )

func run():
	if not enabled:
		return

func _exit_scene():
	Globals.triggers.remove( Globals.triggers.find( self ) )
