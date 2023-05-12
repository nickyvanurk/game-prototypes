@tool
extends MeshInstance3D


@export var generate = false
@export var seed = 21
@export var size = 128
@export var height_scale = 100
@export var resolution = 1.0

var map_generator = MapGenerator.new()


func _ready():
	map_generator.seed = seed
	map_generator.chunk_size = size
	var height_map = map_generator._generate_height_map()
	_generate_terrain(height_map)


func _process(delta):
	if generate:
		map_generator.seed = seed
		map_generator.chunk_size = size
		var height_map = map_generator._generate_height_map()
		_generate_terrain(height_map)
		generate = false


func _generate_terrain(height_map: Image):
	var scaled_size = size / resolution
	var scaled_half_size = scaled_size / 2
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	for z in scaled_size + 1:
		for x in scaled_size + 1:
			surface_tool.set_uv(Vector2(inverse_lerp(0, scaled_size, x), inverse_lerp(0, scaled_size, z)))
			var y = height_map.get_pixel(x * resolution, z * resolution).r
			surface_tool.add_vertex(Vector3(-scaled_half_size * resolution + x * resolution, (y - 0.5) * height_scale, -scaled_half_size * resolution + z * resolution))
	
	var vert_idx = 0
	for z in scaled_size:
		for x in scaled_size:
			surface_tool.add_index(vert_idx + 0)
			surface_tool.add_index(vert_idx + 1)
			surface_tool.add_index(vert_idx + scaled_size + 1)
			surface_tool.add_index(vert_idx + scaled_size + 1)
			surface_tool.add_index(vert_idx + 1)
			surface_tool.add_index(vert_idx + scaled_size + 2)
			vert_idx += 1
		vert_idx += 1
	
	surface_tool.generate_normals()
	mesh = surface_tool.commit()
	_update_shader()


func _update_shader():
	get_active_material(0).set_shader_parameter("min_height", -0.5 * height_scale)
	get_active_material(0).set_shader_parameter("max_height", 0.0 * height_scale)
