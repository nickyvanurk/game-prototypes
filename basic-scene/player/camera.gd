extends Camera3D

@onready var pivot = get_parent().find_child("CameraPivot")
@onready var mount = get_parent().find_child("CameraMount")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	set_as_top_level(true)
	
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		handle_mouse_capture()
		
func _process(delta):
	transform.origin = lerp(global_transform.origin, mount.global_transform.origin, 0.5)
	look_at(pivot.global_transform.origin, Vector3.UP)

func handle_mouse_capture() -> void:
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
