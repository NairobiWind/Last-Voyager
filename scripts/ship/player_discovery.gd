extends Node
class_name PlayerDiscovery

@export var world_chunk_size: int = 2400

@onready var player_ship: Node2D = get_parent()
@onready var chunk_manager: Node = get_node("/root/Main/SectorChunkManager")
@onready var map_manager: Node = get_node("/root/MapManager")

var last_chunk: Vector2i = Vector2i(9999, 9999)

func _process(_delta: float) -> void:
	if not player_ship or not chunk_manager or not map_manager:
		return

	# Redondea hacia abajo para evitar errores por borde
	var pos := player_ship.global_position.floor()
	var current_chunk := Vector2i(
	int(floor(pos.x / world_chunk_size)),
	int(floor(pos.y / world_chunk_size))
	)

	if current_chunk != last_chunk:
		last_chunk = current_chunk
		print("🗺 Descubriendo SOLO al entrar exactamente en:", current_chunk)
		map_manager.discover_chunk(current_chunk)
