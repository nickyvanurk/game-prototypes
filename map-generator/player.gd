extends CharacterBody3D


@export var mouse_sensitivity = 0.005
@export var speed = 40

@onready var camera = $Camera3D


func _unhandled_input(event):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * mouse_sensitivity)
			camera.rotate_x(-event.relative.y * mouse_sensitivity)


func _process(delta):
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var up_down_dir = 0
	if Input.is_action_pressed("up"):
		up_down_dir = 1
	if Input.is_action_pressed("down"):
		up_down_dir = -1
	var direction = (camera.global_transform.basis * Vector3(input_dir.x, up_down_dir, input_dir.y)).normalized()
	if direction:
		var speed_modifier = 3 if Input.is_action_pressed("speed_boost") else 1
		velocity = direction * speed * speed_modifier
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.y = move_toward(velocity.y, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	move_and_slide()
