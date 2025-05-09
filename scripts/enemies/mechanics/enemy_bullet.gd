extends Area2D

@export var speed: float = 1000.0
@export var lifetime: float = 4.0

var velocity: Vector2 = Vector2.ZERO
var time_passed: float = 0.0
var target_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	z_index = 10
	add_to_group("enemy_bullets")

	# Habilitar _process para que la bala se mueva y expire
	set_process(true)

	# Dirección hacia el jugador
	if target_position != Vector2.ZERO:
		var dir = (target_position - global_position).normalized()
		velocity = dir * speed
	else:
		#push_warning("⚠️ target_position no asignado correctamente.")
		velocity = Vector2.RIGHT.rotated(rotation) * speed

	# Conexión de colisiones
	connect("body_entered", Callable(self, "_on_body_entered"))

func _process(delta: float) -> void:
	time_passed += delta
	position += velocity * delta

	# Rotación visual hacia la dirección de movimiento
	rotation = lerp_angle(rotation, velocity.angle(), 10.0 * delta)

	if time_passed > lifetime:
		queue_free()

func _on_body_entered(body: Node) -> void:
	# dañamos al jugador y al asteroide
	if body.is_in_group("player") and body.has_method("apply_damage"):
		body.apply_damage(1)
		queue_free()
	if body.is_in_group("asteroids") and body.has_method("apply_bullet_damage"):
		body.apply_bullet_damage(1)
		queue_free()
