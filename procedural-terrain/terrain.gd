@tool
extends MeshInstance3D

var snap_step = 20
var shape = HeightMapShape3D.new()


func _snap(player):
	var player_pos = player.global_transform.origin.snapped(Vector3(snap_step, 0, snap_step))
	global_transform.origin.x = player_pos.x
	global_transform.origin.z = player_pos.z
	get_active_material(0).set("shader_param/uvx", player_pos.x / mesh.size.x)
	get_active_material(0).set("shader_param/uvy", player_pos.z / mesh.size.y)
	_create_collision_shape(player_pos.x / mesh.size.x, player_pos.z / mesh.size.y)


func _create_collision_shape(uvx: float, uvy: float):
	var heightmap = load("res://map-generator/heightmap.tres").get_image()
	var height = get_active_material(0).get("shader_param/height_scale")
	
	var pos = Vector2(0.5 - (256.0 / 2048.0), 0.5 - (256.0 / 2048.0))
	pos.x += uvx / 4.0
	pos.y += uvy / 4.0
	pos *= heightmap.get_width()
	
	var data: PackedFloat32Array = []
	for y in range(pos.y, pos.y + 516, 4):
		for x in range(pos.x, pos.x + 516, 4):
			data.push_back(heightmap.get_pixel(x, y).r * height)
			
	shape.map_width = 129
	shape.map_depth = 129
	shape.map_data = data
	$StaticBody3D/CollisionShape3D.shape = shape
	$StaticBody3D/CollisionShape3D.scale = Vector3(4, 1, 4)
