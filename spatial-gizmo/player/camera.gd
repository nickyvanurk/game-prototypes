extends Camera

onready var pivot = get_parent().find_node("CameraPivot")
onready var mount = get_parent().find_node("CameraMount")

func _ready():
	set_as_toplevel(true)
	
func _process(delta):
	transform.origin = lerp(global_transform.origin, mount.global_transform.origin, 0.5)
	look_at(pivot.global_transform.origin, Vector3.UP)

func handle_mouse_capture() -> void:
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
