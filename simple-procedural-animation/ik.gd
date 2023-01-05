class_name IK
extends Node

const CHAIN_MAX_ITER = 3

var bones
var target
var pole

func _init(_bones: Array, _target: Node3D, _pole: Node3D):
	bones = _bones
	target = _target
	pole = _pole

func solve():
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
