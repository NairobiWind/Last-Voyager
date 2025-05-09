extends Node2D
class_name MainDebug

@onready var player_ship = $PlayerShip
@onready var hud = $HUD
@onready var joystick = hud.get_node("VirtualJoystick")
@onready var stats = player_ship.get_node("PlayerStats")
@onready var shoot = player_ship.get_node("PlayerShoot")
@onready var movement = player_ship.get_node("PlayerMovement")
@onready var camera = player_ship.get_node("Camera2D")
@onready var debug_camera = $DebugCamera
@onready var input_manager = $MobileInputManager
@onready var fps_label = hud.get_node("FPSLabel")
@onready var chunk_manager = $SectorChunkManager

# MapManager como singleton (AutoLoad), no como nodo hijo
var map_manager = MapManager

@onready var ui_layer_top_scene = preload("res://scenes/ui/UILayerTop.tscn")

var debug_enabled := false
var time_accum := 0.0
const debug_zoom_speed := 0.1

func _ready():
	await get_tree().process_frame  # asegura que todos los nodos existen

	# --- Setup base del jugador ---
	movement.setup(player_ship, joystick, null, hud, stats)
	shoot.ship = player_ship
	shoot.player_stats = stats
	shoot.hud = hud
	shoot.bullet_scene = preload("res://scenes/ship/Bullet.tscn")

	hud.set_stats_source(player_ship, stats)

	if input_manager and not input_manager.is_connected("shoot_requested", Callable(player_ship, "_on_touch_shoot_requested")):
		input_manager.connect("shoot_requested", Callable(player_ship, "_on_touch_shoot_requested"))
	input_manager.joystick = joystick

	player_ship.setup_external(hud, joystick, input_manager)

	camera.make_current()

	# --- Instanciar UI Layer Top y configurar MiniMap ---
	var ui_layer_top_instance = ui_layer_top_scene.instantiate()
	add_child(ui_layer_top_instance)

func _process(delta: float) -> void:
	# Hotkeys debug
	if Input.is_action_just_pressed("toggle_hud"):
		hud.visible = not hud.visible

	if Input.is_action_just_pressed("toggle_camera"):
		debug_enabled = not debug_enabled
		if debug_enabled:
			debug_camera.make_current()
		else:
			camera.make_current()

	if debug_enabled:
		debug_camera.global_position = player_ship.global_position

		if Input.is_action_pressed("zoom_in"):
			debug_camera.zoom -= Vector2.ONE * debug_zoom_speed * delta

		if Input.is_action_pressed("zoom_out"):
			debug_camera.zoom += Vector2.ONE * debug_zoom_speed * delta

		# Limitar zoom entre 0.2 y 5.0 en cada componente
		var z: Vector2 = debug_camera.zoom
		z.x = clamp(z.x, 0.2, 5.0)
		z.y = clamp(z.y, 0.2, 5.0)
		debug_camera.zoom = z




	# Mostrar info rendimiento
	var fps := Engine.get_frames_per_second()
	var mem_static := Performance.get_monitor(Performance.MEMORY_STATIC)
	var draw_calls := Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)

	fps_label.text = "FPS: %d | DrawCalls: %d | Mem: %.1fMB" % [
		fps, draw_calls, mem_static / 1048576.0
	]

	time_accum += delta
	if time_accum >= 20.0:
		time_accum = 0.0
		print(fps_label.text)
