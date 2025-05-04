extends Node

var fuel: float = 100.0
const FUEL_MAX = 100.0
const FUEL_COST_SHOOT = 0.1
const FUEL_REGEN_AMOUNT = 0.1
const FUEL_REGEN_INTERVAL = 1.0

var idle_time := 0.0

func _process(delta):
	# Si no se pulsa nada, empieza a regenerar
	if not Input.is_action_pressed("ui_up") and not Input.is_action_pressed("ui_left"):
		idle_time += delta
		if idle_time >= FUEL_REGEN_INTERVAL:
			fuel = min(fuel + FUEL_REGEN_AMOUNT, FUEL_MAX)
			idle_time = 0.0
	else:
		idle_time = 0.0

func consume_thrust(delta: float):
	if Input.is_action_pressed("ui_up"):
		fuel = max(fuel - 0.1 * delta, 0.0)

func consume_shoot() -> bool:
	if fuel >= FUEL_COST_SHOOT:
		fuel -= FUEL_COST_SHOOT
		return true
	return false
