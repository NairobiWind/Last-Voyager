extends Node2D

@onready var fps_label = $CanvasLayer/FPSLabel
@onready var hud_canvas := $CanvasLayer
@onready var player_camera := $PlayerShip/Camera2D
@onready var debug_camera := $DebugCamera

var debug_enabled := false
var debug_cam_speed := 800.0
var debug_zoom_speed := 0.1
var time_accumulator := 0.0

func _process(delta):
	if Input.is_action_just_pressed("toggle_hud"):
		hud_canvas.visible = not hud_canvas.visible

	if Input.is_action_just_pressed("toggle_camera"):
		debug_enabled = not debug_enabled
		if debug_enabled:
			debug_camera.make_current()
		else:
			player_camera.make_current()

	if debug_enabled:
		var move := Vector2.ZERO
		if Input.is_action_pressed("cam_up"):
			move.y -= 1
		if Input.is_action_pressed("cam_down"):
			move.y += 1
		if Input.is_action_pressed("cam_left"):
			move.x -= 1
		if Input.is_action_pressed("cam_right"):
			move.x += 1
		debug_camera.position += move.normalized() * debug_cam_speed * delta

		if Input.is_action_pressed("zoom_in"):
			debug_camera.zoom -= Vector2.ONE * debug_zoom_speed * delta
		if Input.is_action_pressed("zoom_out"):
			debug_camera.zoom += Vector2.ONE * debug_zoom_speed * delta

	var fps = Engine.get_frames_per_second()
	var nodes = get_tree().get_node_count()
	var mem_static = Performance.get_monitor(Performance.MEMORY_STATIC)
	var time_process = Performance.get_monitor(Performance.TIME_PROCESS)
	var time_physics = Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)
	var draw_calls = Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)

	var stars_total = count_total_stars()
	var asteroids_total = get_tree().get_nodes_in_group("asteroids").size()
	var planets_total = get_tree().get_nodes_in_group("planets").size()

	fps_label.text = "FPS: %d\nNodos: %d\nDrawCalls: %d\n" % [fps, nodes, draw_calls]
	fps_label.text += "Mem Static: %.2f MB\n" % (mem_static / 1048576.0)
	fps_label.text += "Time Process: %.2f ms\nTime Physics: %.2f ms\n" % [time_process * 1000.0, time_physics * 1000.0]
	fps_label.text += "Stars: %d\nAsteroids: %d\nPlanets: %d" % [stars_total, asteroids_total, planets_total]

	time_accumulator += delta
	if time_accumulator >= 20.0:
		time_accumulator = 0.0
		print("\n[HUD STATS]")
		print("FPS: %d" % fps)
		print("Nodos: %d" % nodes)
		print("DrawCalls: %d" % draw_calls)
		print("Mem Static: %.2f MB" % (mem_static / 1048576.0))
		print("Time Process: %.2f ms" % (time_process * 1000.0))
		print("Time Physics: %.2f ms" % (time_physics * 1000.0))
		print("Stars: %d" % stars_total)
		print("Asteroids: %d" % asteroids_total)
		print("Planets: %d" % planets_total)

func count_total_stars() -> int:
	var total = 0
	for chunk in get_tree().get_nodes_in_group("chunks"):
		if chunk.has_node("MultiMeshInstance2D"):
			var mm: MultiMesh = chunk.get_node("MultiMeshInstance2D").multimesh
			if mm:
				total += mm.instance_count
	return total

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		GameState.save_game()
		
func _ready():
	GameState.load_state()
