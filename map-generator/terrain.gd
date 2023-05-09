@tool
extends MeshInstance3D


@export var size = 512
@export var chunk_offset = Vector2(): set = _set_chunk_offset

var map_generator = MapGenerator.new()


func _ready():
	map_generator.seed = 21
	var height_map = map_generator._generate_height_map()
	mesh.material.set_shader_parameter("height_map", ImageTexture.create_from_image(height_map))

func _set_chunk_offset(value):
	chunk_offset = value
	map_generator.seed = 21
	map_generator.chunk_offset = value
	var height_map = map_generator._generate_height_map()
	mesh.material.set_shader_parameter("height_map", ImageTexture.create_from_image(height_map))
