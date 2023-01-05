extends Camera3D

@export var follow_speed = 0.05
@export var target: CharacterBody3D = null

@onready var offset = position


func _process(delta):
	if target != null:
		position = position.lerp(Vector3(target.position.x + offset.x, offset.y, target.position.z + offset.z), 0.05)
