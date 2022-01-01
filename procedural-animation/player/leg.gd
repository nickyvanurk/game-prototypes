extends Position3D

# The delta/tolerance for the bone chain (how do the bones need to be before it is considered satisfactory)
const CHAIN_TOLERANCE = 0.01
# The amount of interations the bone chain will go through in an attempt to get to the target position
const CHAIN_MAX_ITER = 10

onready var bones = $Bones
onready var player = get_node("/root/World/Player")

var chain_origin = Vector3()
var target = null
var middle_joint_target = null

func _ready():
	if target == null:
		# NOTE: You MUST have a node called Target as a child of this node!
		# So we create one if one doesn't already exist.
		if not has_node("Target"):
			target = Position3D.new()
			add_child(target)

			if Engine.editor_hint:
				if get_tree() != null:
					if get_tree().edited_scene_root != null:
						target.set_owner(get_tree().edited_scene_root)

			target.name = "Target"
		else:
			target = $Target
	if middle_joint_target == null:
		if not has_node("MiddleJoint"):
			middle_joint_target = Position3D.new()
			add_child(middle_joint_target)

			middle_joint_target.name = "MiddleJoint"
		else:
			middle_joint_target = $MiddleJoint
			
	bones = bones.get_children()

func _physics_process(delta):
	target = player
	
	solve_chain()


func solve_chain():
	# Update the origin with the first bone's origin
	chain_origin = bones[0].global_transform.origin
	
	# Get the direction of the final bone.
	var last_bone = bones[bones.size() - 1]
	var last_bone_dir = last_bone.global_transform.basis.z.normalized()
	
	# Get the target position (accounting for the final bone and it's length)
	var target_pos = target.global_transform.origin + (last_bone_dir * last_bone.length)
	
	# Get the difference between our end effector (the final bone in the chain) and the target
#	var dif = (last_bone.global_transform.origin - target_pos).length()
	var dif = (bones[bones.size()-1].global_transform.origin - target_pos).length()
	var chain_iterations = 0
	
	if dif > CHAIN_TOLERANCE:
		# If we have more than 2 bones, move our middle joint towards it!
		if bones.size() > 2:
			var middle_point_pos = middle_joint_target.global_transform.origin
			var middle_point_pos_diff = (middle_point_pos - bones[bones.size() / 2].global_transform.origin)
			bones[bones.size() / 2].global_transform.origin += middle_point_pos_diff.normalized()
		
	while dif > CHAIN_TOLERANCE:
		chain_backward()
		chain_forward()
		chain_apply_rotation()

		# Update the difference between our end effector (the final bone in the chain) and the target
		dif = (bones[bones.size()-1].global_transform.origin - target_pos).length()

		# Add one to chain_iterations. If we have reached our max iterations, then break
		chain_iterations = chain_iterations + 1
		if chain_iterations >= CHAIN_MAX_ITER:
			break
	
func chain_backward():
	var last_bone = bones[bones.size() - 1]
	var last_bone_dir = last_bone.global_transform.basis.z.normalized()

	# Set the position of the end effector (the final bone in the chain) to the target position
	last_bone.global_transform.origin = target.global_transform.origin + (last_bone_dir * last_bone.length)

	# For all of the other bones, move them towards the target
	var i = bones.size() - 1
	while i >= 1:
		var prev_origin = bones[i].global_transform.origin
		i -= 1
		var curr_origin = bones[i].global_transform.origin
		var distance = curr_origin.distance_to(prev_origin)
		if distance:
			var l = bones[i].length / distance
			# Apply the new joint position
			bones[i].global_transform.origin = prev_origin.linear_interpolate(curr_origin, l)
			
func chain_forward():
	# Set root at initial position
	bones[0].global_transform.origin = chain_origin

	# Go through every bone in the bone chain
	for i in range(bones.size() - 1):
		var curr_origin = bones[i].global_transform.origin
		var next_origin = bones[i + 1].global_transform.origin

		var distance = curr_origin.distance_to(next_origin)
		if distance:
			var l = bones[i].length / distance
			# Apply the new joint position, (potentially with constraints), to the bone node
			bones[i + 1].global_transform.origin = curr_origin.linear_interpolate(next_origin, l)

func chain_apply_rotation():
	for i in range(bones.size() - 1, -1, -1):
		var bone = bones[i]
		var tar = target if i == bones.size() - 1 else bones[i + 1]
		var direction = bone.global_transform.origin.direction_to(tar.global_transform.origin)
		var distance = direction * bone.length
		bone.look_at(tar.global_transform.origin, Vector3.UP)
