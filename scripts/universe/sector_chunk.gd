# res://scripts/world/SectorChunk.gd
extends Node2D

@export var chunk_coords    : Vector2i = Vector2i.ZERO
@export var min_asteroids   : int = 5
@export var max_asteroids   : int = 12
@export var speed_range     : Vector2 = Vector2(20, 90)
@export var rot_speed_range : Vector2 = Vector2(-2.0, 2.0)
@export var scale_range     : Vector2 = Vector2(0.6, 1.4)

const CHUNK_SIZE     : int = 2400
const AsteroidScene  = preload("res://scenes/entities/Asteroid.tscn")
const PlanetScene    = preload("res://scenes/entities/Planet.tscn")

func _ready() -> void:
	var rng = RandomNumberGenerator.new()
	rng.seed = int(chunk_coords.x) * 73856093 ^ int(chunk_coords.y) * 19349663

	# Obtener datos del universo
	var data = UniverseData.get_chunk_data(chunk_coords)

	# —–– Planeta —––––––––––––––––––––––––––––––––
	if data.has("planet"):
		MapManager.discover_chunk(chunk_coords)
		_generate_planet(data["planet"])

	# —–– Asteroides —–––––––––––––––––––––––––––––––
	var count   = rng.randi_range(min_asteroids, max_asteroids)
	var spawned = 0
	for i in range(count):
		if GameState.active_asteroids >= GameState.regeneration_threshold and spawned >= min_asteroids:
			break

		var ast = AsteroidScene.instantiate()

		# Material procedural
		ast.asteroid_material = AsteroidResources.get_random_material(rng)

		# Posición dentro del chunk
		ast.position = Vector2(
			rng.randf_range(0, CHUNK_SIZE),
			rng.randf_range(0, CHUNK_SIZE)
		)

		# Movimiento
		var ang   = rng.randf() * TAU
		var speed = rng.randf_range(speed_range.x, speed_range.y)
		if ast is RigidBody2D:
			ast.gravity_scale    = 0
			ast.linear_velocity  = Vector2(cos(ang), sin(ang)) * speed
			ast.angular_velocity = rng.randf_range(rot_speed_range.x, rot_speed_range.y)
		else:
			ast.velocity       = Vector2(cos(ang), sin(ang)) * speed
			ast.rotation_speed = rng.randf_range(rot_speed_range.x, rot_speed_range.y)

		# Escala procedural
		ast.scale = Vector2.ONE * rng.randf_range(scale_range.x, scale_range.y)

		# Destrucción
		if ast.has_signal("destroyed"):
			ast.connect("destroyed", Callable(self, "_on_asteroid_destroyed"))

		add_child(ast)
		GameState.active_asteroids += 1
		spawned += 1

func _generate_planet(data: Dictionary) -> void:
	var planet = PlanetScene.instantiate()
	planet.planet_data = data
	planet.position = Vector2(CHUNK_SIZE, CHUNK_SIZE) * 0.5

	var scale_rng = RandomNumberGenerator.new()
	scale_rng.seed = int(data.get("seed", 12345)) ^ 918273
	planet.scale = Vector2.ONE * scale_rng.randf_range(scale_range.x, scale_range.y)

	planet.add_to_group("planets")
	add_child(planet)

func _on_asteroid_destroyed() -> void:
	GameState.active_asteroids = max(GameState.active_asteroids - 1, 0)
