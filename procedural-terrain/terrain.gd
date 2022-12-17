@tool
extends MeshInstance3D

var snap_step = 1.0
var size = 512.0

var collision_decimation = 10.0
var shape = HeightMapShape3D.new()


func _snap(player):
	var player_pos = player.global_transform.origin.snapped(Vector3(snap_step, 0, snap_step))
	global_transform.origin.x = player_pos.x
	global_transform.origin.z = player_pos.z
	get_active_material(0).set("shader_param/uvx", player_pos.x / size)
	get_active_material(0).set("shader_param/uvy", player_pos.z / size)
	_create_collision_shape(player_pos.x / size, player_pos.z / size)


func _create_collision_shape(uvx: float, uvy: float):
	var heightmap = load("res://map-generator/heightmap.tres").get_image()
	var height = get_active_material(0).get("shader_param/height_scale")
	
	# Get the terrain position in relation to the heightmap (same as terrain shader)
	var heightmap_scale = 1.0 / (heightmap.get_width() / mesh.size.x)
	var pos = Vector2(0, 0)
	pos.x += 0.5 - heightmap_scale / 2.0
	pos.y += 0.5 - heightmap_scale / 2.0
	pos.x += uvx * heightmap_scale
	pos.y += uvy * heightmap_scale
	pos *= heightmap.get_width()
	
	var data: PackedFloat32Array = []
	for y in range(pos.y, pos.y + mesh.size.y):
		for x in range(pos.x, pos.x + mesh.size.x):
			data.push_back(heightmap.get_pixel(x, y).r * height)
			
	shape.map_width = mesh.size.x
	shape.map_depth = mesh.size.y
	shape.map_data = data
	$StaticBody3D/CollisionShape3D.shape = shape
