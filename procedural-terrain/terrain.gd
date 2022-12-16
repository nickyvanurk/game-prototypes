@tool
extends MeshInstance3D

var snap_step = 1.0
var size = 512.0


func _snap(player):
	var player_pos = player.global_transform.origin.snapped(Vector3(snap_step, 0, snap_step))
	global_transform.origin.x = player_pos.x
	global_transform.origin.z = player_pos.z
