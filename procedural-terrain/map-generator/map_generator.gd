@tool
extends Control

@export var generate = false
@export var seed: int = 0: set = _set_seed
@export var falloff = true: set = _set_falloff

@export var width: int = 512: set = _set_width
@export var height: int = 512: set = _set_height

@export var octaves: int = 6: set = _set_octaves
@export var frequency: float = 1.25: set = _set_frequency
@export var persistence: float = 0.5: set = _set_persistence
@export var lacunarity: float = 2.0: set = _set_lacunarity

@onready var texture_rect = $TextureRect
@onready var terrain = $Terrain

var falloff_map: Image = null


func _ready():
	_generate(width, height, seed)


func _process(delta):
	if generate:
		seed = randi()
		_generate(width, height, seed)
		generate = false


func _generate(width: int, height: int, seed: int):
	if not Engine.is_editor_hint(): return
	
	var height_map = _generate_height_map_image(width, height, seed)
	
	if falloff:
		if not falloff_map or falloff_map.get_width() != width or falloff_map.get_height() != height:
			falloff_map = _generate_falloff_image(width, height)

		_subtract_pixels(height_map, falloff_map)
	
	var texture = ImageTexture.create_from_image(height_map)
	texture_rect.texture = texture
	RenderingServer.global_shader_parameter_set("height_map", texture);	


func _subtract_pixels(a: Image, b: Image):
	assert(a.get_width() == b.get_width() and a.get_height() == b.get_height())

	for y in a.get_height():
		for x in a.get_width():
			a.set_pixel(x, y, a.get_pixel(x, y) - b.get_pixel(x, y))


func _generate_height_map_image(width: int, height: int, seed: int) -> Image:
	var n = FastNoiseLite.new()
	n.noise_type = FastNoiseLite.TYPE_SIMPLEX
	n.seed = seed
	n.frequency = frequency
	n.fractal_octaves = octaves
	n.fractal_gain = persistence
	n.fractal_lacunarity = lacunarity
	
	# return array; not image?
	
	# Can I have in editor texture preview?
	
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


func _set_seed(value: int):
	seed = value
	_generate(width, height, seed)


func _set_falloff(value: bool):
	falloff = value
	_generate(width, height, seed)


func _set_width(value: int):
	width = value
	_generate(width, height, seed)


func _set_height(value: int):
	height = value
	_generate(width, height, seed)


func _set_octaves(value: int):
	octaves = value
	_generate(width, height, seed)


func _set_frequency(value: float):
	frequency = value
	_generate(width, height, seed)


func _set_persistence(value: float):
	persistence = value
	_generate(width, height, seed)


func _set_lacunarity(value: float):
	lacunarity = value
	_generate(width, height, seed)
