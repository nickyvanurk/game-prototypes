extends Marker3D

@export var mouse_sensitivity  = 0.3 # (float, 0.1, 1)
@export var min_pitch = -89 # (float, -89, 0)
@export var max_pitch = 89 # (float, 0, 89)

@onready var parent = get_parent()

func _input(event):
	if event is InputEventMouseMotion:
		parent.rotation.y -= deg_to_rad(event.relative.x * mouse_sensitivity)
		rotation.x -= deg_to_rad(event.relative.y * mouse_sensitivity)
		rotation.x = clampf(rotation.x, deg_to_rad(min_pitch), deg_to_rad(max_pitch))
