class_name SprintingPlayerState
extends PlayerMovementState
# @export var ANIMATION : AnimationPlayer
@export var SPEED: float = 9.0
@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.025
@export var TOP_ANIM_SPEED : float = 1.8

func enter(previous_state: StringName = "") -> void:
	ANIMATION.play("Sprinting", 0.5, 1.0)
	global.player._speed = global.player.SPEED_SPRINTING
	
func exit() -> void:
	ANIMATION.speed_scale = 1.0
	
func update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	set_animation_speed(global.player.velocity.length())
	
	if Input.is_action_just_released("sprint"):
		transition.emit("WalkingPlayerState")
		
	if Input.is_action_pressed("move_forward") == false:
		transition.emit("WalkingPlayerState")
		
	if Input.is_action_just_pressed("jump") and PLAYER.is_on_floor():
		if Input.is_action_pressed("crouch") == false:
			transition.emit("JumpingPlayerState")
		
	if Input.is_action_pressed("crouch") and Input.is_action_just_pressed("jump") and PLAYER.is_on_floor():
		transition.emit("RollingPlayerState")
		
func set_animation_speed(spd) -> void:
	var alpha = remap(spd, 0.0, SPEED, 0.0, 1.0)
	ANIMATION.speed_scale = lerp(0.0, TOP_ANIM_SPEED, alpha)
	
