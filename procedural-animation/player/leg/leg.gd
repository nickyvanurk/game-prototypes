@tool
extends Node3D


const CHAIN_MAX_ITER = 3
const STEP_DISTANCE = 0.1
const STEP_HEIGHT = 0.4

@onready var bones = [$Bone1, $Bone2, $Bone3]
@onready var target = $Target
@onready var pole = $Pole
@onready var ray = $Ray

var time = 0.0

@onready var destination = $Target.global_transform.origin
@onready var origin = $Target.global_transform.origin

func _process(delta):
	time += delta * 5

	if time <= 1.0:
		var mid_point = (origin + destination) / 2
		mid_point.y += STEP_HEIGHT
		target.global_transform.origin = origin.bezier_interpolate(mid_point, mid_point, destination, time)
	elif origin != destination:
		origin = destination
	
	_solve()

func move_to_position(position: Vector3):
	if origin == destination:
		destination = position
		origin = target.global_transform.origin
		time = 0.0
	
func is_moving():
	return time < 1.0

func should_step():
	if ray.is_colliding():
		var distance = target.global_transform.origin.distance_to(ray.get_collision_point())
		if distance >= STEP_DISTANCE:
			return true
	return false

func step(direction, distance, time):
	var dest = ray.get_collision_point() + direction.normalized() * STEP_DISTANCE
	move_to_position(dest)

func _solve():
	if bones.size() > 2:
		for idx in range(1, bones.size()):
			var pole_pos = pole.global_transform.origin
			var pole_pos_diff = pole_pos - bones[idx].global_transform.origin
			bones[idx].global_transform.origin += pole_pos_diff

	var base = bones[0].global_transform.origin

	for i in range(CHAIN_MAX_ITER):
		_iterate_backward(target)
		_iterate_forward(base)
		_apply_rotation()

func _iterate_backward(target):
	var size = bones.size()
	if size < 2: return
	
	for i in range(size - 1, -1, -1):
		var curr = target if i == size - 1 else bones[i + 1]
		var prev = bones[i]
		var direction = prev.global_transform.origin.direction_to(curr.global_transform.origin)
		var offset = direction * prev.length
		prev.global_transform.origin = curr.global_transform.origin - offset

func _iterate_forward(base):
	var size = bones.size()
	if size < 2: return
	
	bones[0].global_transform.origin = base
	
	for i in range(1, size):
		var curr = bones[i]
		var prev = bones[i - 1]
		var direction = prev.global_transform.origin.direction_to(curr.global_transform.origin)
		var offset = direction * prev.length
		curr.global_transform.origin = prev.global_transform.origin + offset

func _apply_rotation():
	var size = bones.size()
	if size < 2: return
	
	for i in range(size - 1, -1, -1):
		var curr = target if i == size - 1 else bones[i + 1]
		var prev = bones[i]
		var direction = prev.global_transform.origin.direction_to(curr.global_transform.origin)
		var offset = direction * prev.length
		prev.look_at(curr.global_transform.origin, Vector3.UP)
