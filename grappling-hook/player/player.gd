extends KinematicBody

var speed = 10
var acceleration = 9
var air_acceleration = 2
var jump_impulse = 6.2

var direction = Vector3.ZERO
var velocity = Vector3.ZERO

onready var gravity = ProjectSettings.get("physics/3d/default_gravity")
onready var terminal_velocity = ProjectSettings.get("physics/3d/terminal_velocity")

onready var camera = $Camera
onready var grappling_hook = $GrapplingHook

var ray_length = 100
var last_space_state

func _ready():
	last_space_state = get_world().direct_space_state

func _input(event):
	if event.is_action_pressed("grapple"):
		var target = raycast(last_space_state)
		if target: grappling_hook.grapple(target)
	if event.is_action_released("grapple"):
		grappling_hook.release()

func _physics_process(delta):
	direction = get_input_direction()
	var accel = acceleration if is_on_floor() else air_acceleration
	velocity.x += (direction.x * speed - velocity.x) * (accel * delta)
	velocity.z += (direction.z * speed - velocity.z) * (accel * delta)
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_impulse
	
	if !grappling_hook.is_attached():
		velocity.y = clamp(velocity.y - (gravity * delta), -terminal_velocity, terminal_velocity)
	
	velocity = move_and_slide(velocity, Vector3.UP, true)
	
	last_space_state = get_world().direct_space_state

func get_input_direction():
	direction = transform.basis.x * Input.get_axis("move_left", "move_right")
	direction += transform.basis.z * Input.get_axis("move_forward", "move_backward")
	return direction.normalized()

func raycast(space_state):
	var center = get_viewport().size / 2
	var from = camera.project_ray_origin(center)
	var to = from + camera.project_ray_normal(center) * ray_length
	var result = space_state.intersect_ray(from, to, [self])
	return result.position if result else false
