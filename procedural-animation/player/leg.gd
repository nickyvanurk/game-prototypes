extends Position3D

onready var player = get_node("/root/World/Player")

var segments = []

func _ready():
	for segment in get_children():
		segments.push_back(segment)

func _physics_process(delta):
	for i in range(segments.size() - 1, -1, -1):
		var segment = segments[i]
		var target = player if i == segments.size() - 1 else segments[i + 1]
		var distance = (target.global_transform.origin - segment.global_transform.origin).normalized() * segment.length
		segment.look_at(target.global_transform.origin, Vector3.UP)
		segment.global_transform.origin = target.global_transform.origin - distance
