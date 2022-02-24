extends Spatial

export(NodePath) var parent_path

var parent = null
var is_dragging = false

var offset = Vector3()
var origin = Vector3()

func _ready():
	parent = get_node(parent_path)
	if parent: global_transform.origin = parent.global_transform.origin

func _physics_process(delta):
	var new_parent = get_node(parent_path)
	visible = new_parent != null
	if parent != new_parent:
		global_transform.origin = parent.global_transform.origin
	parent = new_parent
		
func _on_x_input_event(camera, event, position, normal, shape_idx):
	move_on_axis(camera, event, position, "x")

func _on_y_input_event(camera, event, position, normal, shape_idx):
	move_on_axis(camera, event, position, "y")

func _on_z_input_event(camera, event, position, normal, shape_idx):
	move_on_axis(camera, event, position, "z")

func move_on_axis(camera, event, raycast_hit_position, axis):
	if event.is_action_pressed("select_object"):
		is_dragging = true
		origin = global_transform.origin
		
	if event.is_action_released("select_object"):
		is_dragging = false
		origin = Vector3()
		offset = Vector3()
		
	if is_dragging:
		# TODO: use different planes depending on the camera angle. Dot product.
		var p = Plane(0, 1, 0, origin.y) if axis == "x" else Plane(0, 0, 1, origin.z)  if axis == "y" else Plane(1, 0, 0, origin.x)
		p.intersects_ray(camera.global_transform.origin, camera.project_ray_normal(event.position))
		var result = p.intersects_ray(camera.global_transform.origin, camera.project_ray_normal(event.position))
		
		if result:
			if offset == Vector3.ZERO:
				offset = ((global_transform.origin - result))
			global_transform.origin[axis] = (result + offset)[axis]
			parent.global_transform.origin = global_transform.origin
