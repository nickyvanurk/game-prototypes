extends Spatial

export var max_rope_length = 50
export var rest_length = 1
export var rope_stiffness = 4
export var max_grapple_speed = 30

enum State { Released, Attached, ReelingIn, ReelingOut }

var state = State.Released
var grapple_position = Vector3.ZERO
var rope_length

onready var parent = get_parent()
onready var line_geometry = get_node("LineGeometry")
onready var rope = $Rope

func _ready():
	if !("velocity" in parent):
		print_debug("Parent needs velocity")
		set_process(false)
		set_physics_process(false)

func _process(delta):
	if Input.is_action_pressed("reel_in") && [State.Attached, State.ReelingIn, State.ReelingOut].has(state):
		state = State.ReelingIn
		print("Reeling in...")
	if Input.is_action_pressed("reel_out") && [State.Attached, State.ReelingIn, State.ReelingOut].has(state):
		state = State.ReelingOut
		print("Reeling out...")

func _physics_process(delta):
	rope.visible = false
	
	if is_attached():
		var direction = (grapple_position - parent.translation).normalized()
		var length = (grapple_position - parent.translation).length()
	
		if length > rope_length:
			parent.translation = grapple_position - (direction * rope_length)
		
		var speed_towards_grapple_position = round(parent.velocity.dot(direction) * 100) / 100
		if speed_towards_grapple_position:
			if length > rope_length:
				parent.velocity -= speed_towards_grapple_position * direction
				parent.translation = grapple_position - direction * length
		
		rope.scale = Vector3(0.02, 0.02, length / 2)
		rope.look_at_from_position((grapple_position + global_transform.origin) / 2, grapple_position, Vector3.UP)
		rope.visible = true

func grapple(target):
	state = State.Attached
	grapple_position = target
	rope_length = (grapple_position - parent.translation).length()
	
func release():
	state = State.Released

func is_attached():
	return [State.Attached, State.ReelingIn, State.ReelingOut].has(state)
