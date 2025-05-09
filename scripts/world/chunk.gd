extends Node2D

const CHUNK_SIZE: int = 2400
const STAR_COUNT: int = 50
const STAR_BASE_SIZE: int = 128
const STAR_TEXTURE: Texture2D = preload("res://assets/sprites/ship/Kenny Simple Space/PNG/Retina/star_small.png")

var chunk_coords: Vector2i = Vector2i.ZERO
var multimesh_instance: MultiMeshInstance2D

# 🌌 Cache global compartida
static var multimesh_cache: Dictionary = {}

# Toggle para debug: dibujar bordes y etiquetas de chunks
@export var show_debug: bool = false

func _ready():
	if multimesh_cache.has(chunk_coords):
		# ✅ Reutilizar multimesh del cache
		multimesh_instance = MultiMeshInstance2D.new()
		multimesh_instance.multimesh = multimesh_cache[chunk_coords]
		multimesh_instance.texture = STAR_TEXTURE
		add_child(multimesh_instance)
	else:
		# 🚀 Generar y guardar en cache
		generate_stars()
	
	# Si debug activado, forzar redraw
	if show_debug:
		queue_redraw()

func generate_stars():
	multimesh_instance = MultiMeshInstance2D.new()
	add_child(multimesh_instance)

	var quad := QuadMesh.new()
	quad.size = Vector2.ONE

	var mm := MultiMesh.new()
	mm.mesh = quad
	mm.transform_format = MultiMesh.TRANSFORM_2D
	mm.use_colors = true
	mm.instance_count = STAR_COUNT

	multimesh_instance.multimesh = mm
	multimesh_instance.texture = STAR_TEXTURE

	var rng := RandomNumberGenerator.new()
	rng.seed = hash(chunk_coords)

	for i in STAR_COUNT:
		var x = rng.randf_range(0, CHUNK_SIZE)
		var y = rng.randf_range(0, CHUNK_SIZE)
		var star_scale = rng.randf_range(0.3, 0.6)
		var rot = rng.randf_range(0, TAU)

		var xf := Transform2D()
		xf = xf.scaled(Vector2(STAR_BASE_SIZE * star_scale, STAR_BASE_SIZE * star_scale))
		xf = xf.rotated(rot)
		xf.origin = Vector2(x, y)

		mm.set_instance_transform_2d(i, xf)
		mm.set_instance_color(i, Color(1, 1, 1, rng.randf_range(0.3, 1.0)))

	# 💾 Guardar el multimesh original en el cache
	multimesh_cache[chunk_coords] = mm

func _draw():
	if not show_debug:
		return
	# Dibujar borde del chunk
	draw_rect(
		Rect2(Vector2.ZERO, Vector2(CHUNK_SIZE, CHUNK_SIZE)),
		Color(1, 1, 1, 0.1),
		false,
		2.0
	)
	# Etiqueta de coordenadas
	var font := ThemeDB.fallback_font
	var label := "Chunk: %d, %d" % [chunk_coords.x, chunk_coords.y]
	var text_pos := Vector2(20, 40)
	draw_string(font, text_pos, label)

func _process(_delta: float) -> void:
	# Si togglean show_debug en tiempo de ejecución, actualizar
	if Engine.is_editor_hint():
		return
	if show_debug:
		queue_redraw()
