@tool
extends Node

@export var generate = false
@export var size: int = 512
@export var seed: int = 0
@export var octaves: int = 6
@export var frequency: float = 0.002
@export var persistence: float = 0.5
@export var lacunarity: float = 2.0

@export var deep_water = 0.2
@export var shallow_water = 0.4
@export var sand = 0.5
@export var grass = 0.7
@export var forest = 0.8
@export var rock = 0.9
@export var snow = 1.0

@export var deep_water_color = Color(0, 0, 0.5, 1)
@export var shallow_water_color = Color(25.0/255, 25.0/255, 150.0/255, 1)
@export var sand_color = Color(240.0/255, 240.0/255, 64.0/255, 1)
@export var grass_color = Color(50.0/255, 220.0/255, 20.0/255, 1)
@export var forest_color = Color(16.0/255, 160.0/255, 0, 1)
@export var rock_color = Color(0.5, 0.5, 0.5, 1)
@export var snow_color = Color(1, 1, 1, 1)

@onready var preview = get_node("Preview")


func _ready():
	_generate()


func _process(delta):
	if generate:
		_generate()
		generate = false


func _generate():
	var height_map = _generate_height_map()
	var falloff_map = _generate_falloff_map()
	
	for y in size:
		for x in size:
			height_map.set_pixel(x, y, height_map.get_pixel(x, y) - falloff_map.get_pixel(x, y))
	
	var colored_height_map = _generate_colored_height_map(height_map)
	preview.texture = ImageTexture.create_from_image(colored_height_map)


func _generate_colored_height_map(height_map) -> Image:
	var colored_height_map = Image.create(size, size, false, Image.FORMAT_RGBA8)
	for y in range(size):
		for x in range(size):
			var value = height_map.get_pixel(x, y).r
			
			if value < deep_water:
				colored_height_map.set_pixel(x, y, deep_water_color)
			elif value < shallow_water:
				colored_height_map.set_pixel(x, y, shallow_water_color)
			elif value < sand:
				colored_height_map.set_pixel(x, y, sand_color)
			elif value < grass:
				colored_height_map.set_pixel(x, y, grass_color)
			elif value < forest:
				colored_height_map.set_pixel(x, y, forest_color)
			elif value < rock:
				colored_height_map.set_pixel(x, y, rock_color)
			else:
				colored_height_map.set_pixel(x, y, snow_color)
	return colored_height_map


func _generate_height_map() -> Image:
	var n = FastNoiseLite.new()
	n.noise_type = FastNoiseLite.TYPE_SIMPLEX
	n.seed = seed
	n.frequency = frequency
	n.fractal_octaves = octaves
	n.fractal_gain = persistence
	n.fractal_lacunarity = lacunarity
	return n.get_image(size, size)


func _generate_falloff_map() -> Image:
	var falloff_map = Image.create(size, size, false, Image.FORMAT_RGBA8)	
	for y in size:
		for x in size:
			var value = maxf(absf(float(x) / float(size) * 2 - 1), 
							absf(float(y) / float(size) * 2 - 1))
			var a = 3.0
			var b = 2.2
			value = pow(value, a) / (pow(value, a) + pow(b - b * value, a))
			falloff_map.set_pixel(x, y, Color(Color.BLACK.lerp(Color.WHITE, value)))
	return falloff_map



func _generate_texture() -> Image:
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	for y in range(size):
		for x in range(size):
			var color = Color(randi_range(0, 255), randi_range(0, 255), randi_range(0, 255), randf_range(0, 1))
			image.set_pixel(x, y, Color.BLACK)
	return image
