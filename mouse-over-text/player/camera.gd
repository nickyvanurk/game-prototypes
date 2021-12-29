extends Camera

export var ray_length = 100

onready var pivot = get_parent().find_node("CameraPivot")
onready var mount = get_parent().find_node("CameraMount")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	set_as_toplevel(true)
	
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
func _process(delta):
	transform.origin = lerp(global_transform.origin, mount.global_transform.origin, 0.5)
	look_at(pivot.global_transform.origin, Vector3.UP)
	
