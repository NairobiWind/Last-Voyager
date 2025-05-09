extends Node

var universes: Dictionary = {}  # universe_id → chunk_cache
var current_universe_id: String = "default"

func set_current_universe(universe_id: String) -> void:
	current_universe_id = universe_id

func reset_universe_cache(universe_id: String) -> void:
	universes.erase(universe_id)

func get_available_universes() -> Array:
	return universes.keys()

func get_current_chunk_cache() -> Dictionary:
	if not universes.has(current_universe_id):
		universes[current_universe_id] = {}
	return universes[current_universe_id]

func get_chunk_data(chunk_coords: Vector2i) -> Dictionary:
	var cache = get_current_chunk_cache()
	if cache.has(chunk_coords):
		#print("✅ Caché usada para", current_universe_id, chunk_coords)
		return cache[chunk_coords]

	var rng = RandomNumberGenerator.new()
	rng.seed = hash(chunk_coords)

	var data := {}

	# 🌍 Generación de planeta
	if rng.randf() < 0.05:
		var planet_seed = hash(chunk_coords * Vector2i(13, 47))
		var base_seed = hash(chunk_coords * Vector2i(71, 23))
		var illum_index = abs(hash(chunk_coords * Vector2i(5, 89))) % 11
		var terrain_index = abs(hash(chunk_coords * Vector2i(33, 17))) % 28
		var atmo_index = abs(hash(chunk_coords * Vector2i(91, 7))) % 28
		var atmo_seed = hash(chunk_coords * Vector2i(41, 59))

		data["planet"] = {
			"seed": planet_seed,
			"base_seed": base_seed,
			"illum_index": illum_index,
			"terrain_index": terrain_index,
			"atmo_index": atmo_index,
			"atmo_seed": atmo_seed,
			"name": "PX-%04d" % (abs(planet_seed) % 10000)
		}

		print("🌍 Planeta generado en", current_universe_id, "chunk:", chunk_coords)

	# 👾 Enemigos
	if rng.randf() < 0.02:
		data["enemies"] = rng.randi_range(1, 4)

	# 🪨 Grupo de asteroides
	if rng.randf() < 0.6:
		var asteroids := []
		var group_seed = hash(chunk_coords * Vector2i(99, 37))
		var group_rng = RandomNumberGenerator.new()
		group_rng.seed = group_seed

		var count = group_rng.randi_range(4, 12)
		for i in count:
			var angle = group_rng.randf_range(0, TAU)
			var distance = group_rng.randf_range(100.0, 400.0)
			var offset = Vector2.RIGHT.rotated(angle) * distance

			var material = AsteroidResources.get_random_material(group_rng)

			asteroids.append({
				"offset": offset,
				"velocity_angle": angle + group_rng.randf_range(-0.3, 0.3),
				"speed": group_rng.randf_range(60.0, 140.0),
				"size": group_rng.randi_range(0, 7),
				"material": material
			})

		data["asteroids"] = asteroids

	# Guardar en caché
	cache[chunk_coords] = data
	return data
