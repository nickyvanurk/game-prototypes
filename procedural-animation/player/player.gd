extends CharacterBody3D

@export var speed = 3
@export var acceleration = 9
@export var jump_impulse = 6.2

@onready var gravity = ProjectSettings.get("physics/3d/default_gravity")
@onready var terminal_velocity = ProjectSettings.get("physics/3d/terminal_velocity")

@onready var legs = $CollisionShape3D/Body/Legs.get_children()

func _physics_process(delta):
	var camera_basis = $Camera3D.transform.basis
	var input = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_forward", "move_backward"))
	var direction = camera_basis * Vector3(input.x, 0, input.y)
	direction.y = 0
	direction = direction.normalized()
	
	velocity.x = velocity.x + (direction.x * speed - velocity.x) * (acceleration * delta)
	velocity.z = velocity.z + (direction.z * speed - velocity.z) * (acceleration * delta)
	velocity.y = clamp(velocity.y - (gravity * delta), -terminal_velocity, terminal_velocity)
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_impulse
	
	move_and_slide()

	if direction.length() > 0:
		var q_from = global_transform.basis.get_rotation_quaternion()
		var q_to = Transform3D().looking_at(direction).basis.get_rotation_quaternion()
		global_transform.basis = Basis(q_from.slerp(q_to, 5 * delta))
	
	for leg in legs:
		if leg.should_step():
			var leg_direction = velocity.normalized()
			leg.step(leg_direction)
