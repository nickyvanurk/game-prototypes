extends KinematicBody

onready var material = $MeshInstance.get_surface_material(0)

var original_color = null

func _ready():
	original_color = material.albedo_color

func _on_input_event(camera, event, position, normal, shape_idx):
	print(event)

func _on_mouse_entered():
	material.albedo_color = Color("#F7574F")

func _on_mouse_exited():
	material.albedo_color = original_color
