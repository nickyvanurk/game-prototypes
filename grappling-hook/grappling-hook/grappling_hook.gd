extends Spatial

export var max_rope_length = 50

enum State { Released, Grappling, Attached, ReelingIn, ReelingOut }

var state = State.Released

func _process(delta):
	if Input.is_action_pressed("reel_in") && [State.Attached, State.ReelingIn, State.ReelingOut].has(state):
		state = State.ReelingIn
		print("Reeling in...")
	if Input.is_action_pressed("reel_out") && [State.Attached, State.ReelingIn, State.ReelingOut].has(state):
		state = State.ReelingOut
		print("Reeling out...")

func grapple():
	state = State.Grappling
	print("Grappling")
	
func release():
	state = State.Released
	print("Releasing")
