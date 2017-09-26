
extends Node2D

var name
export (bool) var enabled = true

func _enter_scene():
	name = get_name()
	var n = name.find(" ")
	if n != -1:
		name = name.left( n )
	Globals.triggers.push_back( self )

func _exit_scene():
	Globals.triggers.remove( Globals.triggers.find( self ) )
