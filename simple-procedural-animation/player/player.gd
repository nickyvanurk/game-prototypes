extends CharacterBody3D

@export var speed = 1
@export var acceleration = 9
@export var rotation_speed = 120 # deg/s

@onready var legs = $Shape/Body/Legs.get_children()
@onready var body = $Shape/Body
@onready var shape = $Shape
@onready var shape_offset = shape.position
@onready var camera_pivot = $CameraPivot


func _physics_process(delta):
	var input = Input.get_vector("left", "right", "forward", "backward")
	var direction = Vector3(input.x, 0, input.y)
	direction.y = 0
	direction = direction.normalized()
	
	velocity.x = velocity.x + (direction.x * speed - velocity.x) * (acceleration * delta)
	velocity.z = velocity.z + (direction.z * speed - velocity.z) * (acceleration * delta)
	global_position += velocity * transform.basis.inverse() * delta
	
	var dir = (velocity * transform.basis.inverse()).normalized()
	if !legs[0].is_moving && !legs[2].is_moving:
		legs[1].step(dir, delta)
		legs[3].step(dir, delta)
	if !legs[1].is_moving && !legs[3].is_moving:
		legs[0].step(dir, delta)
		legs[2].step(dir, delta)

	var avg_surface_dist = 0.0
	for leg in legs:
		avg_surface_dist += shape.to_local(leg.target.global_position).y
	avg_surface_dist /= legs.size()
	shape.translate_object_local(shape_offset + Vector3(0, avg_surface_dist, 0))
	
	var normal = (legs[0].target.global_position - legs[2].target.global_position).cross(legs[1].target.global_position - legs[3].target.global_position).normalized()
	transform.basis.y = normal
	transform.basis.x = -transform.basis.z.cross(normal)
	transform.basis = transform.basis.orthonormalized()

	for leg in legs:
		leg.home_ray.force_raycast_update()
		leg.overshoot_ray.force_raycast_update()
