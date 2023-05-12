@tool
extends MeshInstance3D


@export var generate = false
@export var size = 128
@export var height_scale = 50


func _ready():
	_generate()


func _process(delta):
	if generate:
		_generate()
		generate = false


func _generate():
	var n = FastNoiseLite.new()
	n.noise_type = FastNoiseLite.TYPE_SIMPLEX
	n.seed = 21
	n.frequency = 0.002
	n.fractal_octaves = 6
	n.fractal_gain = 0.5
	n.fractal_lacunarity = 2.0
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var half_size = size / 2
	var thisrow = 0
	var prevrow = 0
	var point = 0
	
	for z in size:
		for x in size:
			st.set_uv(Vector2(inverse_lerp(0, size, x), inverse_lerp(0, size, z)))
			st.add_vertex(Vector3(-half_size + x, n.get_noise_2d(x, z) * height_scale, -half_size + z))
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
	
	mesh = st.commit()
	
	_update_shader()


func _update_shader():
	get_active_material(0).set_shader_parameter("min_height", -1.0 * height_scale)
	get_active_material(0).set_shader_parameter("max_height", 1.0 * height_scale)
