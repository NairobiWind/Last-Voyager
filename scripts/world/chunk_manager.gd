extends Node2D

const CHUNK_SIZE = 2400
const PADDING_CHUNKS = 1  # margen extra

const ChunkScene = preload("res://scenes/world/Chunk.tscn")

var active_chunks = {}
var player: Node2D
var camera: Camera2D
var last_visible_rect := Rect2()

func _ready():
	player = get_parent().get_node("PlayerShip")
	camera = get_viewport().get_camera_2d()
	_update_chunks()

func _process(_delta):
	if camera:
		var visible_rect = get_camera_visible_rect()
		if visible_rect != last_visible_rect:
			last_visible_rect = visible_rect
			_update_chunks()

func get_camera_visible_rect() -> Rect2:
	var screen_size = get_viewport_rect().size
	var top_left = camera.global_position - (screen_size / 2)
	var rect = Rect2(top_left, screen_size)
	return rect.grow(CHUNK_SIZE * PADDING_CHUNKS)

func _update_chunks():
	var from = get_chunk_coords(last_visible_rect.position)
	var to = get_chunk_coords(last_visible_rect.end)

	var required_chunks := {}

	for x in range(from.x, to.x + 1):
		for y in range(from.y, to.y + 1):
			var coords = Vector2i(x, y)
			required_chunks[coords] = true
			if not active_chunks.has(coords):
				load_chunk(coords)

	# Descargar chunks que ya no se ven
	for coords in active_chunks.keys():
		if not required_chunks.has(coords):
			unload_chunk(coords)

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
