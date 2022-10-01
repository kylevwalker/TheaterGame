extends Spatial

var interacting = false
onready var cursor_open = load("res://icon.png")
onready var cursor_closed = load("res://UI Graphics/CursorTestAD64.png")
onready var target_position = self.translation
onready var target_rotation = self.rotation
signal return_nav_position

func _on_Hitbox_mouse_entered():
	#Input.set_custom_mouse_cursor(cursor_open)
	interacting = true
	
func _on_Hitbox_mouse_exited():
	#Input.set_custom_mouse_cursor(cursor_closed)
	interacting = false
	
func _input(event):
	if Input.is_action_just_pressed("interact_click") && interacting:
		emit_signal("return_nav_position", target_position, target_rotation)
		
		
		
		

