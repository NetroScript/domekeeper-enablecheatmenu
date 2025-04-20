extends Node

const MYMODNAME_LOG := "NetroScript-EnableCheatMenu"

var used_cheats_in_current_run : bool = false:
	set(value):
		if value != used_cheats_in_current_run:
			# If the value is set to true, we want to log it
			if value:
				ModLoaderLog.info("Cheat Menu was used in this run", MYMODNAME_LOG)
		used_cheats_in_current_run = value
		

func _init():
	ModLoaderLog.info("Init", MYMODNAME_LOG)

	# Add hook to bypass devMode check
	ModLoaderMod.add_hook(hookedToggleCheats, "res://stages/level/LevelStage.gd", "toggleCheats")
	ModLoaderMod.add_hook(onRunStart, "res://stages/loadout/MultiplayerloadoutStage.gd", "startRun")
	ModLoaderMod.add_hook(hookPrestigeEndScreenReady, "res://content/gamemode/prestige/RunFinishedPopup.gd", "_ready")

func _ready():
	ModLoaderLog.info("Done", MYMODNAME_LOG)
	add_to_group("mod_init")

func modInit():
	pass


func hookedToggleCheats(chain: ModLoaderHookChain) -> void:
		
	ModLoaderLog.info("Hooked Cheat Toggle Call", MYMODNAME_LOG)


	# When in an unknown game mode which does not allow cheats, use the original function -> only special handling for prestige is implemented
	if CheatDetection.isRunning and Level.loadout.modeId != Const.MODE_PRESTIGE:
		ModLoaderLog.info("Unknown Competitive Game Mode Detected, falling back to default Chat Toggle Behavior", MYMODNAME_LOG)
		chain.execute_next()
		return
	
		
	used_cheats_in_current_run = true

	# Store the old dev mode state
	var old_state : bool = GameWorld.devMode
	
	# enable devMode to be able to open the cheat menu
	GameWorld.devMode = true 
	# Call the original function toggling the menu
	chain.execute_next()
	
	# Reset the devMode state 
	GameWorld.devMode = old_state

func onRunStart(chain: ModLoaderHookChain) -> void:
	ModLoaderLog.info("Hooked Run Start Call", MYMODNAME_LOG)
	# Reset the used cheats flag
	used_cheats_in_current_run = false
	# Call the original function
	chain.execute_next()


func hookPrestigeEndScreenReady(chain: ModLoaderHookChain) -> void:
	
	# If no cheats were used, run the original function
	if not used_cheats_in_current_run:
		chain.execute_next()
		return

	var screen: CenterContainer = chain.reference_object
	# Hide the leaderboard display, and replace it with a dummy version before ready is called 
	screen.Leaderboard.visible = false
	screen.Leaderboard = DummyLeaderboard.new()

	# Run the original functionality of the ready function
	chain.execute_next()

	# Display custom message that the leaderboard was disabled
	var ScoreUploadResult : Label = screen.find_child("ScoreUploadResult")

	screen.scoreUploadMessage = "Score upload disabled due to using the cheat menu in this run. Do not use the cheat menu to be able to use the leaderboard."
	ScoreUploadResult.text = screen.scoreUploadMessage

	# Also stop the CheatDetection similar to how the original leaderboard would do
	if CheatDetection.isRunning:
		CheatDetection.stop()


class DummyLeaderboard:
	signal leaderboard_not_found
	signal leaderboard_found
	signal leaderboard_score_upload_success
	signal leaderboard_score_upload_failed
	signal leaderboard_download_finished

	func start(variant: String, showSeasonControls := true, showModeControls := false):
		ModLoaderLog.info("Replaced Leaderboard Start with DummyLeaderboard", MYMODNAME_LOG)

	func uploadScore(score: int):
		ModLoaderLog.info("Replaced Leaderboard Upload with DummyLeaderboard", MYMODNAME_LOG)
