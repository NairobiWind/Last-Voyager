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
	GameStats.consume_thrust(delta)

	if mode_mgr.touch_mode:
		_process_touch(delta)
	else:
		_process_pc(delta)

	move_and_slide()
	GameState.last_position = global_position
	GameState.last_fuel     = GameStats.fuel

func _process_touch(delta: float) -> void:
	if joystick:
		var v = joystick.get_vector()
		if v.length() > 0.1:
			rotation = lerp_angle(rotation, v.angle(), 10.0 * delta)
			velocity = v.normalized() * speed
		else:
			velocity = Vector2.ZERO
	else:
		velocity = Vector2.ZERO
	thrust_pts.emitting = false

	if Input.is_action_just_pressed("shoot") and GameStats.fuel > 0.0 and GameStats.consume_shoot():
		_shoot_bullet(true)

func _process_pc(delta: float) -> void:
	var mp  = get_global_mouse_position()
	var dir_pc = (mp - global_position).normalized()
	rotation   = lerp_angle(rotation, dir_pc.angle(), 5.0 * delta)

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
	var b    = bullet_scene.instantiate()
	var dir  : Vector2
	if is_touch:
		# móvil: dispara siempre hacia adelante de la nave
		dir = Vector2.RIGHT.rotated(rotation)
	else:
		# PC: dispara hacia la posición del ratón
		var mp = get_global_mouse_position()
		dir = (mp - global_position).normalized()

	# Posición de aparición
	b.global_position  = global_position + dir * 60.0
	# Importante: asignar target_position para que Bullet.gd calcule bien
	b.target_position  = b.global_position + dir
	# Parámetros iniciales (opcional, pues Bullet.gd los recalcula en _ready)
	b.rotation         = dir.angle()
	b.velocity         = dir * b.speed

	get_parent().add_child(b)

func _on_loot_collector_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot") and area.has_method("get_resource_data"):
		var data = area.get_resource_data()
		if data.has("name") and data.has("amount"):
			GameState.add_loot(data["name"], data["amount"])
		area.queue_free()
