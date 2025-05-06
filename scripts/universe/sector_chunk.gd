extends Node2D
class_name SectorChunk

@export var chunk_coords: Vector2i = Vector2i.ZERO  # Índice del chunk (x,y)
const CHUNK_SIZE: int = 2400                        # Tamaño en unidades del chunk

func _ready() -> void:
	# Posicionar el SectorChunk en la cuadrícula:
	position = Vector2(chunk_coords.x * CHUNK_SIZE,
					   chunk_coords.y * CHUNK_SIZE)

	# Lógica procedural (planetas, asteroides...)
	var logic: Dictionary = UniverseData.get_chunk_data(chunk_coords)
	if logic.has("planet"):
		var PlanetScene: PackedScene = preload("res://scenes/entities/Planet.tscn")
		var planet = PlanetScene.instantiate()
		planet.planet_data = logic["planet"]
		planet.position = Vector2(CHUNK_SIZE * 0.5, CHUNK_SIZE * 0.5)
		add_child(planet)
		var rng := RandomNumberGenerator.new()
		rng.seed = logic["planet"]["seed"]
		planet.scale = Vector2.ONE * rng.randf_range(0.7, 1.4)
	if logic.has("asteroids"):
		var AsteroidScene: PackedScene = preload("res://scenes/entities/Asteroid.tscn")
		for data in logic["asteroids"]:
			if GameState.active_asteroids >= GameState.regeneration_threshold:
				break
			var ast = AsteroidScene.instantiate()
			ast.position = data["offset"] + Vector2(CHUNK_SIZE * 0.5, CHUNK_SIZE * 0.5)
			ast.velocity = Vector2.RIGHT.rotated(data["velocity_angle"]).normalized() * data["speed"]
			ast.size_index = data["size"]
			ast.asteroid_material = data["material"]
			if ast.has_signal("destroyed"):
				ast.connect("destroyed", Callable(self, "_on_asteroid_destroyed"))
			add_child(ast)
			GameState.active_asteroids += 1

	# Registrar en MapManager y actualizar dibujo
	var mm := get_node_or_null("/root/MapManager")
	if mm:
		mm.register_active_chunk(chunk_coords)
		mm.discover_chunk(chunk_coords)
	queue_redraw()

func _exit_tree() -> void:
	var mm := get_node_or_null("/root/MapManager")
	if mm:
		mm.unregister_active_chunk(chunk_coords)
	for child in get_children():
		if child.is_in_group("asteroids"):
			GameState.active_asteroids = max(GameState.active_asteroids - 1, 0)

func _on_asteroid_destroyed() -> void:
	GameState.active_asteroids = max(GameState.active_asteroids - 1, 0)

func _draw() -> void:
	# Marco rojo semitransparente 2px
	draw_rect(Rect2(Vector2.ZERO, Vector2(CHUNK_SIZE, CHUNK_SIZE)), Color(1,0,0,0.3), false, 10)
