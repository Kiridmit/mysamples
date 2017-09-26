
extends TextureProgress
var win_mass = 0
#var player
var WIN = false
var LOOSE = false

func _ready():
	#player = Globals.scene.get_node( "Bubbles/Player" )
	if Globals.player == null:
		return
	for bubble in Globals.scene.get_node( "Bubbles" ).get_children():
	#	print(i.get_name(), " ", i.mass)
		if not bubble.is_anti:
			win_mass += bubble.mass
		else:
			win_mass -= bubble.mass
	win_mass *= 0.8
	set_max( win_mass )
	print( "win mass = ", win_mass, ": player mass = ", Globals.player.mass )
	
	set_fixed_process( true )

func _fixed_process( delta ):
	
	# Отслеживание выигрыша
	if Globals.player.mass > win_mass and WIN == false:
		Globals.player_won()
		WIN = true
	if Globals.player. mass <= 0 and LOOSE == false:
		Globals.player_lost()
		LOOSE = true
	#print( "get_value: ", get_val() )
	set_val( Globals.player.mass )