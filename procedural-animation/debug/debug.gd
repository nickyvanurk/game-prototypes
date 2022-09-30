extends Node

@onready var mesh: ImmediateMesh = $Shapes.mesh

func _ready():
	set_process_priority(-1)

func _input(event):
	if event is InputEventKey:
		if event.is_action_pressed("toggle_debug"):
			get_tree().debug_collisions_hint = !get_tree().debug_collisions_hint
			mesh.clear_surfaces()
			get_viewport().debug_draw = Viewport.DEBUG_DRAW_DISABLED

		if get_tree().debug_collisions_hint:
			if event.is_action_pressed("toggle_viewport_mode"):
				# Viewport.DEBUG_DRAW_WIREFRAME = 4
				get_viewport().debug_draw ^= 1 << 2; # Toggle third bit (4)

func _process(delta):
	if !get_tree().debug_collisions_hint:
		return

	mesh.clear_surfaces()

func draw_line(points: Array, color: Color = Color.RED) -> void:
	if !get_tree().debug_collisions_hint:
		return

	if points == null || points.size() <= 1:
		return
		
	mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	mesh.surface_set_color(color)
	for p in points:
		mesh.surface_add_vertex(p)
	mesh.surface_end()

func draw_sphere(position: Vector3, color: Color = Color.RED, radius: float = 0.04) -> void:
	if !get_tree().debug_collisions_hint:
		return

	var step = 15
	var sppi = 2 * PI / step
	var axes = [
		[Vector3.UP, Vector3.RIGHT],
		[Vector3.RIGHT, Vector3.FORWARD],
		[Vector3.FORWARD, Vector3.UP]
	]
	mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	mesh.surface_set_color(color)
	for axis in axes:
		for i in range(step + 1):
			mesh.surface_add_vertex(position + (axis[0] * radius)
				.rotated(axis[1], sppi * (i % step)))
	mesh.surface_end()
