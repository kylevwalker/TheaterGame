extends Control

onready var text = get_node("Canvas/TextDisplay")

	
func _process(delta):
	text.bbcode_text = "FPS: " + str(Performance.get_monitor(Performance.TIME_FPS)) + "\n"
	text.bbcode_text += "DRAW CALLS: " + \
		str(Performance.get_monitor(Performance.RENDER_DRAW_CALLS_IN_FRAME)) + "\n"
	text.bbcode_text += "GAME MODE: " + str(GameManager.gameState.keys()[GameManager.current_state])
