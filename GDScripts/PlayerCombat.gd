extends Spatial

var is_defending = false
var is_attacking = false
var is_idle = false

var maxHP = 5
var HP


onready var body = $Body
onready var dodge_anim_player = $Body/AnimationPlayer
onready var parry_anim_player = $Body/FPSHandsTest/AnimationPlayer
onready var dodge_timer_right = $DodgeTimerRight
onready var dodge_timer_left = $DodgeTimerLeft
onready var dodge_timer_down = $DodgeTimerDown

func _ready():
	#is_defending = true
	is_attacking = true
	
func _physics_process(delta):
	if is_defending:
		_process_defense(delta)
	elif is_attacking:
		_process_offense(delta)
	if !dodge_anim_player.is_playing():
		if !dodge_timer_right.is_stopped():
			dodge_right()
		elif !dodge_timer_left.is_stopped():
			dodge_left()
		elif !dodge_timer_down.is_stopped():
			dodge_down()
			
func _process_defense(delta):
	if Input.is_action_just_pressed("ui_right"):
		dodge_timer_right.start()
			
	elif Input.is_action_just_pressed("ui_left"):
		dodge_timer_left.start()
	elif Input.is_action_just_pressed("ui_down"):
		dodge_timer_down.start()
	elif Input.is_action_pressed("ui_up") && !dodge_anim_player.is_playing():
		block()
	
func dodge_right():
	print("dodge right")
	dodge_anim_player.play("DodgeRight")
	
func dodge_left():
	print("dodge left")
	dodge_anim_player.play("DodgeLeft")
	
func block():
	print("blocking")
	
func dodge_down():
	print("dodge down")
	dodge_anim_player.play("DodgeDown")
	
	
# -------------------------------------------

func _process_offense(delta):
	
	if Input.is_action_just_pressed("ui_right"):
		parry("RIGHT")
	elif Input.is_action_just_pressed("ui_left"):
		parry("LEFT")
	elif Input.is_action_just_pressed("ui_down"):
		parry("DOWN")
	elif Input.is_action_pressed("ui_up"):
		parry("UP")
func parry(direction):
	match direction:
		"UP":
			parry_anim_player.play("Parry_Up")
		"LEFT":
			parry_anim_player.play("Parry_Left")
		"RIGHT":
			parry_anim_player.play("Parry_Right")
		"DOWN":
			parry_anim_player.play("Parry_Down")
