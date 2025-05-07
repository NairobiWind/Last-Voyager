# res://scenes/ship/PlayerShip.gd
extends CharacterBody2D

@export var bullet_scene    : PackedScene = preload("res://scenes/ship/Bullet.tscn")
@export var speed           : float       = 600.0
@export var joystick_path   : NodePath
@export var touchui_path    : NodePath

# Parámetros PC
const ACCELERATION: float            = 600.0
const INITIAL_PUSH: float            = 100.0
const FRICTION: float                = 100.0
const BRAKE_FORCE: float             = 300.0
const JOYSTICK_DEADZONE_ACCEL: float = 0.4

# Vida y defensa
@export var max_health     : int   = 10
@export var defense_factor : float = 1.0  # daño efectivo = raw_damage / defense_factor
var health                   : int

# Estado interno
var pushing: bool         = false
var was_pushing: bool     = false
var last_touch_mode: bool = false

# Referencias
@onready var joystick       = get_node_or_null(joystick_path)
@onready var mobile_ctrls   = get_node_or_null(touchui_path)
@onready var mode_mgr       = get_node("/root/InputModeManager")
@onready var camera         = $Camera2D
@onready var loot_collector = $LootCollector
@onready var thrust_pts     = $ThrustParticles

func _ready() -> void:
	# — Fallback automático de nodos si no los asignaste en el Inspector —
	if joystick == null and mobile_ctrls:
		var auto_js = mobile_ctrls.get_node_or_null("VirtualJoystick")
		if auto_js:
			joystick = auto_js
		else:
			push_error("PlayerShip: no se encontró 'VirtualJoystick' en %s" % mobile_ctrls.get_path())
	if mobile_ctrls == null:
		var auto_ui = get_tree().get_root().get_node_or_null("Main/HUD/MobileControls")
		if auto_ui:
			mobile_ctrls = auto_ui

	# Inicializar HP
	health = max_health

	# Cámara
	camera.zoom = Vector2.ONE
	camera.make_current()

	add_to_group("player")

	# Restaurar posición y fuel
	global_position = GameState.last_position
	GameStats.fuel   = GameState.last_fuel

	# Conectar loot
	if not loot_collector.is_connected("area_entered", Callable(self, "_on_loot_collector_area_entered")):
		loot_collector.connect("area_entered", Callable(self, "_on_loot_collector_area_entered"))

	# UI touch
	last_touch_mode = mode_mgr.touch_mode
	_update_touch_ui()

func _process(_delta: float) -> void:
	var tm = mode_mgr.touch_mode
	if tm != last_touch_mode:
		last_touch_mode = tm
		_update_touch_ui()

func _update_touch_ui() -> void:
	if mobile_ctrls:
		mobile_ctrls.visible = last_touch_mode

func _physics_process(delta: float) -> void:
	z_index = 10
	pushing = false

	if mode_mgr.touch_mode:
		_process_touch(delta)
	else:
		_process_pc(delta)

	# Notificar a GameStats si cambió el estado de empuje
	if pushing != was_pushing:
		GameStats.set_thrusting(pushing)
		was_pushing = pushing

	# Mover y detectar colisiones de movimiento
	move_and_slide()
	_handle_collisions()

	# Guardar estado
	GameState.last_position = global_position
	GameState.last_fuel     = GameStats.fuel

func _process_touch(delta: float) -> void:
	# 1) Verificamos joystick
	if joystick == null:
		thrust_pts.emitting = false
		return

	# 2) Leemos su vector
	var v = joystick.get_vector()
	var mag = v.length()

	# 3) Normalizamos sin ternarios
	var dir_norm: Vector2
	if mag > 0.0:
		dir_norm = v / mag
	else:
		dir_norm = Vector2.RIGHT

	# 4) Rotación suave
	if mag > 0.01:
		rotation = lerp_angle(rotation, dir_norm.angle(), 10.0 * delta)

	# 5) Empuje vs fricción
	if mag > JOYSTICK_DEADZONE_ACCEL:
		pushing = true
		velocity += dir_norm * ACCELERATION * delta * mag
		thrust_pts.emitting = true
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		thrust_pts.emitting = false

	# 6) Límite de velocidad
	if velocity.length() > speed:
		velocity = velocity.normalized() * speed

	# 7) Deriva lateral
	var forward = Vector2.RIGHT.rotated(rotation)
	var aligned = forward * velocity.dot(forward)
	velocity = lerp(velocity, aligned, 0.05)

func _process_pc(delta: float) -> void:
	var mp     = get_global_mouse_position()
	var dir_pc = (mp - global_position).normalized()
	rotation   = lerp_angle(rotation, dir_pc.angle(), 5.0 * delta)

	if Input.is_action_pressed("ui_up"):
		pushing = true
		if Input.is_action_just_pressed("ui_up"):
			velocity += dir_pc * INITIAL_PUSH
		else:
			velocity += dir_pc * ACCELERATION * delta
		thrust_pts.emitting = true
	else:
		thrust_pts.emitting = false

	if Input.is_action_pressed("brake"):
		velocity = velocity.move_toward(Vector2.ZERO, BRAKE_FORCE * delta)
	elif not pushing:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	if velocity.length() > speed:
		velocity = velocity.normalized() * speed

	if Input.is_action_just_pressed("shoot"):
		if GameStats.consume_shoot():
			_shoot_bullet(false)

func _shoot_bullet(is_touch: bool) -> void:
	var b   = bullet_scene.instantiate()
	var dir = Vector2.RIGHT.rotated(rotation)
	if not is_touch:
		dir = (get_global_mouse_position() - global_position).normalized()
	b.global_position = global_position + dir * 60.0
	b.target_position = b.global_position + dir
	b.rotation        = dir.angle()
	b.velocity        = dir * b.speed
	get_parent().add_child(b)

func _handle_collisions() -> void:
	for i in get_slide_collision_count():
		var col   = get_slide_collision(i)
		var other = col.get_collider()
		if other and other.is_in_group("asteroids"):
			var raw_damage = 10
			if other.has_method("get_collision_damage"):
				raw_damage = other.get_collision_damage()
			apply_damage(raw_damage)

func apply_damage(amount: int) -> void:
	var effective = int(amount / defense_factor)
	if effective < 1:
		effective = 1
	health -= effective
	if health < 0:
		health = 0
	print("🚨 Damage: %d (factor=%.2f) → HP %d/%d"
		% [effective, defense_factor, health, max_health])
	if health == 0:
		_die()

func _die() -> void:
	print("💥 Ship destroyed!")
	# TODO: explosión, reiniciar nivel…

func _on_loot_collector_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot") and area.has_method("get_resource_data"):
		var data = area.get_resource_data()
		if data.has("name") and data.has("amount"):
			GameState.add_loot(data["name"], data["amount"])
		area.queue_free()
