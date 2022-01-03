extends Position3D

const CHAIN_MAX_ITER = 3

onready var bones = $Bones.get_children()
onready var target = get_node("/root/World/Player/CameraPivot")

var detect_range = 5
var depth = -3.5

func _ready():
	global_transform.origin.y = depth

func _physics_process(delta):
	if !bones || !target: return
	
	if global_transform.origin.distance_to(target.global_transform.origin) <= detect_range:
		solve()
		global_transform.origin.y = lerp(global_transform.origin.y, 0, 2 * delta)
	elif global_transform.origin.y != depth:
		global_transform.origin.y = lerp(global_transform.origin.y, depth, 0.2 * delta)

func solve():
	var base = bones[0].global_transform.origin
	
	for i in range(CHAIN_MAX_ITER):
		iterate_backward(target)
		iterate_forward(base)
		
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
	
	bones[0].global_transform.origin = base
	
	for i in range(1, size):
		var curr = bones[i]
		var prev = bones[i - 1]
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
