extends KinematicBody

export(NodePath) var animation_tree

var speed = 3
var acceleration = 9
var jump_impulse = 6.2

var direction = Vector3.ZERO
var velocity = Vector3.ZERO

onready var gravity = ProjectSettings.get("physics/3d/default_gravity")
onready var terminal_velocity = ProjectSettings.get("physics/3d/terminal_velocity")

onready var anim_tree = get_node(animation_tree)

func _physics_process(delta):
	direction = Vector3.ZERO
	direction += transform.basis.x * Input.get_axis("move_left", "move_right")
	direction += transform.basis.z * Input.get_axis("move_forward", "move_backward")
	direction = direction.normalized()

	velocity.x = velocity.x + (direction.x * speed - velocity.x) * (acceleration * delta)
	velocity.z = velocity.z + (direction.z * speed - velocity.z) * (acceleration * delta)
	velocity.y = clamp(velocity.y - (gravity * delta), -terminal_velocity, terminal_velocity)
	
	if is_on_floor():
		if direction != Vector3.ZERO:
			anim_tree["parameters/playback"].travel("Walk")
		else:
			anim_tree["parameters/playback"].travel("Idle")
		
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_impulse
			anim_tree["parameters/playback"].travel("Jump")
	
	velocity = move_and_slide(velocity, Vector3.UP, true)
