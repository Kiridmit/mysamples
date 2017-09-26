
extends "receiver.gd"

export (String) var text

func run():
	if not enabled:
		return
	.run()
	print( text )