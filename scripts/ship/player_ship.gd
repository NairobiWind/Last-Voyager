extends CharacterBody2D
class_name PlayerShip

@export var push_strength: float = 50.0    # Fuerza de empuje al asteroide

# 1. Estado interno
var pushing := false
var was_pushing := false
var last_touch_mode := false

# 2. Referencias internas (de la escena PlayerShip.tscn)
@onready var camera: Camera2D         = $Camera2D
@onready var stats: PlayerStats       = $PlayerStats
@onready var movement: PlayerMovement = $PlayerMovement
@onready var shoot_module: Node       = $PlayerShoot
@onready var loot_collector: Area2D   = $LootCollector
@onready var thrust_particles: GPUParticles2D = $ThrustParticles

# 3. Referencias externas (setup desde Main)
var hud: Node          = null
var joystick: Node     = null
var mobile_input: Node = null

@onready var mode_mgr = get_node("/root/InputModeManager")

# 4. Setup externo y conexión de input táctil
func setup_external(_hud: Node, _joystick: Node, _mobile_input: Node) -> void:
	hud = _hud
	joystick = _joystick
	mobile_input = _mobile_input
	_connect_input()

func _connect_input() -> void:
	if mobile_input and not mobile_input.is_connected("shoot_requested", Callable(self, "_on_touch_shoot_requested")):
		mobile_input.connect("shoot_requested", Callable(self, "_on_touch_shoot_requested"))

# 5. _ready(): inicializaciones y conexiones
func _ready() -> void:
	last_touch_mode = mode_mgr.touch_mode
	camera.make_current()
	add_to_group("player")

	if not loot_collector.is_connected("area_entered", Callable(self, "_on_loot_collector_area_entered")):
		loot_collector.connect("area_entered", Callable(self, "_on_loot_collector_area_entered"))

	# Configuramos el movimiento sin ThrustController
	movement.setup(self, joystick, null, hud, stats)

	# Aseguramos que las partículas empiecen apagadas
	if thrust_particles:
		thrust_particles.emitting = false

	# Debug
	print("🧩 movement:", movement)
	print("✅ PlayerMovement setup ejecutado")

# 6. Cambio de modo de input
func _process(_delta: float) -> void:
	var tm = mode_mgr.touch_mode
	if tm != last_touch_mode:
		last_touch_mode = tm
		_update_touch_ui()

func _update_touch_ui() -> void:
	if hud:
		hud.visible = last_touch_mode

# 7. Física, thrusting y colisiones
func _physics_process(delta: float) -> void:
	z_index = 10
	pushing = false

	if mode_mgr.touch_mode:
		movement.process_touch(delta)
	else:
		movement.process_pc(delta)

	pushing = movement.pushing
	stats.set_thrusting(pushing)

	# ➤ Emitir partículas directamente
	if thrust_particles:
		thrust_particles.emitting = pushing

	if pushing != was_pushing:
		was_pushing = pushing

	move_and_slide()

# 8. Disparo táctil
func _on_touch_shoot_requested() -> void:
	shoot_module.try_shoot(true)

# 9. Recoger loot
func _on_loot_collector_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot") and area.has_method("get_resource_data"):
		var data = area.get_resource_data()
		if data.has("name") and data.has("amount"):
			GameState.add_loot(data["name"], data["amount"])
		area.queue_free()

# 10. Permitir daño desde Asteroid.gd
func apply_damage(amount: int) -> void:
	stats.apply_damage(amount)
