class_name CrouchingPlayerState extends PlayerMovementState

@export var SPEED: float = 2.0
@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.25
@export_range(1,6,0.1) var CROUCH_SPEED : float = 4

@onready var CROUCH_SHAPECAST : ShapeCast3D = %ShapeCast3D

func enter(previous_state: StringName = "") -> void:
	if previous_state == "PronePlayerState":
		var anim := ANIMATION.get_animation("Crouch")
		var end_time := anim.length - 0.001
		
		ANIMATION.play("Crouch")
		ANIMATION.seek(end_time, true)
		#ANIMATION.stop()  # Optional
		
	elif previous_state == "RollingPlayerState":
		var anim := ANIMATION.get_animation("Crouch")
		var end_time := anim.length - 0.001
		
		ANIMATION.play("Crouch")
		ANIMATION.seek(end_time, true)
	else:
		ANIMATION.play("Crouch", -1.0, CROUCH_SPEED)
	global.player._speed = global.player.SPEED_CROUCH
	
	#if previous_state == "PronePlayerState":
		#var LENGTH := ANIMATION.get_animation("Crouch").length
		#ANIMATION.play("Crouch")
		#ANIMATION.seek(LENGTH, true)
		#
	#else:
		#ANIMATION.play("Crouch", -1.0, CROUCH_SPEED)
		#
func update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	if Input.is_action_pressed("crouch") == false:
		uncrouch()
		
	if Input.is_action_just_pressed("prone") and PLAYER.is_on_floor():
		transition.emit("PronePlayerState")
		
	if Input.is_action_just_pressed("roll") and PLAYER.is_on_floor():
		if global.player._speed > 0.0:
			transition.emit("RollingPlayerState")
		
func uncrouch():
	if CROUCH_SHAPECAST.is_colliding() == false and Input.is_action_pressed("crouch") == false:
		ANIMATION.play("Crouch", -1.0, -CROUCH_SPEED * 1.5, true)
		if ANIMATION.is_playing():
			await ANIMATION.animation_finished
		transition.emit("IdlePlayerState")
	elif CROUCH_SHAPECAST.is_colliding() == true:
		await get_tree().create_timer(0.1).timeout
		uncrouch()
		
