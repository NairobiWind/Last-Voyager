# res://scenes/ship/PlayerShip.gd
extends CharacterBody2D
class_name PlayerShip

@export var bullet_scene   : PackedScene = preload("res://scenes/ship/Bullet.tscn")
@export var speed          : float       = 600.0
@export var joystick_path  : NodePath
@export var touchui_path   : NodePath

# Parámetros PC
const ACCELERATION: float = 600.0
const INITIAL_PUSH: float = 100.0
const FRICTION: float     = 100.0
const BRAKE_FORCE: float  = 300.0

# Umbral de joystick para empezar a acelerar (0.0–1.0)
const JOYSTICK_DEADZONE_ACCEL: float = 0.3

@onready var joystick      = get_node_or_null(joystick_path)
@onready var mobile_ctrls  = get_node_or_null(touchui_path)
@onready var mode_mgr      = get_node("/root/InputModeManager")
@onready var camera        = $Camera2D
@onready var loot_collector= $LootCollector
@onready var thrust_pts    = $ThrustParticles

func _ready() -> void:
	camera.zoom = Vector2.ONE
	camera.make_current()
	global_position = GameState.last_position
	GameStats.fuel   = GameState.last_fuel
	if not loot_collector.is_connected("area_entered", Callable(self, "_on_loot_collector_area_entered")):
		loot_collector.connect("area_entered", Callable(self, "_on_loot_collector_area_entered"))

func _process(_delta: float) -> void:
	if mobile_ctrls:
		mobile_ctrls.visible = mode_mgr.touch_mode

func _physics_process(delta: float) -> void:
	# Consume fuel según GameStats.consume_thrust
	GameStats.consume_thrust(delta)
	# Mantener la nave por encima
	z_index = 10

	if mode_mgr.touch_mode:
		_process_touch(delta)
	else:
		_process_pc(delta)

	move_and_slide()
	GameState.last_position = global_position
	GameState.last_fuel     = GameStats.fuel

func _process_touch(delta: float) -> void:
	if not joystick:
		velocity = Vector2.ZERO
		thrust_pts.emitting = false
		return

	var v   = joystick.get_vector()
	var mag = v.length()
	var dir_norm = v / mag if mag > 0.0 else Vector2.RIGHT

	# Rotación
	if mag > 0.01:
		rotation = lerp_angle(rotation, dir_norm.angle(), 10.0 * delta)

	# Aceleración vs deriva
	if mag > JOYSTICK_DEADZONE_ACCEL and GameStats.fuel > 0.0:
		# Empuje proporcional al mag
		velocity += dir_norm * ACCELERATION * delta * mag
	else:
		# No empujas: aplicamos fricción
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	# Límite de velocidad
	if velocity.length() > speed:
		velocity = velocity.normalized() * speed

	# Deriva: frena componente lateral
	var forward = Vector2.RIGHT.rotated(rotation)
	var aligned = forward * velocity.dot(forward)
	velocity = lerp(velocity, aligned, 0.05)

	# Partículas de thrust solo si empujas
	thrust_pts.emitting = (mag > JOYSTICK_DEADZONE_ACCEL and GameStats.fuel > 0.0)

	# Disparo táctil
	if Input.is_action_just_pressed("shoot") and GameStats.fuel > 0.0 and GameStats.consume_shoot():
		_shoot_bullet(true)

func _process_pc(delta: float) -> void:
	# Rotación hacia el ratón
	var mp     = get_global_mouse_position()
	var dir_pc = (mp - global_position).normalized()
	rotation   = lerp_angle(rotation, dir_pc.angle(), 5.0 * delta)

	# Empuje / freno con teclado
	if GameStats.fuel > 0.0:
		if Input.is_action_just_pressed("ui_up"):
			velocity += dir_pc * INITIAL_PUSH
			thrust_pts.emitting = true
		elif Input.is_action_pressed("ui_up"):
			velocity += dir_pc * ACCELERATION * delta
			thrust_pts.emitting = true
		else:
			thrust_pts.emitting = false
	else:
		thrust_pts.emitting = false

	if Input.is_action_pressed("brake"):
		velocity = velocity.move_toward(Vector2.ZERO, BRAKE_FORCE * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	if velocity.length() > speed:
		velocity = velocity.normalized() * speed

	if Input.is_action_just_pressed("shoot") and GameStats.fuel > 0.0 and GameStats.consume_shoot():
		_shoot_bullet(false)

func _shoot_bullet(is_touch: bool) -> void:
	var b   = bullet_scene.instantiate()
	var dir : Vector2

	if is_touch:
		dir = Vector2.RIGHT.rotated(rotation)
	else:
		var mp = get_global_mouse_position()
		dir = (mp - global_position).normalized()

	b.global_position  = global_position + dir * 60.0
	b.target_position  = b.global_position + dir
	b.rotation         = dir.angle()
	b.velocity         = dir * b.speed

	get_parent().add_child(b)

func _on_loot_collector_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot") and area.has_method("get_resource_data"):
		var data = area.get_resource_data()
		if data.has("name") and data.has("amount"):
			GameState.add_loot(data["name"], data["amount"])
		area.queue_free()
