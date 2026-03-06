class_name FallingPlayerState
extends PlayerMovementState

@export var SPEED: float = 6.0
@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.25
@export var JUMP_VELOCITY: float = 4.5
@export_range(0.01, 1.0, 0.01) var INPUT_MULTIPLIER: float = 0.85

# Store horizontal momentum when jump starts
#var jump_initial_velocity: Vector3 = Vector3.ZERO

func enter(previous_state: StringName = "") -> void:
	# Add upward jump velocity
	#PLAYER.velocity.y += JUMP_VELOCITY

	# Save current horizontal momentum
	#jump_initial_velocity = Vector3(PLAYER.velocity.x, 0, PLAYER.velocity.z)

	ANIMATION.pause()


func update(delta):
	PLAYER.update_gravity(delta)

	# Apply input scaled by INPUT_MULTIPLIER
	PLAYER.update_input(SPEED * INPUT_MULTIPLIER, ACCELERATION * INPUT_MULTIPLIER, DECELERATION)

	# --- Limit midair horizontal velocity added by input ---
	if not PLAYER.is_on_floor():
		var horizontal_velocity = Vector3(PLAYER.velocity.x, 0, PLAYER.velocity.z)
		#var added_velocity = horizontal_velocity - jump_initial_velocity  # only new velocity added midair
		var max_air_speed = SPEED * INPUT_MULTIPLIER

		#if added_velocity.length() > max_air_speed:
			#var factor = max_air_speed / added_velocity.length()
			#added_velocity *= factor
			# Apply capped added velocity back onto initial momentum
			#PLAYER.velocity.x = jump_initial_velocity.x + added_velocity.x
			#PLAYER.velocity.z = jump_initial_velocity.z + added_velocity.z

	PLAYER.update_velocity()

	if PLAYER.is_on_floor():
		transition.emit("IdlePlayerState")
