extends Spatial

export var max_rope_length = 50
export var rest_length = 1
export var rope_stiffness = 10
export var max_grapple_speed = 15

enum State { Released, Attached, ReelingIn, ReelingOut }

var state = State.Released
var grapple_position = Vector3.ZERO

onready var parent = get_parent()

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
	if is_attached():
		var parent_hook_delta = (grapple_position - parent.translation)
		var length = parent_hook_delta.length()
	
		# Dampening
		parent.velocity *= 0.999 if length > rest_length else 0.9
		
		# Hooke's law
		var acceleration = min(abs(rope_stiffness * (length - rest_length)), max_grapple_speed)
		parent.velocity += parent_hook_delta.normalized() * (acceleration * delta)

func grapple(target):
	state = State.Attached
	grapple_position = target
	
func release():
	state = State.Released

func is_attached():
	return [State.Attached, State.ReelingIn, State.ReelingOut].has(state)
