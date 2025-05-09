extends Node
class_name PlayerStats

signal died

# --- Atributos configurables ---
@export var max_health: int = 10
@export var defense_factor: float = 1.0

@export var fuel: float = 20.0
@export var fuel_max: float = 20.0
@export var fuel_cost_shoot: float = 0.1
@export var fuel_thrust_cost: float = 0.1
@export var fuel_radar_cost: float = 0.1
@export var fuel_regen_amount: float = 0.1
@export var fuel_regen_interval: float = 1.0

# --- Estado interno ---
var health: int = 0
var base_defense_factor: float = 1.0
var regen_timer: float = 0.0
var is_thrusting: bool = false
var radar_zoom_active: bool = false
var ship_speed: float = 0.0  # actualizado externamente desde PlayerShip

func _ready() -> void:
	health = max_health
	base_defense_factor = defense_factor

func _process(delta: float) -> void:
	# Si el radar (mapa 7×7) está activo, consumir fuel y no regenerar
	if radar_zoom_active:
		fuel = clamp(fuel - fuel_radar_cost * delta, 0.0, fuel_max)
		return

	# Lógica de regeneración y penalización de thrust
	regen_timer += delta
	if regen_timer >= fuel_regen_interval:
		var cost: float = 0.0
		if is_thrusting:
			cost += fuel_thrust_cost

		if cost > 0.0:
			fuel = clamp(fuel - cost, 0.0, fuel_max)
		elif ship_speed < 5.0:
			fuel = clamp(fuel + fuel_regen_amount, 0.0, fuel_max)

		regen_timer -= fuel_regen_interval

	# Penalización dinámica de defensa según nivel de fuel
	if fuel <= 0.0:
		defense_factor = base_defense_factor * 0.5
	elif fuel < fuel_max * 0.1:
		var t := fuel / (fuel_max * 0.1)
		defense_factor = lerp(base_defense_factor * 0.5, base_defense_factor, t)
	else:
		defense_factor = base_defense_factor

func set_thrusting(active: bool) -> void:
	is_thrusting = active

func set_radar_zoom(active: bool) -> void:
	radar_zoom_active = active

func update_speed(speed: float) -> void:
	ship_speed = speed

func consume_shoot() -> bool:
	if fuel >= fuel_cost_shoot:
		fuel -= fuel_cost_shoot
		return true
	return false

func apply_damage(amount: int) -> void:
	var effective: int = max(1, int(amount / defense_factor))
	health -= effective
	if health <= 0:
		health = 0
		emit_signal("died")

func reset_stats() -> void:
	health = max_health
	fuel   = fuel_max

	regen_timer        = 0.0
	defense_factor     = base_defense_factor
	is_thrusting       = false
	radar_zoom_active  = false

	print("[PlayerStats] Stats reseteados: Health=", health, " Fuel=", fuel)
