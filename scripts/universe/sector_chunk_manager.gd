extends Node2D

const CHUNK_SIZE = 2400
const RADIUS = 2  # Ahora con más margen para evitar desapariciones bruscas

const SectorChunkScene = preload("res://scenes/universe/SectorChunk.tscn")

var active_chunks = {}
var player: Node2D
var last_chunk_coords = Vector2i(-99999, -99999)

func _ready():
	player = get_parent().get_node("PlayerShip")
	_update_chunks()

func _process(_delta):
	var current_chunk = get_chunk_coords(player.global_position)

	if current_chunk != last_chunk_coords:
		last_chunk_coords = current_chunk
		print("🧭 Cambio de chunk a:", current_chunk, "| FPS:", Engine.get_frames_per_second())
		_update_chunks()

func _update_chunks():
	var current_chunk = last_chunk_coords

	# Cargar chunks cercanos
	for x in range(current_chunk.x - RADIUS, current_chunk.x + RADIUS + 1):
		for y in range(current_chunk.y - RADIUS, current_chunk.y + RADIUS + 1):
			var coords = Vector2i(x, y)
			if not active_chunks.has(coords):
				load_chunk(coords)

	# Descargar chunks lejanos
	var to_remove = []
	for coords in active_chunks.keys():
		if coords.distance_to(current_chunk) > RADIUS:
			to_remove.append(coords)

	for coords in to_remove:
		unload_chunk(coords)

	print("Chunks activos:", active_chunks.size())

func load_chunk(coords: Vector2i):
	print(">> Cargando chunk:", coords)
	var chunk = SectorChunkScene.instantiate()
	chunk.chunk_coords = coords
	chunk.position = coords * CHUNK_SIZE
	add_child(chunk)
	active_chunks[coords] = chunk

func unload_chunk(coords: Vector2i):
	print("<< Descargando chunk:", coords)
	if active_chunks.has(coords):
		active_chunks[coords].queue_free()
		active_chunks.erase(coords)

func get_chunk_coords(pos: Vector2) -> Vector2i:
	return Vector2i(floor(pos.x / CHUNK_SIZE), floor(pos.y / CHUNK_SIZE))

func transfer_asteroid_to_chunk(asteroid: Node2D, new_chunk_coords: Vector2i):
	if not active_chunks.has(new_chunk_coords):
		load_chunk(new_chunk_coords)

	var new_chunk = active_chunks[new_chunk_coords]
	var global_pos = asteroid.global_position

	# Reasigna el asteroide manteniendo su posición global
	asteroid.get_parent().remove_child(asteroid)
	new_chunk.add_child(asteroid)
	asteroid.global_position = global_pos
