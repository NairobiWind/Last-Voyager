extends Node2D

@export var asteroid_scene: PackedScene  # No se inicializa aquí
@export var number_of_asteroids: int = 8
@export var spawn_radius: float = 300.0
@export var spread_angle_deg: float = 360.0
@export var speed_range: Vector2 = Vector2(80, 160)

func _ready():
	spawn_asteroid_group(global_position)

func spawn_asteroid_group(center: Vector2):
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	for i in range(number_of_asteroids):
		if asteroid_scene == null:
			push_error("Asteroid scene not assigned!")
			return

		var asteroid = asteroid_scene.instantiate()

		var angle_deg = rng.randf_range(-spread_angle_deg / 2, spread_angle_deg / 2)
		var angle = deg_to_rad(angle_deg)

		var offset = Vector2.RIGHT.rotated(angle) * rng.randf_range(spawn_radius * 0.7, spawn_radius)
		asteroid.global_position = center + offset

		var direction = offset.normalized().rotated(rng.randf_range(-0.1, 0.1))
		var speed = rng.randf_range(speed_range.x, speed_range.y)
		asteroid.velocity = direction * speed

		call_deferred("add_child", asteroid)
