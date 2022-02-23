extends KinematicBody

onready var material = $MeshInstance.get_surface_material(0)

var original_color = null
var is_dragging = false

func _ready():
	original_color = material.albedo_color

func _on_input_event(camera, event, position, normal, shape_idx):
	if event.is_action_pressed("select_object"):
		material.albedo_color = Color("#F7574F")
		is_dragging = true
	
	if event.is_action_released("select_object"):
		material.albedo_color = original_color
		is_dragging = false
	
	if is_dragging:
		var ray_from = camera.global_transform.origin
		var ray_dir = camera.project_ray_normal(event.position)
		var ray_to = ray_from + ray_dir * ray_from.distance_to(global_transform.origin)
		
		global_transform.origin.x = ray_to.x
		global_transform.origin.z = ray_to.z
