extends Control

@export var base_chunk_px: int         = 32
@export var view_distance: int        = 1
@export var world_chunk_size: int     = 2400
@export var planet_icon_radius: float = 10.0
@export var player_icon_radius: float = 4.0

@onready var player_ship: Node2D = get_node("/root/Main/PlayerShip")
@onready var chunk_manager: Node = get_node("/root/Main/SectorChunkManager")
@onready var map_manager: Node = get_node("/root/MapManager")

var zoom_levels := [1, 3]
var zoom_index := 0

func _ready() -> void:
	set_process(true)
	set_mouse_filter(Control.MOUSE_FILTER_PASS)
	queue_redraw()

func _process(_delta: float) -> void:
	GameStats.radar_zoom_active = (view_distance == 3)
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if get_rect().has_point(event.position):
			_toggle_zoom()
	elif event is InputEventScreenTouch and event.pressed:
		if get_rect().has_point(event.position):
			_toggle_zoom()

func _toggle_zoom() -> void:
	zoom_index = (zoom_index + 1) % zoom_levels.size()
	view_distance = zoom_levels[zoom_index]
	queue_redraw()

func get_chunk_size_px() -> float:
	var logical_chunks_visible = (view_distance * 2 + 1)
	var logical_diameter = float(logical_chunks_visible) * world_chunk_size
	var pixels_per_unit = min(size.x, size.y) / logical_diameter
	return pixels_per_unit * world_chunk_size

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

func _draw() -> void:
	if not player_ship or not chunk_manager or not map_manager:
		return

	var chunk_size_px = get_chunk_size_px()
	var size2d = size
	var center = size2d * 0.5
	var radius = min(size2d.x, size2d.y) * 0.5

	draw_circle(center, radius, Color(0.1, 0.5, 0.2, 0.5))

	var W = float(world_chunk_size)
	var player_pos = player_ship.global_position
	var current_chunk = chunk_manager.get_chunk_coords(player_pos)

	var planet_chunks = chunk_manager.get_chunks_with_planets_around(current_chunk, view_distance)

	for coords in planet_chunks:
		var planet_world = Vector2((coords.x + 0.5) * W, (coords.y + 0.5) * W)
		var delta_pixel = (planet_world - player_pos) / W * chunk_size_px
		var draw_pos = center + delta_pixel

		# Radio adaptado según zoom (20% mayor si view_distance == 3)
		var scaled_radius = planet_icon_radius / view_distance
		if view_distance == 3:
			scaled_radius *= 1.2

		# Marcar como descubierto si es el mismo chunk que el jugador
		if coords == current_chunk:
			map_manager.discover_chunk(coords)

		var key = "%d,%d" % [coords.x, coords.y]
		var color = Color(1, 1, 0.1) if map_manager.discovered_chunks.has(key) else Color(1, 0.2, 0.2)

		if draw_pos.distance_to(center) <= radius - scaled_radius:
			draw_circle(draw_pos, scaled_radius, color)

	draw_circle(center, player_icon_radius, Color(1, 1, 1))

	var label = "Zoom: %dx%d" % [view_distance * 2 + 1, view_distance * 2 + 1]
	draw_string(get_theme_default_font(), Vector2(4, 14), label, HORIZONTAL_ALIGNMENT_LEFT)
	draw_rect(Rect2(Vector2.ZERO, size), Color(1, 1, 1, 0.15), false, 1)
