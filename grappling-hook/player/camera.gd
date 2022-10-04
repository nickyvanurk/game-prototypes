extends Camera3D

@onready var pivot = get_parent().find_child("CameraPivot")
@onready var mount = get_parent().find_child("CameraMount")

func _ready():
	set_as_top_level(true)

func _process(delta):
	transform.origin = mount.global_transform.origin
	look_at(pivot.global_transform.origin, Vector3.UP)
