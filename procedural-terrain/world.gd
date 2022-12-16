@tool
extends Node3D

@onready var player = $Camera3D
@onready var terrain = $MapGenerator/Terrain


func _ready():
	var timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(Callable(terrain, "_snap").bind(player))
	timer.start()
