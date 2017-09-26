
extends "transmitter.gd"

export ( String, "=", "+", "-", "*", "/" ) var mode
export ( String ) var property_name
export ( float ) var value

func run():
	if not enabled:
		return
	if mode == "=":
		for trigger_name in trigger_array:
			for trigger in Globals.triggers:
				if trigger.name == trigger_name:
					trigger.set( property_name, value )
	elif mode == "+":
		for trigger_name in trigger_array:
			for trigger in Globals.triggers:
				if trigger.name == trigger_name:
					trigger.set( property_name, trigger.get( property_name ) + value )
	elif mode == "-":
		for trigger_name in trigger_array:
			for trigger in Globals.triggers:
				if trigger.name == trigger_name:
					trigger.set( property_name, trigger.get( property_name ) - value )
	elif mode == "*":
		for trigger_name in trigger_array:
			for trigger in Globals.triggers:
				if trigger.name == trigger_name:
					trigger.set( property_name, trigger.get( property_name ) * value )
	else:
		for trigger_name in trigger_array:
			for trigger in Globals.triggers:
				if trigger.name == trigger_name:
					trigger.set( property_name, trigger.get( property_name ) / value )

