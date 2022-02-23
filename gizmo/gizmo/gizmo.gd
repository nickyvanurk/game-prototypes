extends Spatial

export(NodePath) var parent_path

onready var cone_x = $x/Cone
onready var cone_y = $y/Cone
onready var cone_z = $z/Cone

func _physics_process(delta):
	var parent = get_node(parent_path)
	visible = parent != null
	
	if parent:
		global_transform.origin = parent.global_transform.origin
