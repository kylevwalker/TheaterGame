extends Spatial

export var sensitivity = 0.05
#onready var cursor = load("res://UI Graphics/CursorTestAD64.png")


#func _input(event):
#	if Input.is_action_pressed("drag_camera"):
#		if event is InputEventMouseMotion:
#			 # reset rotation
#			rot_x += event.relative.x * sensitivity
#			rot_y += event.relative.y * sensitivity
#			#rot_x = clamp(rot_x, -limit_x, limit_x)
#			rot_y = clamp(rot_y, -limit_y, limit_y)
#			transform.basis = Basis()
#			rotate_object_local(Vector3(0, 1, 0), rot_x) 
#			rotate_object_local(Vector3(1, 0, 0), rot_y)



		
		
