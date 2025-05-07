# res://scripts/managers/GameStats.gd
extends Node

var fuel: float = 100.0
const FUEL_MAX = 100.0
const FUEL_COST_SHOOT = 0.1
const FUEL_REGEN_AMOUNT = 0.1
const FUEL_REGEN_INTERVAL = 1.0
const FUEL_THRUST_COST = 0.1  # fuel por segundo al empujar

var is_thrusting: bool = false
var timer: float = 0.0

func set_thrusting(active: bool) -> void:
	is_thrusting = active

func _process(delta: float) -> void:
	timer += delta
	if timer >= FUEL_REGEN_INTERVAL:
		if is_thrusting:
			fuel = max(fuel - FUEL_THRUST_COST, 0.0)
		else:
			fuel = min(fuel + FUEL_REGEN_AMOUNT, FUEL_MAX)
		timer -= FUEL_REGEN_INTERVAL

func consume_shoot() -> bool:
	if fuel >= FUEL_COST_SHOOT:
		fuel -= FUEL_COST_SHOOT
		return true
	return false
