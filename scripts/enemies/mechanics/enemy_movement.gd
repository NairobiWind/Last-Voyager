extends Node
class_name EnemyMovement

@export var speed: float = 200.0            # Velocidad máxima
@export var min_distance: float = 100.0     # Límite interior de la zona de combate
@export var max_distance: float = 200.0     # Límite exterior de la zona de combate
@export var acceleration: float = 500.0     # Aceleración por segundo
@export var rotation_speed: float = 5.0     # Velocidad de giro (rad/s)
@export var orbit_speed: float = 1.5        # Velocidad angular de la órbita (rad/s)
@export var dodge_amplitude: float = 50.0   # Amplitud de la oscilación lateral
@export var dodge_frequency: float = 2.0    # Frecuencia de la oscilación (osc./s)

var ship: CharacterBody2D
var target: Node2D

var _velocity: Vector2 = Vector2.ZERO
var _orbit_angle: float = 0.0
var _dodge_time: float = 0.0

func setup(ship_ref: CharacterBody2D, target_ref: Node2D) -> void:
	ship = ship_ref
	target = target_ref

func process(delta: float) -> void:
	if not target or not target.is_inside_tree():
		return

	# Vector crudo y normalizado al jugador
	var to_target = target.global_position - ship.global_position
	var dist = to_target.length()
	var dir = to_target.normalized()

	# 1) Rotación suave mirando al jugador
	var angle_diff = wrapf(dir.angle() - ship.rotation, -PI, PI)
	ship.rotation += clamp(angle_diff, -rotation_speed * delta, rotation_speed * delta)

	# Actualizamos tiempo para la oscilación
	_dodge_time += delta

	var desired_vel: Vector2

	if dist > max_distance:
		# --- Persecución con zig-zag lateral ---
		var perp = Vector2(-dir.y, dir.x)
		var wave = perp * sin(_dodge_time * dodge_frequency * TAU) * dodge_amplitude
		desired_vel = dir * speed + wave

	elif dist < min_distance:
		# --- Retroceso con zig-zag lateral ---
		var perp = Vector2(-dir.y, dir.x)
		var wave = perp * sin(_dodge_time * dodge_frequency * TAU) * dodge_amplitude
		desired_vel = -dir * speed + wave

	else:
		# --- Órbita alrededor del jugador ---
		_orbit_angle += orbit_speed * delta
		# Radio medio de la zona de combate
		var orbit_radius = (min_distance + max_distance) * 0.5
		# Offset circular
		var orbit_offset = Vector2.RIGHT.rotated(_orbit_angle) * orbit_radius
		var goal = target.global_position + orbit_offset
		var move_dir = (goal - ship.global_position).normalized()
		desired_vel = move_dir * speed

	# 2) Aceleración limitada para suavizar cambios bruscos
	_velocity = _velocity.move_toward(desired_vel, acceleration * delta)
	ship.velocity = _velocity

	# 3) Mover
	ship.move_and_slide()
