extends Node3D

@export var step_distance = 0.1
@export var step_duration = 0.2
@export var overshoot_fraction = 1

@onready var target = $Target
@onready var home_ray = $HomeRay
@onready var overshoot_ray = $OvershootRay

var is_moving = false
var time = 0.0
var start_point = Vector3()
var center_point = Vector3()
var end_point = Vector3()


func _process(delta):
	$Socket.rotation.y = atan2(-target.global_position.z, target.global_position.x) - PI/2
	
	var d = $Socket.to_local(target.global_position)
	var p = solve(Vector2(-d.z, d.y), $Bone1.length, $Bone1/Bone2.length)
	
	$Socket/Joint.position.z = -p.x
	$Socket/Joint.position.y = p.y
	
	$Bone1.look_at($Socket/Joint.global_position)
	$Bone1/Bone2.look_at(target.global_position)


func solve(p: Vector2, r1: float, r2: float) -> Vector2:
	var h = p.dot(p)
	var w = h + r1*r1 - r2*r2
	var s = max(4.0*r1*r1*h - w*w,0.0)
	return (w*p + Vector2(-p.y,p.x)*sqrt(s)) * 0.5/h


func step(direction, delta):
	if !home_ray.is_colliding():
		return
	
	var home_position = home_ray.get_collision_point()
	var distance = target.global_position.distance_to(home_position)
	if distance > step_distance * overshoot_fraction:
		if !is_moving:
			is_moving = true

	if is_moving:
		time += delta
		
		start_point = target.global_position
		overshoot_ray.global_position = home_ray.global_position + direction * step_distance * overshoot_fraction
		end_point = overshoot_ray.get_collision_point()
		center_point = (start_point + end_point) / 2
		center_point += home_ray.get_collision_normal() * start_point.distance_to(end_point) / 2.0
		
		var normalized_time = time / step_duration
		# Quadratic bezier curve
		target.global_position = (
			start_point.lerp(center_point, normalized_time).lerp(
			center_point.lerp(end_point, normalized_time), normalized_time
		))

		if time >= step_duration:
			is_moving = false
			time = 0.0
