extends Node
class_name PlayerMovement

# --- Parámetros configurables ---
var acceleration: float = 600.0
var initial_push: float = 100.0
var friction: float = 100.0
var brake_force: float = 300.0
var joystick_deadzone: float = 0.4
var speed: float = 600.0

# --- Referencias internas ---
var ship: CharacterBody2D = null
var joystick: Node = null
var thrust_controller: Node = null
var hud: Node = null
var player_stats: Node = null

# --- Estado ---
var pushing: bool = false

func setup(
	_ship: CharacterBody2D,
	_joystick: Node,
	_thrust_controller: Node,
	_hud: Node,
	_player_stats: Node
) -> void:
	ship = _ship
	joystick = _joystick
	thrust_controller = _thrust_controller
	hud = _hud
	player_stats = _player_stats

func process_touch(delta: float) -> void:
	pushing = false
	if joystick == null:
		_emit_thrust(false)
		return

	var input_vector = joystick.get_vector()
	var magnitude = input_vector.length()
	var dir = input_vector.normalized() if magnitude > 0.0 else Vector2.RIGHT

	if magnitude > 0.01:
		ship.rotation = lerp_angle(ship.rotation, dir.angle(), 10.0 * delta)

	if magnitude > joystick_deadzone:
		if player_stats and player_stats.fuel > 0.0:
			pushing = true
			ship.velocity += dir * acceleration * delta * magnitude
			_emit_thrust(true)
		else:
			#_show_fuel_warning()
			_emit_thrust(false)
	else:
		ship.velocity = ship.velocity.move_toward(Vector2.ZERO, friction * delta)
		_emit_thrust(false)

	_limit_speed()
	_reduce_lateral_drift()

func process_pc(delta: float) -> void:
	pushing = false

	var mouse_pos = ship.get_global_mouse_position()
	var dir = (mouse_pos - ship.global_position).normalized()
	ship.rotation = lerp_angle(ship.rotation, dir.angle(), 5.0 * delta)

	var is_thrusting := Input.is_action_pressed("ui_up")

	if is_thrusting and player_stats and player_stats.fuel > 0.0:
		pushing = true
		if Input.is_action_just_pressed("ui_up"):
			ship.velocity += dir * initial_push
		else:
			ship.velocity += dir * acceleration * delta
		_emit_thrust(true)
	elif is_thrusting:
		#_show_fuel_warning()
		_emit_thrust(false)
	else:
		_emit_thrust(false)

	if Input.is_action_pressed("brake"):
		ship.velocity = ship.velocity.move_toward(Vector2.ZERO, brake_force * delta)
	elif not pushing:
		ship.velocity = ship.velocity.move_toward(Vector2.ZERO, friction * delta)

	_limit_speed()

# --- Utilidades internas ---
func _emit_thrust(state: bool) -> void:
	if thrust_controller and thrust_controller.has_method("set_emitting"):
		thrust_controller.set_emitting(state)

#func _show_fuel_warning() -> void:
	#if hud:
		#hud.show_fuel_warning()

func _limit_speed() -> void:
	if ship.velocity.length() > speed:
		ship.velocity = ship.velocity.normalized() * speed

func _reduce_lateral_drift() -> void:
	var forward = Vector2.RIGHT.rotated(ship.rotation)
	var aligned = forward * ship.velocity.dot(forward)
	ship.velocity = lerp(ship.velocity, aligned, 0.05)
