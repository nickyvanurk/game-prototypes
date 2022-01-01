extends Position3D

onready var player = get_node("/root/World/Player")

var bones = []

func _ready():
	for bone in get_children():
		bones.push_back(bone)

func _physics_process(delta):
	for i in range(bones.size() - 1, -1, -1):
		var bone = bones[i]
		var target = player if i == bones.size() - 1 else bones[i + 1]
		var direction = bone.global_transform.origin.direction_to(target.global_transform.origin)
		var distance = direction * bone.length
		bone.look_at(target.global_transform.origin, Vector3.UP)
		bone.global_transform.origin = target.global_transform.origin - distance
