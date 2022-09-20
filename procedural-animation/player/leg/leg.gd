extends Node3D


const CHAIN_MAX_ITER = 3

@onready var bones = [$Bone1, $Bone2, $Bone3]
@onready var target = $Target
@onready var pole = $Pole
@onready var home_ray = $HomeRay
@onready var overshoot_ray = $OvershootRay

@export var step_distance = 0.1
@export var step_duration = 0.2
@export var step_overshoot_fraction = 1.25

var is_moving = false
var time = 0.0
var start_point = Vector3()
var center_point = Vector3()
var end_point = Vector3()

func _process(delta):
	_solve()

func step(direction, speed_frac, delta):
	if !home_ray.is_colliding():
		return
	
	var home_position = home_ray.get_collision_point()
	var distance = target.global_position.distance_to(home_position)
	if distance > step_distance:
		if !is_moving:
			is_moving = true
			
			# TODO: Rework later. Find good solution to match movement to speed
			step_distance = speed_frac / 6
			
			start_point = target.global_position
			var overshoot_distance = step_distance * step_overshoot_fraction
			var overshoot_vector = direction * overshoot_distance
			var overshoot_ray_position = home_position + overshoot_vector
			overshoot_ray_position.y = overshoot_ray.global_position.y
			overshoot_ray.global_position = overshoot_ray_position
			end_point = overshoot_ray.get_collision_point()
			center_point = (start_point + end_point) / 2
			center_point += home_ray.get_collision_normal() * start_point.distance_to(end_point) / 2.0
	
	if is_moving:
		time += delta
		
		var normalized_time = time / step_duration
		# Quadratic bezier curve
		target.global_position = (
			start_point.lerp(center_point, normalized_time).lerp(
			center_point.lerp(end_point, normalized_time), normalized_time
		))

		if time >= step_duration:
			is_moving = false
			time = 0.0

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
