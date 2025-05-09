extends Resource
class_name WaveConfig


# -- Temporización de oleadas --
@export var initial_delay: float = 2.0         # Segundos antes de la ola 0
@export var base_interval: float = 30.0        # Segundos entre olas
@export var interval_increment: float = 5.0    # Aumento del intervalo por ola
@export var waves_count: int = 5               # Nº de oleadas

# -- Presupuesto de dificultad --
@export var base_budget: float = 100.0         # Dificultad de la ola 0
@export var budget_growth: float = 1.2         # Factor de crecimiento exponencial

# -- Definición de tipos de enemigo --
# Cada elemento debe ser un Diccionario con:
# { scene: PackedScene, cost: float, defense: float }
@export var enemy_types: Array[EnemyType] = []
