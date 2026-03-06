class_name Player extends CharacterBody3D


#const SPEED = 5.0
@export var SPEED_PRONE : float = 1.5
@export var SPEED_DEFAULT : float = 5.0
@export var SPEED_SPRINTING : float = 9
@export var SPEED_CROUCH : float = 2.0
@export var ACCELERATION : float = 0.1
@export var DECELERATION : float = 0.25
# @export var JUMP_VELOCITY = 4.5
# @export var TOGGLE_CROUCH : bool = true
@export_range(1, 5, 0.1) var CROUCH_SPEED : float = 7.0
@export_range(0.0, 2.0, 0.25) var MOUSE_SENSITIVITY : float = 1.0
@export var TILT_LOWER_LIMIT := deg_to_rad(-90.0)
@export var TILT_UPPER_LIMIT := deg_to_rad(90.0)
@export var CAMERA_CONTROLLER = Camera3D
@export var ANIMATIONPLAYER : AnimationPlayer
@export var CROUCH_SHAPECAST : Node3D
@export var free_look_tilt_amount : float = 10.0

@onready var neck: Node3D = $Neck
@onready var COLLISION_SHAPE_3D: CollisionShape3D = $CollisionShape3D
@onready var inventory_controller: Node = %InventoryController

var free_looking : bool = false
var STANDING_HEIGHT : float
var _speed : float
var _mouse_input : bool = false
var _rotation_input : float
var _tilt_input : float
var _mouse_rotation : Vector3
var _player_rotation : Vector3
var _camera_rotation : Vector3
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _input(event):
	if event.is_action_pressed("exit"):
		get_tree().quit()
		
	if Input.is_action_pressed("Inventory"):
		inventory_controller.visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if free_looking == true:
			# Rotate neck only (yaw offset)
			neck.rotation.y += deg_to_rad(-event.relative.x * MOUSE_SENSITIVITY)
			neck.rotation.y = clamp(neck.rotation.y, deg_to_rad(-110), deg_to_rad(110))
		else:
			# Normal FPS rotation
			_rotation_input = -event.relative.x * MOUSE_SENSITIVITY
			_tilt_input = -event.relative.y * MOUSE_SENSITIVITY
			
func _update_camera(delta):
	# Only rotate player body if NOT freelooking
	if free_looking == false:
		_mouse_rotation.y += _rotation_input * delta
		_mouse_rotation.x += _tilt_input * delta
		_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	# Apply body rotation
		global_transform.basis = Basis.from_euler(Vector3(0.0, _mouse_rotation.y, 0.0))
	# Apply pitch to camera
		CAMERA_CONTROLLER.rotation.x = _mouse_rotation.x
		_rotation_input = 0.0
		_tilt_input = 0.0
		
func _apply_movement(delta):
	var lerp_speed = 5.0
	if Input.is_action_pressed("freelook"):
		free_looking = true
		# Add camera roll tilt based on neck yaw
		var target_tilt = -neck.rotation.y * deg_to_rad(free_look_tilt_amount)
		CAMERA_CONTROLLER.rotation.z = lerp(
			CAMERA_CONTROLLER.rotation.z,
			target_tilt,
			delta * lerp_speed
		)
	else:
		free_looking = false
		# Reset neck smoothly
		neck.rotation.y = lerp(neck.rotation.y, 0.0, delta * lerp_speed)
		# Reset tilt smoothly
		CAMERA_CONTROLLER.rotation.z = lerp(
			CAMERA_CONTROLLER.rotation.z,
			0.0,
			delta * lerp_speed
		)
func _ready():
	STANDING_HEIGHT = COLLISION_SHAPE_3D.shape.height
	global.player = self
	#get mouseinput
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_speed = SPEED_DEFAULT
func _physics_process(delta: float) -> void:
	global.debug.add_property("MovementSpeed",_speed,1)
	global.debug.add_property("Velocity","%.2f" % velocity.length(), 2)
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	_apply_movement(delta)
	_update_camera(delta)
		
	var input_dir := Input.get_vector("strafe_left", "strafe_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		#velocity.x = direction.x * _speed
		velocity.x = lerp(velocity.x,direction.x * _speed,ACCELERATION)
		#velocity.z = direction.z * _speed
		velocity.z = lerp(velocity.z,direction.z * _speed, ACCELERATION)
	else:
		velocity.x = move_toward(velocity.x, 0, DECELERATION)
		
		velocity.z = move_toward(velocity.z, 0, DECELERATION)
		
func update_gravity(delta) -> void:
	velocity.y -= gravity * delta
	
func get_input_direction() -> Vector3:
	var input_dir := Input.get_vector(
		"strafe_left",
		"strafe_right",
		"move_forward",
		"move_backward"
	)
	return (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
func update_input(speed: float, acceleration: float, deceleration: float) -> void:
	var input_dir = Input.get_vector("strafe_left","strafe_right","move_forward","move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = lerp(velocity.x, direction.x * _speed, ACCELERATION)
		velocity.z = lerp(velocity.z, direction.z * _speed, ACCELERATION)
	else:
		velocity.x = move_toward(velocity.x, 0, DECELERATION)
		velocity.z = move_toward(velocity.z, 0, DECELERATION)
		
func update_velocity() -> void:
	move_and_slide()
	
