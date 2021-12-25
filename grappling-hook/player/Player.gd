extends KinematicBody

var speed = 3
var acceleration = 9
var jump_impulse = 6.2

var direction = Vector3.ZERO
var velocity = Vector3.ZERO

onready var gravity = ProjectSettings.get("physics/3d/default_gravity")
onready var terminal_velocity = ProjectSettings.get("physics/3d/terminal_velocity")

onready var grappling_hook = $GrapplingHook

func _input(event):
	if event.is_action_pressed("grapple"):
		grappling_hook.grapple()
	if event.is_action_released("grapple"):
		grappling_hook.release()

func _physics_process(delta):
	direction = Vector3.ZERO
	direction += transform.basis.x * Input.get_axis("move_left", "move_right")
	direction += transform.basis.z * Input.get_axis("move_forward", "move_backward")
	direction = direction.normalized()

	velocity.x = velocity.x + (direction.x * speed - velocity.x) * (acceleration * delta)
	velocity.z = velocity.z + (direction.z * speed - velocity.z) * (acceleration * delta)
	velocity.y = clamp(velocity.y - (gravity * delta), -terminal_velocity, terminal_velocity)
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_impulse
	
	velocity = move_and_slide(velocity, Vector3.UP, true)
