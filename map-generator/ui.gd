extends Control


@onready var fps = $FPS
@onready var draw_calls = $DrawCalls
@onready var vertices_drawn = $VerticesDrawn


func _unhandled_input(event):
	if Input.is_action_just_pressed("toggle_wireframe"):
		if get_viewport().debug_draw != Viewport.DEBUG_DRAW_WIREFRAME:
			RenderingServer.set_debug_generate_wireframes(true)
			get_viewport().debug_draw = Viewport.DEBUG_DRAW_WIREFRAME
		else:
			RenderingServer.set_debug_generate_wireframes(false)
			get_viewport().debug_draw = Viewport.DEBUG_DRAW_DISABLED


func _process(delta):
	fps.text = "FPS: " + str(Performance.get_monitor(Performance.TIME_FPS))
	draw_calls.text = "Draw Calls: " + str(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
	vertices_drawn.text = "Vertices Drawn: " + str(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME))
