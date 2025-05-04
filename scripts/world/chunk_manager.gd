extends Node2D

const CHUNK_SIZE = 2400
const RADIUS = 2
const ChunkScene = preload("res://scenes/world/Chunk.tscn")

var active_chunks = {}
var player: Node2D
var last_chunk_coords = Vector2i(-99999, -99999)

func _ready():
	player = get_parent().get_node("PlayerShip")  # Cambiar si tu nodo tiene otro nombre

func _process(_delta):
	var player_chunk = get_chunk_coords(player.global_position)

	# Verificación: solo imprimir si cambió de chunk
	if player_chunk != last_chunk_coords:
		print("Chunk actual:", player_chunk)
		last_chunk_coords = player_chunk

	# Cargar chunks cercanos
	for x in range(player_chunk.x - RADIUS, player_chunk.x + RADIUS + 1):
		for y in range(player_chunk.y - RADIUS, player_chunk.y + RADIUS + 1):
			var chunk_pos = Vector2i(x, y)
			if not active_chunks.has(chunk_pos):
				load_chunk(chunk_pos)

	# Descargar chunks lejanos
	var to_remove = []
	for pos in active_chunks.keys():
		if pos.distance_to(player_chunk) > RADIUS:
			to_remove.append(pos)

	for pos in to_remove:
		unload_chunk(pos)

func get_chunk_coords(pos: Vector2) -> Vector2i:
	return Vector2i(floor(pos.x / CHUNK_SIZE), floor(pos.y / CHUNK_SIZE))

func load_chunk(pos: Vector2i):
	var chunk = ChunkScene.instantiate()
	chunk.position = pos * CHUNK_SIZE
	chunk.chunk_coords = pos
	add_child(chunk)
	active_chunks[pos] = chunk

func unload_chunk(pos: Vector2i):
	if active_chunks.has(pos):
		active_chunks[pos].queue_free()
		active_chunks.erase(pos)
