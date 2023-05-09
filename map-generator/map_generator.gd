@tool
extends Node

@export var generate = false
@export var size: int = 512
@export var seed: int = 0
@export var octaves: int = 6
@export var frequency: float = 0.002
@export var persistence: float = 0.5
@export var lacunarity: float = 2.0

@onready var preview = get_node("Preview")


func _ready():
	_generate()


func _process(delta):
	if generate:
		_generate()
		generate = false


func _generate():
	preview.texture = _generate_height_map()


func _generate_height_map():
	var n = FastNoiseLite.new()
	n.noise_type = FastNoiseLite.TYPE_SIMPLEX
	n.seed = seed
	n.frequency = frequency
	n.fractal_octaves = octaves
	n.fractal_gain = persistence
	n.fractal_lacunarity = lacunarity
	return ImageTexture.create_from_image(n.get_image(size, size))


func _generate_texture():
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	for y in range(size):
		for x in range(size):
			var color = Color(randi_range(0, 255), randi_range(0, 255), randi_range(0, 255), randf_range(0, 1))
			image.set_pixel(x, y, Color.BLACK)
	return ImageTexture.create_from_image(image)
