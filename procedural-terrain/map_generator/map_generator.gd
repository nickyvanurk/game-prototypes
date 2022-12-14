@tool
extends Control

@export var generate = false
@export var seed: int = 0
@export var falloff = true

@export var width: int = 512: set = _set_width
@export var height: int = 512: set = _set_height

@onready var texture_rect = $TextureRect

var falloff_map: Image = null


func _ready():
	_generate(width, height, seed)


func _process(delta):
	if generate:
		seed = randi()
		_generate(width, height, seed)
		generate = false


func _generate(width: int, height: int, seed: int):
	var height_map = _generate_height_map_image(width, height, seed)
	
	if falloff:
		if not falloff_map or falloff_map.get_width() != width or falloff_map.get_height() != height:
			falloff_map = _generate_falloff_image(width, height)

		for y in height:
			for x in width:
				height_map.set_pixel(x, y, height_map.get_pixel(x, y) - falloff_map.get_pixel(x, y))

	texture_rect.texture = ImageTexture.create_from_image(height_map)


func _generate_height_map_image(width: int, height: int, seed: int) -> Image:
	var n = FastNoiseLite.new()
	n.seed = seed
	return n.get_image(width, height)


func _generate_falloff_image(width: int, height: int) -> Image:
	var image = Image.create(width, height, false, Image.FORMAT_RGBA8)	
	for i in height:
		for j in width:
			var x = float(j) / float(width) * 2 - 1
			var y = float(i) / float(height) * 2 - 1
			var value: float = maxf(absf(x), absf(y))
			
			var a = 3.0
			var b = 2.2
			value = pow(value, a) / (pow(value, a) + pow(b - b * value, a))
			
			image.set_pixel(j, i, Color(Color.BLACK.lerp(Color.WHITE, value)))
	return image


func _set_width(value):
	width = value
	_generate(width, height, seed)


func _set_height(value):
	height = value
	_generate(width, height, seed)
