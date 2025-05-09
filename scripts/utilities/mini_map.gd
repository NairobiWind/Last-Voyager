extends Control
class_name MiniMap

@export var base_chunk_px: int = 32
@export var view_distance: int = 1
@export var world_chunk_size: int = 2400
@export var planet_icon_radius: float = 10.0
@export var player_icon_radius: float = 4.0

var player_ship: Node2D
var chunk_manager: Node
var map_manager: Node
var player_stats: Node

var zoom_levels: Array[int] = [1, 3]
var zoom_index: int = 0

func _ready() -> void:
	z_index = 100
	mouse_filter = Control.MOUSE_FILTER_STOP
	position = Vector2(16, 16)
	custom_minimum_size = Vector2(200, 200)

	player_ship = get_node_or_null("/root/Main/PlayerShip")
	chunk_manager = get_node_or_null("/root/Main/SectorChunkManager")
	map_manager = get_node_or_null("/root/MapManager")
	if player_ship:
		player_stats = player_ship.get_node_or_null("PlayerStats")

	if not player_ship or not chunk_manager or not map_manager:
		push_warning("⚠️ MiniMap: Faltan referencias necesarias")

	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		# --- CAMBIO CLAVE: usar el rect global ---
		if get_global_rect().has_point(event.position):
			print("👆 MiniMap tocado en global:", event.position)
			_toggle_zoom()
			accept_event()

func _process(_delta: float) -> void:
	if player_stats:
		player_stats.radar_zoom_active = (view_distance == 3)
	queue_redraw()

func _toggle_zoom() -> void:
	zoom_index = (zoom_index + 1) % zoom_levels.size()
	view_distance = zoom_levels[zoom_index]
	queue_redraw()

func get_chunk_size_px() -> float:
	var logical_chunks_visible: float = float(view_distance * 2 + 1)
	var logical_diameter: float = logical_chunks_visible * world_chunk_size
	var pixels_per_unit: float = min(size.x, size.y) / logical_diameter
	return pixels_per_unit * world_chunk_size

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

func _draw() -> void:
	if not player_ship or not chunk_manager or not map_manager:
		return

	var chunk_size_px: float = get_chunk_size_px()
	var center: Vector2 = size * 0.5
	var radius: float = min(size.x, size.y) * 0.5

	draw_circle(center, radius, Color(0.1, 0.5, 0.2, 0.5))

	var W: float = float(world_chunk_size)
	var player_pos: Vector2 = player_ship.global_position
	var current_chunk = chunk_manager.get_chunk_coords(player_pos)
	var planet_chunks = chunk_manager.get_chunks_with_planets_around(current_chunk, view_distance)

	for coords in planet_chunks:
		var planet_world: Vector2 = Vector2((coords.x + 0.5) * W, (coords.y + 0.5) * W)
		var delta_pixel: Vector2 = (planet_world - player_pos) / W * chunk_size_px
		var draw_pos: Vector2 = center + delta_pixel

		var scaled_radius: float = planet_icon_radius / view_distance
		if view_distance == 3:
			scaled_radius *= 1.2

		var key: String = "%d,%d" % [coords.x, coords.y]
		var color: Color = Color(1, 1, 0.1) if map_manager.discovered_chunks.has(key) else Color(1, 0.2, 0.2)

		if draw_pos.distance_to(center) <= radius - scaled_radius:
			draw_circle(draw_pos, scaled_radius, color)

	var base_size: float = player_icon_radius
	if view_distance == 1:
		base_size *= 3.0
	elif view_distance == 3:
		base_size *= 2.0

	var triangle: Array[Vector2] = [
		Vector2(base_size, 0),
		Vector2(-base_size * 0.6, base_size * 0.75),
		Vector2(-base_size * 0.6, -base_size * 0.75)
	]

	for i in triangle.size():
		triangle[i] = triangle[i].rotated(player_ship.rotation) + center

	draw_polygon(triangle, [Color(1, 1, 1)])
