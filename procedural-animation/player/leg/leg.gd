extends Node3D

@export var step_distance = 0.1
@export var step_duration = 0.2
@export var overshoot_fraction = 1

@onready var target = $Target
@onready var ik = IK.new([$Bone1, $Bone2, $Bone3], target, $Pole)
@onready var home_ray = $HomeRay
@onready var overshoot_ray = $OvershootRay

var is_moving = false
var time = 0.0
var start_point = Vector3()
var center_point = Vector3()
var end_point = Vector3()

func _process(delta):
	ik.solve()
	
	Debug.draw_sphere(target.global_position, Color.BLUE, 0.02)
	
	var r = global_transform.basis.inverse()
	Debug.draw_line([home_ray.global_position, home_ray.global_position + home_ray.target_position * r])
	Debug.draw_line([overshoot_ray.global_position, overshoot_ray.global_position + overshoot_ray.target_position * r], Color.YELLOW)
	Debug.draw_sphere(home_ray.get_collision_point(), Color.RED, 0.02)
	Debug.draw_sphere(overshoot_ray.get_collision_point(), Color.YELLOW, 0.02)

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
