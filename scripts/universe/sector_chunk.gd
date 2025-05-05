extends Node2D

const CHUNK_SIZE = 2400
var chunk_coords = Vector2i.ZERO

func _ready():
	var logic = UniverseData.get_chunk_data(chunk_coords)

	# Planeta
	if logic.has("planet"):
		var planet_scene = preload("res://scenes/entities/Planet.tscn")
		var planet = planet_scene.instantiate()
		planet.planet_data = logic["planet"]
		# Usamos multiplicación para evitar división entera
		planet.position = Vector2(CHUNK_SIZE * 0.5, CHUNK_SIZE * 0.5)
		call_deferred("add_child", planet)

		# 🔄 Escala visual aleatoria pero consistente
		var scale_rng = RandomNumberGenerator.new()
		scale_rng.seed = logic["planet"]["seed"]
		var scale = scale_rng.randf_range(0.7, 1.4)
		planet.scale = Vector2.ONE * scale

		call_deferred("add_child", planet)
		
	# Asteroides con control de regeneración
	if logic.has("asteroids"):
		var scene = preload("res://scenes/entities/Asteroid.tscn")
		for asteroid_data in logic["asteroids"]:
			# Solo instanciar si estamos por debajo del umbral
			if GameState.active_asteroids < GameState.regeneration_threshold:
				var asteroid = scene.instantiate()
				# Posición relativa al centro del chunk usando float
				asteroid.position = asteroid_data["offset"] + Vector2(CHUNK_SIZE * 0.5, CHUNK_SIZE * 0.5)

				# Dirección normalizada y velocidad
				var direction = Vector2.RIGHT.rotated(asteroid_data["velocity_angle"]).normalized()
				asteroid.velocity = direction * asteroid_data["speed"]

				# Propiedades del asteroide
				asteroid.size_index = asteroid_data["size"]
				asteroid.asteroid_material = asteroid_data["material"]

				# Conectar señal de destrucción para decrementar contador
				if asteroid.has_signal("destroyed"):
					asteroid.connect("destroyed", Callable(self, "_on_asteroid_destroyed"))

				add_child(asteroid)
				GameState.active_asteroids += 1
func _exit_tree():
	# Antes de que se destruya el chunk, decrementamos el total si quedan asteroides activos
	for asteroid in get_children():
		if asteroid.is_in_group("asteroids"):
			GameState.active_asteroids = max(0, GameState.active_asteroids - 1)

# Función de callback para cuando un asteroide se destruye
func _on_asteroid_destroyed():
	GameState.active_asteroids = max(0, GameState.active_asteroids - 1)
