@tool
@icon("res://icons/quad_tree.svg")
extends Node3D
class_name QuadTree


@export_range(0, 1000000, 1) var lod_level := 2
@export_range(1.0, 65535.0) var quad_size := 1024.0
@export_range(0.0, 1.0, 0.001) var morph_range := 0.15
@export_range(0, 32000, 1) var mesh_vertex_resolution := 256
@export var ranges := [50.0, 100.0, 200.0]
@export var material: ShaderMaterial

@onready var mesh_instance := $MeshInstance3D
@onready var _visibility_detector := $VisibleOnScreenNotifier3D
@onready var subquad_node = $SubQuads
	
var Quad

var is_root := true
var cull_box: AABB
var lod_meshes: Array[PlaneMesh] = []
var _subquads: Array[QuadTree] = []

func _ready() -> void:
	if is_root:
		Quad = load("res://quad_tree.tscn")
		
		var camera := get_viewport().get_camera_3d()
		material.set_shader_parameter("view_distance_max", camera.far)
		material.set_shader_parameter("vertex_resolution", mesh_vertex_resolution)

		mesh_instance = MeshInstance3D.new()
		subquad_node = Node3D.new()
		_visibility_detector = VisibleOnScreenNotifier3D.new()

		add_child(mesh_instance)
		add_child(_visibility_detector)
		add_child(subquad_node)
		
		var current_size = quad_size
		
		for i in lod_level + 1:
			var mesh = PlaneMesh.new()
			mesh.size = Vector2.ONE * current_size
			mesh.subdivide_depth = mesh_vertex_resolution - 1
			mesh.subdivide_width = mesh.subdivide_depth
			
			lod_meshes.insert(0, mesh)
			current_size *= 0.5
	
	mesh_instance.visible = false
	mesh_instance.mesh = lod_meshes[lod_level]
	mesh_instance.material_override = material
	mesh_instance.set_instance_shader_parameter("patch_size", quad_size)
	mesh_instance.set_instance_shader_parameter("min_lod_morph_distance", ranges[lod_level] * 2 * (1.0 - morph_range))
	mesh_instance.set_instance_shader_parameter("max_lod_morph_distance", ranges[lod_level] * 2)
	
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
			new_quad.material = material
			
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
