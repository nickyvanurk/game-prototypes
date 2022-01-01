extends Position3D

onready var upper = $Joint1
onready var middle = $Joint2
onready var lower = $Joint3

onready var player = get_node("/root/World/Player")

var len_upper = 0
var len_middle = 0
var len_lower = 0

func _ready():
	# change to correct length later
	len_upper = 1
	len_middle = 1
	len_lower = 1

func _physics_process(delta):
	var target = player.global_transform.origin
	
	lower.look_at(target, Vector3.UP)
	var distance = (target - lower.global_transform.origin).normalized() * len_lower
	lower.global_transform.origin = target - distance
	
	middle.look_at(lower.global_transform.origin, Vector3.UP)
	distance = (lower.global_transform.origin - middle.global_transform.origin).normalized() * len_middle
	middle.global_transform.origin = lower.global_transform.origin - distance
	
	upper.look_at(middle.global_transform.origin, Vector3.UP)
	distance = (middle.global_transform.origin - upper.global_transform.origin).normalized() * len_upper
	upper.global_transform.origin = middle.global_transform.origin - distance
