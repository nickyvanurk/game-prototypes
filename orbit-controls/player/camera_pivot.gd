extends Position3D

export(float, 0.1, 1) var mouse_sensitivity  = 0.3
export(float, -90, 0) var min_pitch = -90
export(float, 0, 90) var max_pitch = 90

export(float) var min_zoom = 1.0
export(float) var max_zoom = 10.0
export(float) var zoom_factor = 0.5
export(float) var zoom_duration = 0.2

onready var parent = get_parent()
onready var camera_boom = $CameraBoom
onready var tween = $Tween

var zoom_level = 1.0 setget set_zoom_level

func _ready():
	zoom_level = camera_boom.spring_length

func _input(event):
	if Input.is_action_pressed("rotate_camera") and event is InputEventMouseMotion:
		parent.rotation_degrees.y -= event.relative.x * mouse_sensitivity
		rotation_degrees.x -= event.relative.y * mouse_sensitivity
		rotation_degrees.x = clamp(rotation_degrees.x, min_pitch, max_pitch)
	
	if event.is_action_pressed("zoom_in"):
		set_zoom_level(zoom_level - zoom_factor)
		
	if event.is_action_pressed("zoom_out"):
		set_zoom_level(zoom_level + zoom_factor)

func set_zoom_level(value):
	zoom_level = clamp(value, min_zoom, max_zoom)
	tween.interpolate_property(
		camera_boom,
		"spring_length",
		camera_boom.spring_length,
		zoom_level,
		zoom_duration,
		Tween.TRANS_SINE,
		Tween.EASE_OUT
	)
	tween.start()
