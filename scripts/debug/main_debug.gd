# res://scripts/MainDebug.gd
extends Node2D
class_name MainDebug

@onready var fps_label:       Label      = $CanvasLayer/FPSLabel
@onready var hud_canvas:      CanvasLayer = $CanvasLayer
@onready var player_ship:     Node2D     = $PlayerShip
@onready var player_camera:   Camera2D   = $PlayerShip/Camera2D
@onready var debug_camera:    Camera2D   = $DebugCamera

var debug_enabled:    bool   = false
var debug_zoom_speed: float  = 0.1
var time_accum:       float  = 0.0

func _ready() -> void:
	GameState.connect("game_loaded", Callable(self, "_on_game_loaded"))
	var loaded: bool = GameState.load_state()
	if not loaded:
		print("No se cargó partida previa.")
	# Aseguramos que empezamos con la cámara del jugador
	player_camera.make_current()

func _on_game_loaded(success: bool) -> void:
	if success:
		player_ship.global_position = GameState.last_position
		GameStats.fuel = GameState.last_fuel

func _process(delta: float) -> void:
	# Toggle HUD
	if Input.is_action_just_pressed("toggle_hud"):
		hud_canvas.visible = not hud_canvas.visible

	# Toggle cámaras
	if Input.is_action_just_pressed("toggle_camera"):
		debug_enabled = not debug_enabled
		if debug_enabled:
			debug_camera.make_current()
		else:
			player_camera.make_current()

	# Si está activa la cámara debug, que siga al jugador
	if debug_enabled:
		debug_camera.global_position = player_ship.global_position
		# Zoom in/out con teclas
		if Input.is_action_pressed("zoom_in"):
			debug_camera.zoom -= Vector2.ONE * debug_zoom_speed * delta
		if Input.is_action_pressed("zoom_out"):
			debug_camera.zoom += Vector2.ONE * debug_zoom_speed * delta

	# Estadísticas básicas
	var fps        : int   = Engine.get_frames_per_second()
	var nodes      : int   = get_tree().get_node_count()
	var mem_static : float = Performance.get_monitor(Performance.MEMORY_STATIC)
	var t_proc     : float = Performance.get_monitor(Performance.TIME_PROCESS)
	var t_phys     : float = Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)
	var draw_calls : int   = Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)

	# Conteos de grupos
	var asteroid_count : int = get_tree().get_nodes_in_group("asteroids").size()
	var planet_count   : int = get_tree().get_nodes_in_group("planets").size()

	# Montar texto
	fps_label.text = "FPS: %d\n"                  % fps
	fps_label.text += "Nodos: %d\n"               % nodes
	fps_label.text += "DrawCalls: %d\n"           % draw_calls
	fps_label.text += "Mem: %.2f MB\n"            % (mem_static/1048576.0)
	fps_label.text += "P: %.2f ms  F: %.2f ms\n"  % [t_proc*1000.0, t_phys*1000.0]
	fps_label.text += "Ast: %d  Pl: %d"           % [asteroid_count, planet_count]

	# Log periódico
	time_accum += delta
	if time_accum >= 20.0:
		time_accum = 0.0
		print(fps_label.text)

func _notification(what: int) -> void:
	if what == Window.NOTIFICATION_WM_CLOSE_REQUEST:
		GameState.save_state()
