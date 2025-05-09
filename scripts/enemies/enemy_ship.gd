extends CharacterBody2D
class_name EnemyShip

# Paths exportables desde el editor
@export var movement_path: NodePath
@export var shoot_path: NodePath
@export var stats_path: NodePath
@export var enemy_type: String = "enemy_ship"

# Referencias a módulos (se asignan en _ready)
var movement_module: EnemyMovement
var shoot_module: EnemyShoot
var stats_module: EnemyStats
var shoot_timer: Timer

func _ready() -> void:
	add_to_group("enemies")
	print("🔷 EnemyShip inicializado: ", name)

	# Asignar módulos
	movement_module = get_node_or_null(movement_path) as EnemyMovement
	shoot_module    = get_node_or_null(shoot_path)    as EnemyShoot
	stats_module    = get_node_or_null(stats_path)    as EnemyStats
	shoot_timer     = get_node_or_null("StatsModule/ShootTimer") as Timer

	# Validaciones con logs
	if not movement_module:
		push_warning("❌ EnemyMovement no encontrado. Path: " + str(movement_path))
		return
	else:
		print("✅ EnemyMovement asignado.")

	if not shoot_module:
		push_warning("❌ EnemyShoot no encontrado. Path: " + str(shoot_path))
		return
	else:
		print("✅ EnemyShoot asignado.")

	if not stats_module:
		push_warning("❌ EnemyStats no encontrado. Path: " + str(stats_path))
		return
	else:
		print("✅ EnemyStats asignado.")

	if not shoot_timer:
		push_warning("❌ Timer no encontrado en ruta StatsModule/ShootTimer.")
		return
	else:
		print("✅ ShootTimer asignado.")

	# Buscar jugador
	var players: Array = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		push_warning("❌ No se encontró ningún nodo en el grupo 'player'.")
		return

	var player: Node2D = players[0] as Node2D
	print("🎯 Objetivo asignado:", player.name)

	# Setup de módulos
	movement_module.setup(self, player)
	shoot_module.setup(self, shoot_timer, player)
	stats_module.setup()
	stats_module.died.connect(_on_died)

	z_index = 10

func _physics_process(delta: float) -> void:
	if movement_module:
		movement_module.process(delta)
	if shoot_module:
		shoot_module.process(delta)

func _on_died() -> void:
	print("💥 Enemigo destruido:", name)
	queue_free()

func apply_damage(amount: int) -> void:
	if stats_module:
		stats_module.apply_damage(amount)
