@tool
extends Node

@export var generate = false
@export var size: int = 512

@onready var preview = get_node("Preview")


func _ready():
	preview.texture = _generate_texture()


func _process(delta):
	if generate:
		preview.texture = _generate_texture()
		generate = false


func _generate_texture():
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	for y in range(size):
		for x in range(size):
			var color = Color(randi_range(0, 255), randi_range(0, 255), randi_range(0, 255), randf_range(0, 1))
			image.set_pixel(x, y, Color.BLACK)
	return ImageTexture.create_from_image(image)
