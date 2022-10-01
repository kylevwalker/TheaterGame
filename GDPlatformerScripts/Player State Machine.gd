extends StateMachine
#-------------------------------------------------------------------------------
func _ready():
	add_state("Idle")
	add_state("Run")
	add_state("Jump")
	add_state("Fall")
	add_state("WallSlide")
	add_state("WallJump")
	add_state("WallJumpFall")
	# Add states here to append them to state dictionary
	call_deferred("set_state", states.Idle)

#-------------------------------------------------------------------------------
func _input(event):
	# Jumping and Coyote Jumping
	if [states.Idle, states.Run].has(state) || \
	!parent.coyote_timer.is_stopped():
		if event.is_action_pressed("jump"): 
			parent.coyote_timer.stop()
			parent.jump()
		if event.is_action_released("jump"):
			parent.jump_buffer.stop()
			parent.jump_cancel()
	elif [states.Jump, states.WallJump].has(state):
		if event.is_action_released("jump"):
			parent.jump_cancel()
	# Jump Buffer Trigger
	elif state == states.Fall || state == states.WallJumpFall:
		if event.is_action_pressed("jump"):
			parent.jump_buffer.start()
	elif state == states.WallSlide:
		if event.is_action_pressed("jump"):
			parent.wall_jump()
	
#-------------------------------------------------------------------------------				
func _state_logic(delta):
	# Apply gravity when not grounded
	if !parent.wall_collisions(parent.floor_raycast):
		if state == states.WallSlide && parent.velocity.y > 0:
			parent._apply_gravity(delta, parent.WALL_SLIDE_FRICTION)
		else:
			parent._apply_gravity(delta, 1)
	# Prevent falling during coyote time
	if !parent.coyote_timer.is_stopped():
		parent.velocity.y = 0
	# Move player every frame
	if ![states.WallJump].has(state):
		parent._movement_input(delta)
	parent.movement(delta)
	# Stop movement in standard operations when releasing input
	if ![states.WallJump, states.WallSlide, states.WallJumpFall].has(state):
		parent.stop_movement()

	# Jump Buffer
	if !parent.jump_buffer.is_stopped() && \
	parent.wall_collisions(parent.floor_raycast) \
	&& Input.is_action_pressed("jump"):
		parent.jump_buffer.stop()
		parent.jump()
	parent.sprite_flip()
	if state == states.WallSlide:
		if parent.velocity.y < 0:
			parent.sprite.play("WallClimb")
		else:
			parent.sprite.play("WallSlide")
	# DEBUGGER
	#print(state)
#-------------------------------------------------------------------------------
func _get_transition(delta):
	# Matches each state based on certain conditions
	match state:
		states.Idle:
			if !parent.wall_collisions(parent.floor_raycast):
				if parent.velocity.y < 0:
					return states.Jump
				elif parent.velocity.y > 0:
					return states.Fall
			elif parent.velocity.x != 0:
				return states.Run
			
			
		states.Run:
			if !parent.wall_collisions(parent.floor_raycast):
				if parent.velocity.y < 0:
					return states.Jump
				elif parent.velocity.y > 0:
					# Starts coyote timer when transitioning from run to fall
					parent.coyote_timer.start()
					return states.Fall
			elif parent.velocity.x == 0:
				return states.Idle
	
		
		states.Jump:
			if parent.wall_collisions(parent.floor_raycast):
				return states.Idle
			elif parent.velocity.y >= 0:
				return states.Fall
			elif parent.wall_all_collisions(parent.right_wall_raycast):
				parent.wall_direction = 1
				return states.WallSlide
			elif parent.wall_all_collisions(parent.left_wall_raycast):
				parent.wall_direction = -1
				return states.WallSlide
	
				
		states.Fall:
			if parent.wall_collisions(parent.floor_raycast):
				return states.Idle
			elif parent.velocity.y < 0:
				return states.Jump
			# Catches player on wall to limit wall slide from any speed
			elif parent.wall_all_collisions(parent.right_wall_raycast):
				parent.wall_direction = 1
				if parent.velocity.y > parent.MIN_SLIDE_CLAMP:
					parent.jump_cancel()
				return states.WallSlide
			elif parent.wall_all_collisions(parent.left_wall_raycast):
				parent.wall_direction = -1
				if parent.velocity.y > parent.MIN_SLIDE_CLAMP:
					parent.jump_cancel()
				return states.WallSlide
	
		
		states.WallSlide:
			if parent.wall_collisions(parent.floor_raycast):
				return states.Idle
			elif !(parent.wall_all_collisions(parent.right_wall_raycast) || \
			parent.wall_all_collisions(parent.left_wall_raycast)):
				if parent.velocity.y >= 0:
					return states.Fall
				elif parent.velocity.y < 0:
					return states.WallJump
	
			
		states.WallJump:
			if parent.velocity.y >= 0:
				return states.WallJumpFall
			elif parent.wall_collisions(parent.floor_raycast):
				return states.Idle
			elif (parent.wall_all_collisions(parent.right_wall_raycast) || \
			parent.wall_all_collisions(parent.left_wall_raycast)):
				return states.WallSlide
	
				
		states.WallJumpFall:
			# Catches player on wall to limit wall slide from any speed
			if parent.wall_collisions(parent.floor_raycast):
				return states.Idle
			elif parent.wall_all_collisions(parent.right_wall_raycast):
				parent.wall_direction = 1
				if parent.velocity.y > parent.MIN_SLIDE_CLAMP:
					parent.jump_cancel()
				return states.WallSlide
			elif parent.wall_all_collisions(parent.left_wall_raycast):
				parent.wall_direction = -1
				if parent.velocity.y > parent.MIN_SLIDE_CLAMP:
					parent.jump_cancel()
				return states.WallSlide
		
			
				
			
	return null
#-------------------------------------------------------------------------------	
func _enter_state(new_state, old_state):
	match new_state:
		states.Idle:
			parent.sprite.play("Idle")
		states.Run:
			parent.sprite.play("Run")
		states.Jump:
			parent.sprite.play("Jump")
		states.Fall:
			parent.sprite.play("Fall")
		states.WallJumpFall:
			parent.sprite.play("Fall")
		states.WallJump:
			parent.sprite.play("Jump")

func _exit_state(old_state, new_state):
	pass
	
