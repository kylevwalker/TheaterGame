extends KinematicBody

var rotation_helper
var vel = Vector3()
var crosshair 
var can_move = true
export var sensitivity = 0.04

const CAM_Y_LIM = 70
const ACCEL = 8
const gravity = -24
const MAX_SPEED = 15
const DEACCEL = 16
const MAX_SLOPE_ANGLE = 40

func _ready():
	GameManager.player_node = self
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	rotation_helper = $Rotation
	crosshair = $Control/Crosshairs
func _physics_process(delta):
	if can_move:
		_process_movement(delta)	

func _input(event):         
	# Rotate body and camera
	if can_move:
		if event is InputEventMouseMotion:
			var mouse_move = event.relative
			rotation_helper.rotation.x += -deg2rad\
				(mouse_move.y * sensitivity)
			rotation_helper.rotation.x = clamp\
				(rotation_helper.rotation.x, 
				deg2rad(-CAM_Y_LIM), deg2rad(CAM_Y_LIM))
			self.rotation.y += -deg2rad(mouse_move.x * sensitivity)


func _process_movement(delta):
	var dir = Vector3()

	if Input.is_action_pressed("movement_forward"):
		dir -= transform.basis.z
	if Input.is_action_pressed("movement_back"):
		dir += transform.basis.z
	if Input.is_action_pressed("movement_left"):
		dir -= transform.basis.x
	if Input.is_action_pressed("movement_right"):
		dir += transform.basis.x
	
	dir = dir.normalized()
	vel.y += (gravity * delta)
	
	var hvel = vel
	hvel.y = 0

	var target = dir
	target *= MAX_SPEED
	var accel
	if dir.dot(hvel) > 0:
		accel = ACCEL
	else:
		accel = DEACCEL

	hvel = hvel.linear_interpolate(target, accel * delta)
	vel.x = hvel.x
	vel.z = hvel.z
	vel = move_and_slide(vel, Vector3(0, 1, 0), 0.05, 4, 
		deg2rad(MAX_SLOPE_ANGLE))
		
func _on_Area_area_shape_entered(area_id, area, area_shape, local_shape):
	crosshair.play("interacting")

func _on_Area_area_shape_exited(area_id, area, area_shape, local_shape):
	crosshair.play("default")
