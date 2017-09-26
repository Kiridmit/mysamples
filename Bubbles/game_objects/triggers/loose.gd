
extends "receiver.gd"

func run():
	if not enabled:
		return
	Globals.player_lost()
