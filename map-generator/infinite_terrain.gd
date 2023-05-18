extends Node3D


@export var chunk_size = 128
@export var view_distance = 1000
@export var viewer: Node3D
@export var chunk_scene: PackedScene

var map_generator = MapGenerator.new()
var chunks = {}
var total_chunks


func _ready():
	map_generator.seed = 21
	map_generator.chunk_size = chunk_size
	var height_map = map_generator._generate_height_map()
	total_chunks = roundi(view_distance / chunk_size)


func _process(delta):
	_update_chunks()


func _update_chunks():
	var current_x = roundi(viewer.position.x / chunk_size)
	var current_z = roundi(viewer.position.z / chunk_size)

	for offset_z in range(-total_chunks, total_chunks):
		for offset_x in range(-total_chunks, total_chunks):
			var viewer_offset = Vector3(current_x - offset_x, 0, current_z - offset_z)
			if chunks.has(viewer_offset):
				if chunks[viewer_offset]._update_lod(viewer.position):
					map_generator.chunk_offset.x = viewer_offset.x
					map_generator.chunk_offset.y = viewer_offset.z
					var height_map = map_generator._generate_height_map()
					chunks[viewer_offset]._generate(height_map, viewer_offset, chunk_size)
			else:
				var chunk = chunk_scene.instantiate();
				map_generator.chunk_offset.x = viewer_offset.x
				map_generator.chunk_offset.y = viewer_offset.z
				var height_map = map_generator._generate_height_map()
				chunk._generate(height_map, viewer_offset, chunk_size)
				chunks[viewer_offset] = chunk
				add_child(chunk)
