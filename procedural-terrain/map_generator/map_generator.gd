@tool
extends Control

@export var generate = false
@export var seed: int = 0
@export var falloff = true

@onready var texture_rect = $TextureRect


func _ready():
	_generate()


func _process(delta):
	if generate:
		_generate()
		generate = false


func _generate():
	seed = randi()
	var height_map = _generate_height_map_image(512, seed);
	
	if falloff:
		var falloff_map = _generate_falloff_image(512);
		for y in height_map.get_height():
			for x in height_map.get_width():
				height_map.set_pixel(x, y, height_map.get_pixel(x, y) - falloff_map.get_pixel(x, y))
	
	texture_rect.texture = ImageTexture.create_from_image(height_map)


func _generate_height_map_image(size: int, seed: int) -> Image:
	var n = FastNoiseLite.new()
	n.seed = seed
	return n.get_image(size, size)	


func _generate_falloff_image(size: int) -> Image:
	var img = Image.create(size, size, false, Image.FORMAT_RGBA8)	
	for i in size:
		for j in size:
			var x = float(i) / float(size) * 2 - 1
			var y = float(j) / float(size) * 2 - 1
			var value: float = maxf(absf(x), absf(y))
			
			var a = 3.0
			var b = 2.2
			value = pow(value, a) / (pow(value, a) + pow(b - b * value, a))
			
			img.set_pixel(i, j, Color(Color.BLACK.lerp(Color.WHITE, value)))
	return img
