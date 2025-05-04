extends Node2D

const CHUNK_SIZE = 2400
var chunk_coords = Vector2i.ZERO

func _ready():
	var logic = UniverseData.get_chunk_data(chunk_coords)

	if logic.has("planet"):
		var planet_scene = preload("res://scenes/entities/Planet.tscn")
		var planet = planet_scene.instantiate()
		planet.planet_data = logic["planet"]
		planet.position = Vector2(float(CHUNK_SIZE) / 2.0, float(CHUNK_SIZE) / 2.0)
		call_deferred("add_child", planet)

	if logic.has("asteroids"):
		var scene = preload("res://scenes/entities/Asteroid.tscn")
		for asteroid_data in logic["asteroids"]:
			var asteroid = scene.instantiate()
			asteroid.position = asteroid_data["offset"] + Vector2(CHUNK_SIZE * 0.5, CHUNK_SIZE * 0.5)
			asteroid.velocity = Vector2.RIGHT.rotated(asteroid_data["velocity_angle"]) * asteroid_data["speed"]
			asteroid.size_index = asteroid_data["size"]
			asteroid.asteroid_material = asteroid_data["material"]
			add_child(asteroid)
