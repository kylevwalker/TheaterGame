extends Node

var player_node = null
var dialog_manager_node = null

var current_state: int
var previous_state: int

enum gameState{MENU_MODE, STORY_MODE, EXPLORE_MODE, NAVIGATION_MODE, COMBAT_MODE}


func _ready():
	current_state = gameState.EXPLORE_MODE
	updateGameState(current_state)

func updateGameState(newState):
	# Prevents Menu Mode from being recorded in rewind, as 
	# this will never occur
	if current_state != gameState.MENU_MODE:
		previous_state = current_state
	match(newState):
		# -----------------------------------------------------------
		0:
			print("in menu mode")
			current_state = gameState.MENU_MODE
			get_tree().paused = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
		# -----------------------------------------------------------
		1:
			print("in story mode")
			current_state = gameState.STORY_MODE
			if player_node != null:
				player_node.can_move = false
			PauseMenu.can_pause = false
			get_tree().paused = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
		# -----------------------------------------------------------
		2:
			print("in explore mode")
			current_state = gameState.EXPLORE_MODE
			if player_node != null:
				player_node.can_move = true
			PauseMenu.can_pause = true
			get_tree().paused = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
		# -----------------------------------------------------------
		3:
			print("in navigation mode")
			current_state = gameState.NAVIGATION_MODE
			get_tree().paused = false
			PauseMenu.can_pause = true
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
		# -----------------------------------------------------------
		4:
			print("in combat mode")
			PauseMenu.can_pause = false
			current_state = gameState.COMBAT_MODE

func rewindGameState():
	updateGameState(previous_state)

