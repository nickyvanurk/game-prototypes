extends Node


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		# Toggle MOUSE_MODE_VISIBLE = 0 and MOUSE_MODE_CAPTURED = 2
		Input.set_mouse_mode(abs(Input.get_mouse_mode() - 2))
