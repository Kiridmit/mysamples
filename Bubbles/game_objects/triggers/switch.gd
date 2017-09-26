
extends "transmitter.gd"

export ( String, "enable", "disable", "switch" ) var mode

func run():
	if not enabled:
		return
	if mode == "enable":
		for trigger_name in trigger_array:
			for trigger in Globals.triggers:
				if trigger.name == trigger_name:
					trigger.enabled = true
	elif mode == "enable":
		for trigger_name in trigger_array:
			for trigger in Globals.triggers:
				if trigger.name == trigger_name:
					trigger.enabled = false
	else:
		for trigger_name in trigger_array:
			for trigger in Globals.triggers:
				if trigger.name == trigger_name:
					trigger.enabled = not trigger.enabled

