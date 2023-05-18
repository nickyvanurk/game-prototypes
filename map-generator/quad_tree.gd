@tool
@icon("res://icons/quad_tree.svg")
extends Node3D
class_name QuadTree


@export_range(0, 1000000, 1) var lod_level := 5
@export_range(1.0, 65535.0) var quad_size := 2048.0
@export_range(0, 32000, 1) var subdivisions := 32.0
@export var ranges := [20.0, 60.0, 100.0, 140.0, 180, 220.0]

@onready var mesh_instance := $MeshInstance3D
@onready var _visibility_detector := $VisibleOnScreenNotifier3D
@onready var subquad_node = $SubQuads

var Quad

var is_root := true
var cull_box: AABB
var lod_meshes: Array[ArrayMesh] = []
var _subquads: Array[QuadTree] = []


func _ready() -> void:
	if is_root:
		Quad = load("res://quad_tree.tscn")

		mesh_instance = MeshInstance3D.new()
		subquad_node = Node3D.new()
		_visibility_detector = VisibleOnScreenNotifier3D.new()

		add_child(mesh_instance)
		add_child(_visibility_detector)
		add_child(subquad_node)

		var current_size = quad_size

		for i in lod_level + 1:
			var tile_size = current_size / subdivisions
			var half_size = current_size / 2.0

			var st = SurfaceTool.new()
			st.begin(Mesh.PRIMITIVE_TRIANGLES)

			var thisrow = 0
			var prevrow = 0
			var point = 0

			for z in subdivisions + 1:
				for x in subdivisions + 1:
					st.set_uv(Vector2(inverse_lerp(0, subdivisions + 1, x), inverse_lerp(0, subdivisions + 1, z)))
					st.add_vertex(Vector3(-half_size + x * tile_size, 0, -half_size + z * tile_size))
					point += 1

					if z > 0 and x > 0:
						st.add_index(prevrow + x - 1)
						st.add_index(prevrow + x)
						st.add_index(thisrow + x - 1)
						st.add_index(prevrow + x)
						st.add_index(thisrow + x)
						st.add_index(thisrow + x - 1)

				prevrow = thisrow
				thisrow = point

			st.generate_normals()
			st.generate_tangents()

			lod_meshes.insert(0, st.commit())
			current_size *= 0.5

	mesh_instance.visible = false
	mesh_instance.mesh = lod_meshes[lod_level]

	_visibility_detector.aabb = AABB(Vector3(-quad_size * 0.75, -quad_size * 0.5, -quad_size * 0.75),
		Vector3(quad_size * 1.5, quad_size, quad_size * 1.5))
	mesh_instance.custom_aabb = _visibility_detector.aabb
	cull_box = AABB(global_position + Vector3(-quad_size * 0.5, -10, -quad_size * 0.5),
		Vector3(quad_size, 20, quad_size))

	var offset_length = quad_size * 0.25

	if lod_level > 0:
		for offset in [Vector3(1, 0, 1), Vector3(-1, 0, 1), Vector3(1, 0, -1), Vector3(-1, 0, -1)]:
			var new_quad: QuadTree = Quad.instantiate()
			new_quad.lod_level = lod_level - 1
			new_quad.quad_size = quad_size * 0.5
			new_quad.ranges = ranges
			new_quad.process_mode = PROCESS_MODE_DISABLED
			new_quad.position = offset * offset_length
			new_quad.Quad = Quad
			new_quad.lod_meshes = lod_meshes
			new_quad.is_root = false

			subquad_node.add_child(new_quad)
			_subquads.append(new_quad)


func _process(_delta: float) -> void:
	if Engine.get_frames_drawn() % 2:
		var camera := get_viewport().get_camera_3d()
		lod_select(camera.global_position)


func lod_select(cam_pos: Vector3) -> bool:
	if not within_sphere(cam_pos, ranges[lod_level]):
		reset_visibility()

		if is_root:
			mesh_instance.visible = true

		return false

	if not _visibility_detector.is_on_screen():
		mesh_instance.visible = false
		return true

	if lod_level == 0:
		mesh_instance.visible = true
		return true
	else:
		if not within_sphere(cam_pos, ranges[lod_level - 1]):
			reset_visibility()

			for subquad in _subquads:
				subquad.mesh_instance.visible = true
		else:
			for subquad in _subquads:
				if not subquad.lod_select(cam_pos):
					subquad.mesh_instance.visible = true

		return true


func reset_visibility() -> void:
	if mesh_instance.visible:
		mesh_instance.visible = false
	else:
		for subquad in _subquads:
			subquad.reset_visibility()


func within_sphere(center: Vector3, radius: float) -> bool:
	var radius_squared := radius * radius
	var dmin := 0.0

	for i in 3:
		if center[i] < cull_box.position[i]:
			dmin += pow(center[i] - cull_box.position[i], 2.0)
		elif center[i] > cull_box.end[i]:
			dmin += pow(center[i] - cull_box.end[i], 2.0)

	return dmin <= radius_squared
