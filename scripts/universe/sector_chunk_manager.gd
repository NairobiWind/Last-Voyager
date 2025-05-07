extends Node2D

const CHUNK_SIZE = 2400
const SectorChunkScene = preload("res://scenes/universe/SectorChunk.tscn")
const CHUNK_UNLOAD_DELAY_MS = 0

var active_chunks: Dictionary = {}
var unload_queue: Dictionary = {}
var player: Node2D
var last_chunk_coords = Vector2i(-99999, -99999)

func _ready():
	player = get_parent().get_node("PlayerShip")
	_update_chunks()

func _process(_delta):
	if not player:
		return

	var current_chunk = get_chunk_coords(player.global_position)
	if current_chunk != last_chunk_coords:
		last_chunk_coords = current_chunk
		print("🧭 Cambio de chunk a:", current_chunk, "| FPS:", Engine.get_frames_per_second())
		_update_chunks()

		# 💡 Verificar si el chunk contiene planeta y marcarlo como descubierto
		var data = UniverseData.get_chunk_data(current_chunk)
		if data.has("planet"):
			MapManager.discover_chunk(current_chunk)

	_process_chunk_unloads()
	queue_redraw()

func _update_chunks():
	var current_chunk = get_chunk_coords(player.global_position)
	var keep_chunks: Array[Vector2i] = []

	for x in range(-1, 2):
		for y in range(-1, 2):
			var offset = Vector2i(x, y)
			keep_chunks.append(current_chunk + offset)

	for coords in keep_chunks:
		if not active_chunks.has(coords):
			load_chunk(coords)
		unload_queue.erase(coords)

	for coords in active_chunks.keys():
		if not keep_chunks.has(coords) and not unload_queue.has(coords):
			unload_queue[coords] = Time.get_ticks_msec()

func _process_chunk_unloads():
	var now = Time.get_ticks_msec()
	var to_remove: Array[Vector2i] = []

	for coords in unload_queue.keys():
		if now - unload_queue[coords] > CHUNK_UNLOAD_DELAY_MS:
			unload_chunk(coords)
			to_remove.append(coords)

	for coords in to_remove:
		unload_queue.erase(coords)

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

func get_chunks_with_planets_around(center_chunk: Vector2i, radius: int) -> Array[Vector2i]:
	var result: Array[Vector2i] = []

	for x in range(-radius, radius + 1):
		for y in range(-radius, radius + 1):
			var coords = center_chunk + Vector2i(x, y)
			var data = UniverseData.get_chunk_data(coords)
			if data.has("planet"):
				result.append(coords)

	return result

func transfer_asteroid_to_chunk(asteroid: Node2D, new_chunk_coords: Vector2i):
	if not active_chunks.has(new_chunk_coords):
		load_chunk(new_chunk_coords)

	var new_chunk = active_chunks[new_chunk_coords]
	var global_pos = asteroid.global_position
	asteroid.get_parent().remove_child(asteroid)
	new_chunk.add_child(asteroid)
	asteroid.global_position = global_pos
