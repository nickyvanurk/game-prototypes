extends Marker3D

@export var mouse_sensitivity  = 0.3 # (float, 0.1, 1)
@export var min_pitch = -90 # (float, -90, 0)
@export var max_pitch = 90 # (float, 0, 90)

@onready var parent = get_parent()

func _input(event):	
	pass
#	if event is InputEventMouseMotion:
#		parent.rotation_degrees.y -= event.relative.x * mouse_sensitivity
#		rotation_degrees.x -= event.relative.y * mouse_sensitivity
#		rotation_degrees.x = clamp(rotation_degrees.x, min_pitch, max_pitch)
