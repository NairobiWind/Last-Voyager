# res://scripts/world/SectorChunk.gd
extends Node2D

@export var chunk_coords    : Vector2i    = Vector2i.ZERO
@export var min_asteroids   : int         = 5
@export var max_asteroids   : int         = 12
@export var speed_range     : Vector2     = Vector2(20, 90)
@export var rot_speed_range : Vector2     = Vector2(-2.0, 2.0)
@export var scale_range     : Vector2     = Vector2(0.6, 1.4)

const CHUNK_SIZE    : int         = 2400
const AsteroidScene = preload("res://scenes/entities/Asteroid.tscn")
const PlanetScene   = preload("res://scenes/entities/Planet.tscn")

func _ready() -> void:
	var rng = RandomNumberGenerator.new()
	rng.seed = int(chunk_coords.x) * 73856093 ^ int(chunk_coords.y) * 19349663

	# —–– Planeta —––––––––––––––––––––––––––––––––
	var logic = UniverseData.get_chunk_data(chunk_coords)
	if logic.has("planet"):
		var planet = PlanetScene.instantiate()
		planet.planet_data = logic["planet"]
		planet.position    = Vector2(CHUNK_SIZE, CHUNK_SIZE) * 0.5
		planet.scale       = Vector2.ONE * rng.randf_range(scale_range.x, scale_range.y)
		planet.add_to_group("planets")
		add_child(planet)

	# —–– Asteroides —–––––––––––––––––––––––––––––––
	var count    = rng.randi_range(min_asteroids, max_asteroids)
	var spawned  = 0
	for i in range(count):
		# Permite siempre al menos min_asteroids
		if GameState.active_asteroids >= GameState.regeneration_threshold \
		and spawned >= min_asteroids:
			break

		var ast = AsteroidScene.instantiate()

		# 1) Asignar material (incluye durabilidad, color y damage)
		ast.asteroid_material = AsteroidResources.get_random_material(rng)

		# 2) Posición aleatoria dentro del chunk
		ast.position = Vector2(
			rng.randf_range(0, CHUNK_SIZE),
			rng.randf_range(0, CHUNK_SIZE)
		)

		# 3) Física sin gravedad, velocidad 360°
		var ang   = rng.randf() * TAU
		var speed = rng.randf_range(speed_range.x, speed_range.y)
		if ast is RigidBody2D:
			ast.gravity_scale     = 0
			ast.linear_velocity   = Vector2(cos(ang), sin(ang)) * speed
			ast.angular_velocity  = rng.randf_range(rot_speed_range.x, rot_speed_range.y)
		else:
			ast.velocity       = Vector2(cos(ang), sin(ang)) * speed
			ast.rotation_speed = rng.randf_range(rot_speed_range.x, rot_speed_range.y)

		# 4) Escala variable
		ast.scale = Vector2.ONE * rng.randf_range(scale_range.x, scale_range.y)

		# 5) Señal de destrucción
		if ast.has_signal("destroyed"):
			ast.connect("destroyed", Callable(self, "_on_asteroid_destroyed"))

		add_child(ast)
		GameState.active_asteroids += 1
		spawned += 1

func _on_asteroid_destroyed() -> void:
	GameState.active_asteroids = max(GameState.active_asteroids - 1, 0)
