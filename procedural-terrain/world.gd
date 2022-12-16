@tool
extends Node3D

@onready var timer = $Timer
@onready var player = $Camera3D
@onready var terrain = $MapGenerator/Terrain


func _ready():
	timer.timeout.connect(Callable(terrain, "_snap").bind(player))
	timer.start()
