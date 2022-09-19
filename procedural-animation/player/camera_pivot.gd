extends Marker3D

@export var mouse_sensitivity  = 0.3
@export var min_pitch = -89
@export var max_pitch = 89

@export var min_zoom = 0.3
@export var max_zoom = 10.0
@export var zoom_step = 0.25
@export var zoom_duration = 0.2

@onready var parent = get_parent()
@onready var zoom = $CameraBoom.spring_length
@onready var boom = $CameraBoom

func _ready():
	set_as_top_level(true)

func _input(event):
	if event is InputEventMouseMotion:
		rotation.y -= deg_to_rad(event.relative.x * mouse_sensitivity)
		rotation.x -= deg_to_rad(event.relative.y * mouse_sensitivity)
		rotation.x = clampf(rotation.x, deg_to_rad(min_pitch), deg_to_rad(max_pitch))
	
	if event.is_action_pressed("zoom_in"):
		set_zoom(zoom - zoom_step)

	if event.is_action_pressed("zoom_out"):
		set_zoom(zoom + zoom_step)

func _physics_process(delta):
	position = parent.position
	position.y += 0.2

func set_zoom(value):
	zoom = clamp(value, min_zoom, max_zoom)
	var tween = create_tween()
	tween.tween_property(
		boom,
		"spring_length",
		zoom,
		zoom_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
