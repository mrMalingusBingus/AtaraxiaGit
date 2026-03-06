class_name RollingPlayerState
extends PlayerMovementState

@export var DODGE_SPEED: float = 1.0
@export var DODGE_DURATION: float = 0.6
@export var DODGE_FRICTION: float = 100.0
@export var INPUT_LOCKED: bool = true
@export var TOP_ANIM_SPEED: float = 1.5

var dodge_timer: float = 0.0
var dodge_direction: Vector3 = Vector3.ZERO


func enter(previous_state: StringName = "") -> void:
	dodge_timer = DODGE_DURATION
	# Get movement input direction relative to camera
	var input_dir = PLAYER.get_input_direction()
	if input_dir.length() == 0:
		pass
	else:
		dodge_direction = input_dir.normalized()
		
		dodge_direction.y = 0
		dodge_direction = dodge_direction.normalized()
		# Apply instant burst velocity
		PLAYER.velocity.x = dodge_direction.x * DODGE_SPEED
		PLAYER.velocity.z = dodge_direction.z * DODGE_SPEED
		ANIMATION.play("Roll")
	
#func set_animation_speed(spd) -> void:
	#var alpha = remap(spd, 0.0, DODGE_SPEED, 0.0, 1.0)
	#ANIMATION.speed_scale = lerp(0.0, TOP_ANIM_SPEED, alpha)
	#
func update(delta: float) -> void:
	PLAYER.update_gravity(delta)
	dodge_timer -= delta
	# Apply friction to gradually slow dodge
	var horizontal_velocity = Vector3(PLAYER.velocity.x, 0, PLAYER.velocity.z)
	horizontal_velocity = horizontal_velocity.move_toward(Vector3.ZERO, DODGE_FRICTION * delta)
	PLAYER.velocity.x = horizontal_velocity.x
	PLAYER.velocity.z = horizontal_velocity.z
	PLAYER.move_and_slide()
	#set_animation_speed(horizontal_velocity.length())
	if dodge_timer <= 0.0:
		transition_after_dodge()


func transition_after_dodge() -> void:
	if PLAYER.is_on_floor():
		transition.emit("CrouchingPlayerState")
	else:
		transition.emit("FallingPlayerState")
