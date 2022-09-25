extends CharacterBody3D

@export var speed = 1
@export var acceleration = 9

@onready var legs = $CollisionShape3D/Body/Legs.get_children()
@onready var body = $CollisionShape3D/Body

func _physics_process(delta):
	var camera_basis = $Camera3D.transform.basis
	var input = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_forward", "move_backward"))
	var direction = Vector3(input.x, 0, input.y)
	direction.y = 0
	direction = direction.normalized()
	
	velocity.x = velocity.x + (direction.x * speed - velocity.x) * (acceleration * delta)
	velocity.z = velocity.z + (direction.z * speed - velocity.z) * (acceleration * delta)
	
	global_position += velocity * transform.basis.inverse() * delta
	
#	move_and_collide(velocity * delta)
	
#	if direction.length() > 0:
#		var q_from = global_transform.basis.get_rotation_quaternion()
#		var q_to = Transform3D().looking_at(direction).basis.get_rotation_quaternion()
#		global_transform.basis = Basis(q_from.slerp(q_to, 5 * delta))
	
	var dir = (velocity * transform.basis.inverse()).normalized()
	if !legs[0].is_moving && !legs[2].is_moving:
		legs[1].step(dir, delta)
		legs[3].step(dir, delta)
	if !legs[1].is_moving && !legs[3].is_moving:
		legs[0].step(dir, delta)
		legs[2].step(dir, delta)

	var avg_surface_dist = 0.0
	for leg in legs:
		avg_surface_dist += to_local(leg.target.global_position).y
	avg_surface_dist /= legs.size()
	translate_object_local(Vector3(0, avg_surface_dist, 0))
	
	var normal = (legs[0].target.global_position - legs[2].target.global_position).cross(legs[1].target.global_position - legs[3].target.global_position).normalized()
	transform.basis.y = normal
	transform.basis.x = -transform.basis.z.cross(normal)
	transform.basis = transform.basis.orthonormalized()
