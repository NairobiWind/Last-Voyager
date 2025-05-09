extends Node
class_name TimedEnemySpawner

@export var config: WaveConfig              # Recurso .tres con la configuración
@export var player_path: NodePath           # Referencia al jugador

const MIN_SPAWN_RADIUS := 1300.0
const MAX_SPAWN_RADIUS := 3000.0

var _wave_index: int = 0
var _timer: Timer
var _player: Node2D

signal wave_started(index: int, budget: float)
signal all_waves_finished()

func _ready() -> void:
	# 1) Obtener jugador
	_player = get_node_or_null(player_path) as Node2D
	if _player == null:
		push_error("TimedEnemySpawner: ruta inválida para el jugador → " + str(player_path))
		return

	# 2) Configurar el Timer
	_timer = Timer.new()
	add_child(_timer)
	_timer.one_shot = true
	_timer.connect("timeout", Callable(self, "_on_timer_timeout"))

	# 3) Arrancar la primera ola
	print("-- TimedEnemySpawner SIN chunks, siguiendo a:", _player.name, "--")
	_start_timer_for_wave(0)

func _start_timer_for_wave(i: int) -> void:
	var delay = config.initial_delay + (config.base_interval + i * config.interval_increment) * i
	print("Spawner: programada ola %d tras %.2f s" % [i, delay])
	_timer.start(delay)

func _on_timer_timeout() -> void:
	if _wave_index >= config.waves_count:
		print("Spawner: todas las oleadas terminadas")
		emit_signal("all_waves_finished")
		return

	var budget = config.base_budget * pow(config.budget_growth, _wave_index)
	print("Spawner: iniciando ola %d con presupuesto %.2f" % [_wave_index, budget])
	emit_signal("wave_started", _wave_index, budget)

	_spawn_wave(budget)

	_wave_index += 1
	_start_timer_for_wave(_wave_index)

func _spawn_wave(budget: float) -> void:
	print(">>> _spawn_wave arrancó, budget=%.2f" % budget)
	print("    enemy_types.size() =", config.enemy_types.size())

	var remaining = budget
	var types = config.enemy_types.duplicate()

	while remaining > 0 and types.size() > 0:
		types.shuffle()
		var entry = types[0]

		if entry == null or entry.scene == null:
			push_warning("Spawner: EnemyType inválido, descartando.")
			types.remove_at(0)
			continue
		if entry.cost > remaining:
			print("Spawner: entry.cost %.2f > remaining %.2f, descartando tipo" % [entry.cost, remaining])
			types.remove_at(0)
			continue

		# Posición aleatoria alrededor del jugador
		var angle = randf_range(0, TAU)
		var distance = randf_range(MIN_SPAWN_RADIUS, MAX_SPAWN_RADIUS)
		var offset = Vector2.RIGHT.rotated(angle) * distance
		var spawn_pos = _player.global_position + offset

		print("Spawner: spawneando %s en %s con cost=%.2f, defense=%.2f"
			% [entry.scene.resource_path, spawn_pos, entry.cost, entry.defense])

		var enemy = entry.scene.instantiate()
		if enemy == null:
			push_warning("Spawner: fallo al instanciar %s" % entry.scene.resource_path)
			types.remove_at(0)
			continue

		enemy.global_position = spawn_pos
		if enemy.has_method("set_strength"):
			enemy.call("set_strength", int(entry.cost))
		if enemy.has_method("set_defense"):
			enemy.call("set_defense", float(entry.defense))

		get_tree().current_scene.add_child(enemy)
		remaining -= entry.cost
		print("Spawner: presupuesto restante = %.2f" % remaining)
