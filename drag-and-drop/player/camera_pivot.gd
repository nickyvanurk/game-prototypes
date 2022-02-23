extends Position3D

export(float, 0.1, 1) var mouse_sensitivity  = 0.3
export(float, -90, 0) var min_pitch = -90
export(float, 0, 90) var max_pitch = 90

onready var parent = get_parent()

func _input(event):
	if Input.is_action_pressed("rotate_camera") and event is InputEventMouseMotion:
		parent.rotation_degrees.y -= event.relative.x * mouse_sensitivity
		rotation_degrees.x -= event.relative.y * mouse_sensitivity
		rotation_degrees.x = clamp(rotation_degrees.x, min_pitch, max_pitch)
