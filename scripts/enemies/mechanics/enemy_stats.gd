extends Node
class_name EnemyStats

signal died
signal damaged(amount: int, remaining_health: int)

@export var max_health: int = 3
@export var defense_factor: float = 1.0  # 1.0 = sin reducción
@export var score_value: int = 100

var health: int = 0

func setup() -> void:
	health = max_health

# Método público para ajustar la vida máxima en runtime
func set_strength(strength: int) -> void:
	max_health = strength
	health = max_health

# Método público para ajustar la defensa en runtime
func set_defense(defense: float) -> void:
	defense_factor = defense

# Interfaz unificada: apply_damage
func apply_damage(amount: int) -> void:
	if health <= 0:
		return  # Ya muerto

	# Calcula daño efectivo tras defensa
	var effective = max(1, int(amount / defense_factor))
	health = max(health - effective, 0)
	emit_signal("damaged", effective, health)

	if health == 0:
		emit_signal("died")
