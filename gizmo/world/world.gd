extends Spatial

export(int) var ray_length = 1000

onready var camera = $Player/Camera
onready var my_gizmo = $Gizmo

var from = null
var to = null
var should_update = false
	
func _input(event):
	if event.is_action_pressed("select_object"):
		from = camera.project_ray_origin(event.position)
		to = from + camera.project_ray_normal(event.position) * ray_length
		should_update = true

func _physics_process(delta):
	if should_update:
		should_update = false

		var movables_result = get_world().direct_space_state.intersect_ray(from, to, [], pow(2, 3-1))
		var gizmo_result = get_world().direct_space_state.intersect_ray(from, to, [], pow(2, 16-1))
		
		if movables_result:
			my_gizmo.set_parent(movables_result.collider)
		elif !gizmo_result:
			my_gizmo.set_parent(null)
