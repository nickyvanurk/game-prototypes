extends CharacterBody3D

@export var speed = 0.6
@export var acceleration = 9
@export var jump_impulse = 6.2

@onready var gravity = ProjectSettings.get("physics/3d/default_gravity")
@onready var terminal_velocity = ProjectSettings.get("physics/3d/terminal_velocity")

@onready var legs = $CollisionShape3D/Body/Legs.get_children()

func _physics_process(delta):
	var camera_basis = $Camera3D.transform.basis
	var input = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_forward", "move_backward"))
	var direction = camera_basis * Vector3(input.x, 0, input.y)
	direction.y = 0
	direction = direction.normalized()
	
	velocity.x = velocity.x + (direction.x * speed - velocity.x) * (acceleration * delta)
	velocity.z = velocity.z + (direction.z * speed - velocity.z) * (acceleration * delta)
	
	move_and_slide()
	
#	if direction.length() > 0:
#		var q_from = global_transform.basis.get_rotation_quaternion()
#		var q_to = Transform3D().looking_at(direction).basis.get_rotation_quaternion()
#		global_transform.basis = Basis(q_from.slerp(q_to, 5 * delta))
	
	var dir = velocity.normalized()
	var speed_frac = velocity.length() / speed
	if !legs[0].is_moving && !legs[2].is_moving:
		legs[1].step(dir, speed_frac, delta)
		legs[3].step(dir, speed_frac, delta)
	if !legs[1].is_moving && !legs[3].is_moving:
		legs[0].step(dir, speed_frac, delta)
		legs[2].step(dir, speed_frac, delta)
