class_name Chunk
extends MeshInstance3D


@export var height_scale = 100
@export var resolution = 64

var lods = [1, 4, 8, 16, 32, 64]


func _generate(height_map: Image, offset: Vector3, size: int):
	var scaled_size = size / resolution
	var scaled_half_size = scaled_size / 2
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	for z in scaled_size + 1:
		for x in scaled_size + 1:
			surface_tool.set_uv(Vector2(inverse_lerp(0, scaled_size, x * resolution), inverse_lerp(0, scaled_size, z * resolution)))
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
	
	position.x = offset.x * size
	position.z = offset.z * size	


func _update_lod(viewer_pos: Vector3):
	var distance = position.distance_to(viewer_pos)
	var lod = lods[5]
	if distance > 500:
		lod = lods[5];
	elif distance > 400:
		lod = lods[4]
	elif distance > 300:
		lod = lods[3]
	elif distance > 200:
		lod = lods[2]
	elif distance > 100:
		lod = lods[1]
	else:
		lod = lods[0]
		
	if resolution != lod:
		resolution = lod
		return true

	return false


func _update_shader():
	get_active_material(0).set_shader_parameter("min_height", -0.5 * height_scale)
	get_active_material(0).set_shader_parameter("max_height", 0.5 * height_scale)
