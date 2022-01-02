tool
extends Position3D

const CHAIN_MAX_ITER = 3

onready var bones = $Bones.get_children()

var target = null

func _ready():
	target = get_or_create_target()
	
	if Engine.editor_hint:
		make_editor_sphere_at_node(target, Color.magenta)
			
func _physics_process(delta):
	if !bones: return
	
	solve()

func solve():
	var base = bones[0].global_transform.origin
	
	for i in range(CHAIN_MAX_ITER):
		iterate_backward(target)
		iterate_forward(base)
	
#		for j in range(bones.size()):
#			apply_ball_socket_constraint(j, deg2rad(90))

	apply_rotation()

func iterate_backward(target):
	var size = bones.size()
	if size < 2: return
	
	for i in range(size - 1, -1, -1):
		var curr = target if i == size - 1 else bones[i + 1]
		var prev = bones[i]
		var direction = prev.global_transform.origin.direction_to(curr.global_transform.origin)
		var offset = direction * prev.length
		prev.global_transform.origin = curr.global_transform.origin - offset

func iterate_forward(base):
	var size = bones.size()
	if size < 2: return
	
	for i in range(1, size):
		var curr = bones[i]
		var prev = base if i == 0 else bones[i - 1]
		var direction = prev.global_transform.origin.direction_to(curr.global_transform.origin)
		var offset = direction * prev.length
		curr.global_transform.origin = prev.global_transform.origin + offset

func apply_rotation():
	var size = bones.size()
	if size < 2: return
	
	for i in range(size - 1, -1, -1):
		var curr = target if i == size - 1 else bones[i + 1]
		var prev = bones[i]
		var direction = prev.global_transform.origin.direction_to(curr.global_transform.origin)
		var offset = direction * prev.length
		prev.look_at(curr.global_transform.origin, Vector3.UP)

#func apply_ball_socket_constraint(idx, limit):
#	var parentForward = get_parent().global_transform.basis.z if idx == 0 else bones[idx - 1].global_transform.basis.z
#	var thisForward = bones[idx].global_transform.basis.z
#	var angle = parentForward.angle_to(thisForward)
#
#	if angle > limit:
#		var axis = parentForward.cross(thisForward).normalized()
#		bones[idx].global_transform.basis = (get_parent().global_transform.rotated(axis, limit) * get_parent().global_transform.inverse()).basis
#
	
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
