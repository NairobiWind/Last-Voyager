# res://scenes/ship/bullet.gd
extends Area2D

@export var speed: float    = 1000.0
@export var lifetime: float = 4.0

var velocity: Vector2 = Vector2.ZERO
var time_passed := 0.0
var target_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	z_index = 10
	add_to_group("bullets")
	velocity = (target_position - global_position).normalized() * speed
	# Conectamos con el cuerpo para detectar RigidBody2D
	connect("body_entered", Callable(self, "_on_body_entered"))

func _process(delta: float) -> void:
	time_passed += delta
	position += velocity * delta
	rotation = lerp_angle(rotation, velocity.angle(), 10.0 * delta)
	if time_passed > lifetime:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("asteroids") and body.has_method("apply_bullet_damage"):
		# Aplicamos 50 puntos de daño por bala
		body.apply_bullet_damage(50)
		queue_free()
