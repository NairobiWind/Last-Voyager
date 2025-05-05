extends CharacterBody2D

@onready var camera := $Camera2D
@onready var loot_collector := $LootCollector
var bullet_scene: PackedScene = preload("res://scenes/ship/bullet.tscn")

const MAX_SPEED = 600.0
const ACCELERATION = 600.0
const INITIAL_PUSH = 100.0
const FRICTION = 100.0
const BRAKE_FORCE = 300.0

var pushing = false
var just_pushed = false
var inventory := {}

func _ready():
	camera.zoom = Vector2(1, 1)
	camera.position = Vector2.ZERO
	camera.make_current()

	# 🟡 Conectar la señal de loot
	#if loot_collector:
	#	loot_collector.connect("area_entered", Callable(self, "_on_loot_collector_area_entered"))

func _physics_process(delta):
	GameStats.consume_thrust(delta)
	z_index = 10

	var mouse_pos = get_global_mouse_position()
	var target_angle = (mouse_pos - global_position).angle()
	rotation = lerp_angle(rotation, target_angle, 5.0 * delta)

	var direction = Vector2.RIGHT.rotated(rotation)

	if GameStats.fuel > 0.0:
		if Input.is_action_just_pressed("ui_up"):
			velocity += direction * INITIAL_PUSH
			just_pushed = true
			pushing = true
		elif Input.is_action_pressed("ui_up"):
			velocity += direction * ACCELERATION * delta
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

	var forward = Vector2.RIGHT.rotated(rotation)
	var aligned_velocity = forward * velocity.dot(forward)
	velocity = lerp(velocity, aligned_velocity, 0.05)

	$ThrustParticles.emitting = Input.is_action_pressed("ui_up") and GameStats.fuel > 0.0

	move_and_slide()
	handle_shooting()

func handle_shooting():
	if Input.is_action_just_pressed("ui_left") and GameStats.fuel > 0.0 and GameStats.consume_shoot():
		var bullet = bullet_scene.instantiate()
		var fire_direction = Vector2.RIGHT.rotated(rotation)
		var spawn_pos = global_position + fire_direction * 60.0

		bullet.global_position = spawn_pos
		bullet.velocity = fire_direction * bullet.speed
		bullet.rotation = fire_direction.angle()
		bullet.target_position = get_global_mouse_position()
		get_parent().add_child(bullet)

# ✅ Señal conectada al área de recolección de loot
func _on_loot_collector_area_entered(area: Area2D) -> void:
	print("📦 Entrando en zona de loot:", area)

	if not area.is_in_group("loot"):
		print("⛔ No es loot.")
		return

	if not area.has_method("get_resource_data"):
		print("⛔ No tiene método get_resource_data.")
		return

	var data = area.get_resource_data()
	print("📋 Datos obtenidos del loot:", data)

	if not data or not data.has("name") or not data.has("amount"):
		print("❌ Datos inválidos:", data)
		return

	var resource_name = data["name"]
	var amount = data["amount"]

	# Guardar en inventario local
	if inventory.has(resource_name):
		inventory[resource_name] += amount
	else:
		inventory[resource_name] = amount

	print("🪙 Añadido al inventario local:", resource_name, "+", amount)

	# Guardar también en el inventario global
	if Engine.has_singleton("GameState"):
		GameState.add_loot(resource_name, amount)

	area.queue_free()
