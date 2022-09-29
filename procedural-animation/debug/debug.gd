extends Node

@onready var mesh: ImmediateMesh = $Shapes.mesh

var shapes = []

func _ready():
	set_process_priority(-1)

func _input(event):
	if event is InputEventKey:
		if event.is_action_pressed("toggle_debug"):
			get_tree().debug_collisions_hint = !get_tree().debug_collisions_hint
			clear()
			get_tree().reload_current_scene()
		
		if get_tree().debug_collisions_hint:
			if event.is_action_pressed("toggle_viewport_mode"):
				get_viewport().debug_draw += 4 # Viewport.DEBUG_DRAW_WIREFRAME = 4
				get_viewport().debug_draw %= 5 # 4, 3, 2, 1, 0 -> repeat

func _process(delta):
	if !get_tree().debug_collisions_hint:
		return

	clear()

func create_line(points: Array) -> void:
	if !get_tree().debug_collisions_hint:
		return

	if points == null || points.size() <= 1:
		return
	
	mesh.clear_surfaces()
	mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	
	for p in points:
		mesh.surface_add_vertex(p)
	
	mesh.surface_end()

func create_sphere(position: Vector3, color: Color = Color.RED, radius: float = 0.03) -> void:
	if !get_tree().debug_collisions_hint:
		return

	# So we can see the target in the editor, let's create a mesh instance,
	# Add it as our child, and name it
	var indicator = MeshInstance3D.new()
	add_child(indicator)
	indicator.global_position = position

	var indicator_mesh = SphereMesh.new()
	indicator_mesh.radius = radius
	indicator_mesh.height = radius * 2
	indicator_mesh.radial_segments = 8
	indicator_mesh.rings = 4

	# The mesh needs a material (unless we want to use the defualt one).
	# Let's create a material and use the EditorGizmoTexture to texture it.
	var indicator_material = StandardMaterial3D.new()
	indicator_material.flags_unshaded = true
#	indicator_material.albedo_texture = preload("editor_gizmo_texture.png")
	indicator_material.albedo_color = color
	indicator_mesh.material = indicator_material
	indicator.mesh = indicator_mesh
	shapes.append(indicator)

func clear():
	for shape in shapes:
		shape.queue_free()
	shapes.clear()
