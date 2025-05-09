extends Area2D

@export var speed: float = 1000.0
@export var lifetime: float = 4.0
@export var damage: int = 50

var velocity: Vector2 = Vector2.ZERO
var time_passed: float = 0.0
var target_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	# Aseguramos que el Area2D detecta cuerpos físicos
	monitoring = true
	monitorable = true

	z_index = 10
	add_to_group("bullets")

	# Calculamos la dirección de la bala
	if target_position != Vector2.ZERO:
		velocity = (target_position - global_position).normalized() * speed
	else:
		push_warning("⚠️ target_position no asignado correctamente.")
		velocity = Vector2.RIGHT.rotated(rotation) * speed

	# Conectamos la señal _antes_ de movernos
	connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(delta: float) -> void:
	# Movemos en el paso de física
	global_position += velocity * delta
	time_passed += delta

	# Orientación visual
	rotation = lerp_angle(rotation, velocity.angle(), 10.0 * delta)

	# Tiempo de vida
	if time_passed > lifetime:
		queue_free()

func _on_body_entered(body: Node) -> void:
	# 1) Asteroides
	if body.is_in_group("asteroids") and body.has_method("apply_bullet_damage"):
		body.apply_bullet_damage(damage)
		queue_free()
	# 2) Enemigos
	elif body.is_in_group("enemies") and body.has_method("apply_damage"):
		body.apply_damage(damage)
		queue_free()
