extends CharacterBody2D
class_name PlayerShip

@export var bullet_scene: PackedScene = preload("res://scenes/ship/bullet.tscn")

@onready var camera: Camera2D = $Camera2D
@onready var loot_collector: Area2D = $LootCollector
@onready var thrust_particles: GPUParticles2D = $ThrustParticles

const MAX_SPEED: float = 600.0
const ACCELERATION: float = 600.0
const INITIAL_PUSH: float = 100.0
const FRICTION: float = 100.0
const BRAKE_FORCE: float = 300.0

var pushing: bool = false
var just_pushed: bool = false

func _ready() -> void:
	camera.zoom = Vector2.ONE
	camera.position = Vector2.ZERO
	camera.make_current()

	if not loot_collector.is_connected("area_entered", Callable(self, "_on_loot_collector_area_entered")):
		loot_collector.connect("area_entered", Callable(self, "_on_loot_collector_area_entered"))

	global_position = GameState.last_position
	GameStats.fuel = GameState.last_fuel

func _physics_process(delta: float) -> void:
	GameStats.consume_thrust(delta)
	z_index = 10

	var mp: Vector2 = get_global_mouse_position()
	rotation = lerp_angle(rotation, (mp - global_position).angle(), 5.0 * delta)

	var dir: Vector2 = Vector2.RIGHT.rotated(rotation)
	if GameStats.fuel > 0.0:
		if Input.is_action_just_pressed("ui_up"):
			velocity += dir * INITIAL_PUSH
			just_pushed = true; pushing = true
		elif Input.is_action_pressed("ui_up"):
			velocity += dir * ACCELERATION * delta
			pushing = true
		else:
			pushing = false
	else:
		pushing = false

	if Input.is_action_pressed("brake"):
		velocity = velocity.move_toward(Vector2.ZERO, BRAKE_FORCE * delta)
	elif not pushing:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	if velocity.length() > MAX_SPEED:
		velocity = velocity.normalized() * MAX_SPEED

	var fwd: Vector2 = Vector2.RIGHT.rotated(rotation)
	var aligned: Vector2 = fwd * velocity.dot(fwd)
	velocity = lerp(velocity, aligned, 0.05)

	thrust_particles.emitting = pushing and GameStats.fuel > 0.0

	move_and_slide()
	_handle_shooting()

	GameState.last_position = global_position
	GameState.last_fuel = GameStats.fuel

func _handle_shooting() -> void:
	if Input.is_action_just_pressed("ui_left") and GameStats.fuel > 0.0 and GameStats.consume_shoot():
		var b = bullet_scene.instantiate()
		var dir = Vector2.RIGHT.rotated(rotation)
		b.global_position = global_position + dir * 60.0
		b.velocity = dir * b.speed
		b.rotation = dir.angle()
		b.target_position = get_global_mouse_position()
		get_parent().add_child(b)

func _on_loot_collector_area_entered(area: Area2D) -> void:
	if not area.is_in_group("loot") or not area.has_method("get_resource_data"):
		return
	var data = area.get_resource_data()
	if not data.has("name") or not data.has("amount"):
		return
	GameState.add_loot(data["name"], data["amount"])
	area.queue_free()
