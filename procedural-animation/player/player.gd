extends CharacterBody3D

@export var speed = 1.5
@export var acceleration = 9

@onready var gravity = ProjectSettings.get("physics/3d/default_gravity")
@onready var terminal_velocity = ProjectSettings.get("physics/3d/terminal_velocity")

@onready var legs = $CollisionShape3D/Body/Legs.get_children()
@onready var body = $CollisionShape3D/Body

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
	if !legs[0].is_moving && !legs[2].is_moving:
		legs[1].step(dir, delta)
		legs[3].step(dir, delta)
	if !legs[1].is_moving && !legs[3].is_moving:
		legs[0].step(dir, delta)
		legs[2].step(dir, delta)
		
#	var total = Vector3.ZERO;
#	for leg in legs:
#		total += leg.target.global_position
#	total /= legs.size()
#	global_position.y = global_position.lerp(total - global_position, 0.2).y
#
#	var normal = (legs[0].target.global_position - legs[2].target.global_position).cross(legs[1].target.global_position - legs[3].target.global_position).normalized()
#	global_transform.basis.y = normal
#	global_transform.basis.x = -global_transform.basis.z.cross(normal)
#	global_transform.basis = global_transform.basis.orthonormalized()
