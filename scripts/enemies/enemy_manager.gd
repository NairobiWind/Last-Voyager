extends Node

signal enemy_registered(enemy)
signal enemy_unregistered(enemy)
signal all_enemies_killed()

var active_enemies = []
var total_spawned = 0
var total_killed = 0

func _ready():
	print("📡 EnemyManager iniciado.")

func register_enemy(enemy):
	if enemy in active_enemies:
		return

	active_enemies.append(enemy)
	total_spawned += 1
	emit_signal("enemy_registered", enemy)
	print("🛸 Registrado enemigo:", enemy.name, "- Total:", active_enemies.size())

func unregister_enemy(enemy):
	if enemy not in active_enemies:
		return

	active_enemies.erase(enemy)
	total_killed += 1
	emit_signal("enemy_unregistered", enemy)
	print("💥 Eliminado enemigo:", enemy.name, "- Quedan:", active_enemies.size())

	if active_enemies.is_empty():
		emit_signal("all_enemies_killed")
		print("🎉 Todos los enemigos eliminados")

func get_all_enemies():
	return active_enemies.duplicate()

func get_enemy_count():
	return active_enemies.size()

func get_enemies_by_type_name(type_name):
	var result = []
	for e in active_enemies:
		if e.has_variable("enemy_type") and e.enemy_type == type_name:
			result.append(e)
	return result

func get_enemies_by_group(group_name):
	var result = []
	for e in active_enemies:
		if e.is_in_group(group_name):
			result.append(e)
	return result

func for_each_enemy(action):
	for enemy in active_enemies:
		if action.is_valid():
			action.call(enemy)
