extends Spatial

var parent = null
var is_dragging = false

var offset = Vector3()
var origin = Vector3()

func set_parent(obj):
	parent = obj
	if parent != null:
		global_transform.origin = parent.global_transform.origin

func _physics_process(delta):
	visible = parent != null

func _on_x_input_event(camera, event, position, normal, shape_idx):
	if event.is_action_pressed("select_object"):
		origin = global_transform.origin

	var yd = get_dot(Vector3(0, 1, 0), camera)
	var p = Plane(0, 1, 0, origin.y) if abs(yd) > 0.1 else Plane(0, 0, 1, origin.z)

	move_on_axis(camera, event, position, "x", p)

func _on_y_input_event(camera, event, position, normal, shape_idx):
	if event.is_action_pressed("select_object"):
		origin = global_transform.origin

	var zd = get_dot(Vector3(0, 0, 1), camera)
	var p = Plane(0, 0, 1, origin.z) if abs(zd) > 0.1 else Plane(1, 0, 0, origin.x)

	move_on_axis(camera, event, position, "y", p)

func _on_z_input_event(camera, event, position, normal, shape_idx):
	if event.is_action_pressed("select_object"):
		origin = global_transform.origin

	var xd = get_dot(Vector3(1, 0, 0), camera)
	var p = Plane(1, 0, 0, origin.x) if abs(xd) > 0.1 else Plane(0, 1, 0, origin.y)

	move_on_axis(camera, event, position, "z", p)

func move_on_axis(camera, event, raycast_hit_position, axis, plane):
	if event.is_action_pressed("select_object"):
		is_dragging = true

	if event.is_action_released("select_object"):
		is_dragging = false
		origin = Vector3()
		offset = Vector3()

	if parent == null: return
	var shape = parent.get_node("CollisionShape")
	if shape: shape.disabled = is_dragging

	if is_dragging:
		plane.intersects_ray(camera.global_transform.origin, camera.project_ray_normal(event.position))
		var result = plane.intersects_ray(camera.global_transform.origin, camera.project_ray_normal(event.position))

		if result:
			if offset == Vector3.ZERO:
				offset = ((global_transform.origin - result))
			global_transform.origin[axis] = (result + offset)[axis]
			parent.global_transform.origin = global_transform.origin

func get_dot(n, camera):
	return n.dot(global_transform.origin.direction_to(camera.global_transform.origin))
