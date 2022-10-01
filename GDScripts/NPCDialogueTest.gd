extends Spatial

var interacting = false
onready var cursor_open = load("res://icon.png")
onready var cursor_closed = load("res://UI Graphics/CursorTestAD64.png")
onready var pose_player = $"VeneziaPoseModelTest/PosePlayer" 
export(int) var starting_index
export(int) var ending_index
onready var dialog_manager = get_parent().get_parent()

#func _ready():
	
func _on_Hitbox_area_shape_entered(area_id, area, area_shape, local_shape):
	interacting = true
	#Change cursor

func _on_Hitbox_area_shape_exited(area_id, area, area_shape, local_shape):
	interacting = false
	#Change Cursor back
	
func _input(event):
	if Input.is_action_just_pressed("interact") && interacting:
		dialog_manager.play_dialog(starting_index, ending_index)
		
		
		
		
			
