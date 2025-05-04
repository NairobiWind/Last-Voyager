extends Node2D

const CHUNK_SIZE = 2400
var chunk_coords = Vector2i.ZERO
const STAR_COUNT = 50
const AREA_SIZE = 2600.0

func _ready():
	queue_redraw()
	generate_chunk_content()

func _draw():
	# Dibuja el borde del chunk
	var size = Vector2(CHUNK_SIZE, CHUNK_SIZE)
	draw_rect(Rect2(Vector2.ZERO, size), Color(1, 1, 1, 0.1), false, 2.0)

	# Dibuja el texto sin color modulado
	var text = "Chunk: %s, %s" % [chunk_coords.x, chunk_coords.y]
	var font = ThemeDB.fallback_font
	draw_string(font, Vector2(20, 40), text)

func generate_chunk_content():
	var rng = RandomNumberGenerator.new()
	rng.seed = hash(chunk_coords)

	for i in STAR_COUNT:
		var star = Sprite2D.new()
		star.texture = preload("res://assets/sprites/ship/Kenny Simple Space/PNG/Retina/star_small.png")
		star.modulate = Color(1, 1, 1, rng.randf_range(0.3, 1.0))
		star.position = Vector2(rng.randf_range(0, CHUNK_SIZE), rng.randf_range(0, CHUNK_SIZE))
		star.scale = Vector2.ONE * rng.randf_range(0.3, 0.6)
		add_child(star)
		
		
