extends Node

const MYMODNAME_LOG := "NetroScript-EnableCheatMenu"

func _init():
	ModLoaderLog.info("Init", MYMODNAME_LOG)

	# Add hook to bypass devMode check
	ModLoaderMod.add_hook(hookedToggleCheats, "res://stages/level/LevelStage.gd", "toggleCheats")

func _ready():
	ModLoaderLog.info("Done", MYMODNAME_LOG)
	add_to_group("mod_init")

func modInit():
	pass


func hookedToggleCheats(chain: ModLoaderHookChain) -> void:
		
	print("Hooked Cheat Toggle Call")
	
	# Store the old dev mode state
	var old_state : bool = GameWorld.devMode
	
	# enable devMode to be able to open the cheat menu
	GameWorld.devMode = true 
	# Call the original function toggling the menu
	chain.execute_next()
	
	# Reset the devMode state 
	GameWorld.devMode = old_state
