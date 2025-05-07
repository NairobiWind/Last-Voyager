# res://scripts/world/SectorChunk.gd
extends Node2D

# Índice de chunk (Vector2i)
@export var chunk_coords: Vector2i = Vector2i.ZERO

# — Parámetros ajustables desde el Inspector —
@export var max_asteroids_in_chunk: int = 20   # Máx asteroides por chunk
@export var speed_multiplier: float = 0.1      # Escala la velocidad de cada asteroide
@export var global_asteroid_limit: int = 200   # Límite global (GameState.regeneration_threshold)

const CHUNK_SIZE: int = 2400

func _ready() -> void:
	var center = Vector2(CHUNK_SIZE * 0.5, CHUNK_SIZE * 0.5)
	var logic: Dictionary = UniverseData.get_chunk_data(chunk_coords)

	# — Planeta procedural (igual que antes) —
	if logic.has("planet"):
		var PlanetScene = preload("res://scenes/entities/Planet.tscn")
		var planet = PlanetScene.instantiate()
		planet.planet_data = logic["planet"]
		planet.position = center
		add_child(planet)

		var rng = RandomNumberGenerator.new()
		rng.seed = logic["planet"]["seed"]
		planet.scale = Vector2.ONE * rng.randf_range(0.7, 1.4)

	# — Asteroides procedural —
	if logic.has("asteroids"):
		var AsteroidScene = preload("res://scenes/entities/Asteroid.tscn")
		# solo hasta max_asteroids_in_chunk
		var count = min(max_asteroids_in_chunk, logic["asteroids"].size())
		for i in range(count):
			# respeta el límite global
			if GameState.active_asteroids >= global_asteroid_limit:
				break

			var data = logic["asteroids"][i]
			var ast = AsteroidScene.instantiate()

			ast.position = data["offset"] + center

			# si tu Asteroid usa linear_velocity (RigidBody2D),
			# o velocity (Area2D/CharacterBody2D), ajusta según su API:
			if ast.has_method("set_linear_velocity"):
				ast.linear_velocity = Vector2.RIGHT.rotated(data["velocity_angle"]) \
										* data["speed"] * speed_multiplier
			elif ast.has_variable("velocity"):
				ast.velocity = Vector2.RIGHT.rotated(data["velocity_angle"]) \
								* data["speed"] * speed_multiplier

			ast.size_index = data["size"]
			ast.asteroid_material = data["material"]

			if ast.has_signal("destroyed"):
				ast.connect("destroyed", Callable(self, "_on_asteroid_destroyed"))

			add_child(ast)
			GameState.active_asteroids += 1

func _exit_tree() -> void:
	# al desmontar el chunk, descontar sus asteroides
	for c in get_children():
		if c.is_in_group("asteroids"):
			GameState.active_asteroids = max(GameState.active_asteroids - 1, 0)

func _on_asteroid_destroyed() -> void:
	GameState.active_asteroids = max(GameState.active_asteroids - 1, 0)
