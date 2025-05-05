# res://scripts/world/SectorChunk.gd
extends Node2D

@export var chunk_coords: Vector2i = Vector2i.ZERO  # Índice del chunk, e.g. (x,y)
const CHUNK_SIZE: int = 2400

func _ready() -> void:
	# Obtener datos lógicos para este chunk (planetas, asteroides, etc.)
	var logic: Dictionary = UniverseData.get_chunk_data(chunk_coords)

	# --- GENERACIÓN DEL PLANETA ---
	if logic.has("planet"):
		var PlanetScene: PackedScene = preload("res://scenes/entities/Planet.tscn")
		var planet = PlanetScene.instantiate()
		planet.planet_data = logic["planet"]
		planet.position = Vector2(CHUNK_SIZE * 0.5, CHUNK_SIZE * 0.5)
		add_child(planet)

		var rng = RandomNumberGenerator.new()
		rng.seed = logic["planet"]["seed"]
		planet.scale = Vector2.ONE * rng.randf_range(0.7, 1.4)

	# --- GENERACIÓN DE ASTEROIDES HASTA EL UMBRAL GLOBAL ---
	if logic.has("asteroids"):
		var AsteroidScene: PackedScene = preload("res://scenes/entities/Asteroid.tscn")
		for data in logic["asteroids"]:
			# Control de límite global de asteroides
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
			GameState.active_asteroids += 1  # Incremento directo del contador

func _exit_tree() -> void:
	# Al desmontar el chunk, descontar todos sus asteroides del total global
	for child in get_children():
		if child.is_in_group("asteroids"):
			GameState.active_asteroids = max(GameState.active_asteroids - 1, 0)

func _on_asteroid_destroyed() -> void:
	# Callback: un asteroide ha sido destruido, actualizar contador global
	GameState.active_asteroids = max(GameState.active_asteroids - 1, 0)
