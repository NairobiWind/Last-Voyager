# res://ui/Minimap.gd
extends Control

# =========== Parámetros de configuración ===========
@export var chunk_size_px: int         = 32    # px por chunk en el minimapa
@export var view_distance: int        = 1     # 1 → ventana 3×3
@export var world_chunk_size: int     = 2400  # debe coincidir con CHUNK_SIZE
@export var planet_icon_radius: float = 10.0  # radio en px del icono de planeta
@export var player_icon_radius: float = 4.0   # radio en px del icono del jugador

@onready var player_ship: Node2D    = get_node("/root/Main/PlayerShip")
@onready var map_manager := get_node_or_null("/root/MapManager")

func _ready() -> void:
	set_process(true)
	queue_redraw()

func _process(delta: float) -> void:
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

func _draw() -> void:
	if not player_ship or not map_manager:
		return

	var size2d    = size
	var center    = size2d * 0.5
	var radius    = min(size2d.x, size2d.y) * 0.5

	# 1) Fondo circular verde semitransparente (siempre dibujado)
	draw_circle(center, radius, Color(0.1, 0.5, 0.2, 0.5))

	var W           = float(world_chunk_size)
	var player_pos  = player_ship.global_position
	var pc_x        = floor(player_pos.x / W)
	var pc_y        = floor(player_pos.y / W)

	# 2) Dibujar planetas cacheados solo dentro del círculo 3×3
	for coords in map_manager.planet_chunks:
		var dx = coords.x - pc_x
		var dy = coords.y - pc_y
		if abs(dx) > view_distance or abs(dy) > view_distance:
			continue

		# cálculo posición en pixeles relativos
		var planet_world = Vector2((coords.x + 0.5) * W,
								   (coords.y + 0.5) * W)
		var delta_pixel  = (planet_world - player_pos) / W * chunk_size_px
		var draw_pos     = center + delta_pixel

		# culling: imprime solo si está dentro del círculo
		if draw_pos.distance_to(center) <= radius - planet_icon_radius:
			draw_circle(draw_pos, planet_icon_radius,
						Color(1, 0.2, 0.2))

	# 3) Punto del jugador encima de todo (siempre en el centro)
	draw_circle(center, player_icon_radius, Color(1, 1, 1))
