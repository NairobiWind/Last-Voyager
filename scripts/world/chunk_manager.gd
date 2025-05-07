# res://scripts/world/ChunkManager.gd
extends Node2D

# --- Configuración ---
const CHUNK_SIZE         = 2400                           # píxels por chunk
const PADDING_CHUNKS     = 0                              # margen extra en chunks
const PLAYER_MARGIN_SIZE = Vector2(2600, 1300)           # zona de interés en píxels

# Cuántos chunks cubre la mitad de PLAYER_MARGIN_SIZE
const MARGIN_CHUNKS_X = int(ceil((PLAYER_MARGIN_SIZE.x * 0.5) / CHUNK_SIZE))
const MARGIN_CHUNKS_Y = int(ceil((PLAYER_MARGIN_SIZE.y * 0.5) / CHUNK_SIZE))

const ChunkScene = preload("res://scenes/world/Chunk.tscn")

# --- Estado ---
var active_chunks : Dictionary = {}   # Vector2i -> Nodo de chunk
var player         : Node2D
var last_chunk     : Vector2i

func _ready() -> void:
	player     = get_parent().get_node("PlayerShip")
	last_chunk = _get_player_chunk()
	_update_chunks()
	set_process(true)

func _process(_delta: float) -> void:
	var current = _get_player_chunk()
	if current != last_chunk:
		last_chunk = current
		_update_chunks()

func _get_player_chunk() -> Vector2i:
	return Vector2i(
		floor(player.global_position.x / CHUNK_SIZE),
		floor(player.global_position.y / CHUNK_SIZE)
	)

func _update_chunks() -> void:
	var cx = last_chunk.x
	var cy = last_chunk.y
	var from_x = cx - MARGIN_CHUNKS_X - PADDING_CHUNKS
	var to_x   = cx + MARGIN_CHUNKS_X + PADDING_CHUNKS
	var from_y = cy - MARGIN_CHUNKS_Y - PADDING_CHUNKS
	var to_y   = cy + MARGIN_CHUNKS_Y + PADDING_CHUNKS

	# Marcar qué chunks necesitamos
	var required : Dictionary = {}
	for x in range(from_x, to_x + 1):
		for y in range(from_y, to_y + 1):
			var coords = Vector2i(x, y)
			required[coords] = true
			if not active_chunks.has(coords):
				_load_chunk(coords)

	# Descargar los que ya no son necesarios
	for coords in active_chunks.keys():
		if not required.has(coords):
			_unload_chunk(coords)

func _load_chunk(coords: Vector2i) -> void:
	var chunk = ChunkScene.instantiate()
	chunk.position     = coords * CHUNK_SIZE
	chunk.chunk_coords = coords
	add_child(chunk)
	active_chunks[coords] = chunk

func _unload_chunk(coords: Vector2i) -> void:
	var chunk = active_chunks[coords]
	if chunk:
		chunk.queue_free()
	active_chunks.erase(coords)
