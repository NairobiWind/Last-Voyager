extends Node

# Guarda los chunks descubiertos (clave = "x,y")
var discovered_chunks: Dictionary = {}
# Guarda los chunks actualmente cargados en escena
var active_chunks: Array = []
# Lista de coords de chunks que contienen planetas (cacheada)
var planet_chunks: Array = []

signal chunk_discovered(chunk_coords: Vector2i)

func discover_chunk(coords: Vector2i) -> void:
	var key := "%d,%d" % [coords.x, coords.y]
	if discovered_chunks.has(key):
		return
	discovered_chunks[key] = true
	emit_signal("chunk_discovered", coords)

	# Cachear planeta si existe
	var data = UniverseData.get_chunk_data(coords)
	if data.has("planet"):
		planet_chunks.append(coords)

func register_active_chunk(coords: Vector2i) -> void:
	if coords not in active_chunks:
		active_chunks.append(coords)

func unregister_active_chunk(coords: Vector2i) -> void:
	active_chunks.erase(coords)
