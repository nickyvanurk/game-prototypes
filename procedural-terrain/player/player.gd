extends CharacterBody3D

@export var speed = 10.0
@export var jump_velocity = 4.5
@export var look_sensitivity = 0.01

@onready var camera = $Camera3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var velocity_y = 0


func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * look_sensitivity)
		camera.rotate_x(-event.relative.y * look_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)


func _physics_process(delta):
	var v = Input.get_vector("move_left", "move_right", "move_forward", "move_backward").normalized() * speed
	velocity = v.x * global_transform.basis.x + v.y * global_transform.basis.z
	
	if is_on_floor():
		velocity_y = jump_velocity if Input.is_action_just_pressed("jump") else 0
	else:
		velocity_y -= gravity * delta
	velocity.y = velocity_y
	move_and_slide()
	
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE
