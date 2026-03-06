class_name PronePlayerState extends PlayerMovementState

@export var SPEED: float = 0.5
@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.25
@export_range(1,6,0.1) var PRONE_SPEED : float = 4

@onready var PRONE_SHAPECAST : ShapeCast3D = %ProneShapeCast3D

func enter(previous_state: StringName = "") -> void:
	ANIMATION.play("Prone", -1.0, PRONE_SPEED)
	global.player._speed = global.player.SPEED_PRONE
	
func update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	if Input.is_action_pressed("crouch"):
			unprone()
		
func unprone():
	if PRONE_SHAPECAST.is_colliding() == false and Input.is_action_pressed("crouch"):
		ANIMATION.play("UnProne", -1.0, PRONE_SPEED)
		if ANIMATION.is_playing():
			await ANIMATION.animation_finished
		transition.emit("CrouchingPlayerState")
	elif PRONE_SHAPECAST.is_colliding() == true:
		await get_tree().create_timer(0.1).timeout
		unprone()
		
