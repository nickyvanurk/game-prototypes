tool
extends Position3D

const CHAIN_MAX_ITER = 10
const CHAIN_TOLERANCE = 0.01

onready var bones = $Bones.get_children()

var chain_origin = Vector3()
var target = null

func _ready():
	target = get_or_create_target()
	
	if Engine.editor_hint:
		make_editor_sphere_at_node(target, Color.magenta)
			
func _physics_process(delta):
	pass



#	solve_chain()
#
#func solve_chain():
#	# Update the origin with the first bone's origin
#	chain_origin = bones[0].global_transform.origin
#
#	# Get the direction of the final bone.
#	var last_bone = bones[bones.size() - 1]
#	var last_bone_dir = last_bone.global_transform.basis.z.normalized()
#
#	# Get the target position (accounting for the final bone and it's length)
#	var target_pos = target.global_transform.origin + (last_bone_dir * last_bone.length)
#
#	# Get the difference between our end effector (the final bone in the chain) and the target
##	var dif = (last_bone.global_transform.origin - target_pos).length()
#	var dif = (bones[bones.size()-1].global_transform.origin - target_pos).length()
#	var chain_iterations = 0
#
#	if dif > CHAIN_TOLERANCE:
#		# If we have more than 2 bones, move our middle joint towards it!
#		if bones.size() > 2:
#			var middle_point_pos = middle_joint_target.global_transform.origin
#			var middle_point_pos_diff = (middle_point_pos - bones[1].global_transform.origin)
#			bones[1].global_transform.origin += middle_point_pos_diff.normalized()
#			middle_point_pos_diff = (middle_point_pos - bones[2].global_transform.origin)
#			bones[2].global_transform.origin += middle_point_pos_diff.normalized()
#
#	while dif > CHAIN_TOLERANCE:
#		chain_backward()
#		chain_forward()
#		chain_apply_rotation()
#
#		# Update the difference between our end effector (the final bone in the chain) and the target
#		dif = (bones[bones.size()-1].global_transform.origin - target_pos).length()
#
#		# Add one to chain_iterations. If we have reached our max iterations, then break
#		chain_iterations = chain_iterations + 1
#		if chain_iterations >= CHAIN_MAX_ITER:
#			break
#
#func chain_backward():
#	var last_bone = bones[bones.size() - 1]
#	var last_bone_dir = last_bone.global_transform.basis.z.normalized()
#
#	# Set the position of the end effector (the final bone in the chain) to the target position
#	last_bone.global_transform.origin = target.global_transform.origin + (last_bone_dir * last_bone.length)
#
#	# For all of the other bones, move them towards the target
#	var i = bones.size() - 1
#	while i >= 1:
#		var prev_origin = bones[i].global_transform.origin
#		i -= 1
#		var curr_origin = bones[i].global_transform.origin
#		var distance = curr_origin.distance_to(prev_origin)
#		if distance:
#			var l = bones[i].length / distance
#			# Apply the new joint position
#			bones[i].global_transform.origin = prev_origin.linear_interpolate(curr_origin, l)
#
#func chain_forward():
#	# Set root at initial position
#	bones[0].global_transform.origin = chain_origin
#
#	# Go through every bone in the bone chain
#	for i in range(bones.size() - 1):
#		var curr_origin = bones[i].global_transform.origin
#		var next_origin = bones[i + 1].global_transform.origin
#
#		var distance = curr_origin.distance_to(next_origin)
#		if distance:
#			var l = bones[i].length / distance
#			# Apply the new joint position, (potentially with constraints), to the bone node
#			bones[i + 1].global_transform.origin = curr_origin.linear_interpolate(next_origin, l)
#
#func chain_apply_rotation():
#	for i in range(bones.size() - 1, -1, -1):
#		var bone = bones[i]
#		var tar = target if i == bones.size() - 1 else bones[i + 1]
#		var direction = bone.global_transform.origin.direction_to(tar.global_transform.origin)
#		var distance = direction * bone.length
#		bone.look_at(tar.global_transform.origin, Vector3.UP)

func get_or_create_target():
	if not has_node("Target"):
		var target = Position3D.new()
		add_child(target)

		if Engine.editor_hint:
			if get_tree() != null:
				if get_tree().edited_scene_root != null:
					target.set_owner(get_tree().edited_scene_root)

		target.name = "Target"
		return target
	else:
		return $Target

func make_editor_sphere_at_node(node, color):
	var indicator = MeshInstance.new()
	node.add_child(indicator)
	indicator.name = "(EditorOnly) Visual indicator"

	var indicator_mesh = SphereMesh.new()
	indicator_mesh.radius = 0.1
	indicator_mesh.height = 0.2
	indicator_mesh.radial_segments = 8
	indicator_mesh.rings = 4
	
	var indicator_material = SpatialMaterial.new()
	indicator_material.flags_unshaded = true
	indicator_material.albedo_color = color
	indicator_mesh.material = indicator_material
	indicator.mesh = indicator_mesh
