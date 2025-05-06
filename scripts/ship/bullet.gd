# res://scenes/ship/bullet.gd
extends Area2D

@export var speed: float = 1000.0
@export var lifetime: float = 4.0

var velocity: Vector2 = Vector2.ZERO
var time_passed := 0.0
var target_position: Vector2 = Vector2.ZERO
var direction: Vector2

func _ready() -> void:
	z_index = 10
	add_to_group("bullets")
	# Calcula la dirección usando target_position asignado por PlayerShip
	direction = (target_position - global_position).normalized()
	velocity  = direction * speed
	connect("area_entered", Callable(self, "_on_area_entered"))

func _process(delta: float) -> void:
	time_passed += delta
	position += velocity * delta
	# Ajusta la rotación hacia la trayectoria
	rotation = lerp_angle(rotation, velocity.angle(), 10.0 * delta)
	if time_passed > lifetime:
		queue_free()

func _on_area_entered(area: Node) -> void:
	if area.is_in_group("asteroids"):
		queue_free()
