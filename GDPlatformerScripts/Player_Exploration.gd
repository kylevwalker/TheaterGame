extends KinematicBody2D

const GRAVITY = 1800
const MAX_SPEED = 320
const ACCELERATION = 60

const JUMP_FORCE = 700
const WALL_JUMP_FORCE = -1000
const MIN_VAR_JUMP = 5
const HEAD_BUMP_FORCE = 60
const WALL_SLIDE_FRICTION = 0.2
const MIN_SLIDE_CLAMP = 20

var velocity = Vector2()
var direction_x = 0
var wall_direction = 0
var target_velocity = 0
var max_health = 3

onready var left_wall_raycast = $"Wall Raycasts/Left Wall Raycasts"
onready var right_wall_raycast = $"Wall Raycasts/Right Wall Raycasts"
onready var floor_raycast = $"Wall Raycasts/Floor Raycasts"
onready var ceiling_raycast = $"Wall Raycasts/Ceiling Raycasts"
onready var sprite = $"Sprite"
onready var coyote_timer = $"Coyote Timer"
onready var jump_buffer = $"Jump Buffer"
onready var invincibility_frames = $"Invincibility Frames"
onready var cur_health = max_health

func _apply_gravity(delta, friction):
	# GRAVITY EVERY FRAME
	velocity.y += friction * (delta * GRAVITY)
	if wall_collisions(ceiling_raycast):
		velocity.y = HEAD_BUMP_FORCE
	
func _movement_input(delta):
	if Input.is_action_pressed("right"):
		direction_x = 1
		#$Sprite.flip_h = false
		
	elif Input.is_action_pressed("left"):
		direction_x = -1
		#$Sprite.flip_h = true
	else:
		direction_x = 0
	#target_velocity = direction_x * MAX_SPEED
	#velocity.x = lerp(velocity.x, target_velocity, 0.)
	velocity.x +=  direction_x * ACCELERATION
	if velocity.x > MAX_SPEED :
		velocity.x = MAX_SPEED
	elif velocity.x < -MAX_SPEED:
		velocity.x = -MAX_SPEED
		
func movement(delta):		
	move_and_slide(velocity)

func stop_movement():
	if direction_x == 0:
		velocity.x = 0

func air_friction():
	if direction_x == 0:
		velocity.x = lerp(velocity.x, 0, 0.5)
	
		
func wall_collisions(raycasts):
	for raycast in raycasts.get_children():
		if raycast.is_colliding():
			return true
		
func wall_all_collisions(raycasts):
	for raycast in raycasts.get_children():
		if !raycast.is_colliding():
			return false
	return true

func jump():
	velocity.y = -JUMP_FORCE
		
func jump_cancel():
	velocity.y = MIN_VAR_JUMP
	
func wall_jump():
	velocity.x = WALL_JUMP_FORCE * wall_direction
	velocity.y = -JUMP_FORCE
	
func sprite_flip():
	if velocity.x > 0:
		sprite.flip_h = true
	elif velocity.x < 0:
		sprite.flip_h = false
		

func kill():
	print("You are dead")
