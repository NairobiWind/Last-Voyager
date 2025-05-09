extends Node
class_name EnemyShoot

signal shot_fired

@export var bullet_scene: PackedScene
@export var fire_rate:     float = 1.0
@export var muzzle_offset: Vector2 = Vector2(32, 0) 
# -> distancia en píxeles desde el centro de la nave a la punta de su cañón (ajústalo)

var _ship:       CharacterBody2D
var _player:     Node2D
var _shot_timer: Timer

func setup(ship_ref: CharacterBody2D, shot_timer_ref: Timer, player_ref: Node2D) -> void:
	_ship       = ship_ref
	_player     = player_ref
	_shot_timer = shot_timer_ref

	_shot_timer.wait_time = fire_rate
	_shot_timer.one_shot  = false
	if not _shot_timer.is_connected("timeout", Callable(self, "_on_timeout")):
		_shot_timer.connect("timeout", Callable(self, "_on_timeout"))
	_shot_timer.start()

func process(_delta: float) -> void:
	pass  # sin cambios

func _on_timeout() -> void:
	# Instanciamos la bala
	var bullet = bullet_scene.instantiate()
	if bullet is Node2D:
		# 1) Calculamos la posición del muzzle rotando el offset
		var global_muzzle = _ship.global_position + muzzle_offset.rotated(_ship.rotation)
		bullet.global_position = global_muzzle

		# 2) La rotación de la bala igual a la de la nave
		bullet.rotation = _ship.rotation

		# 3) Dirección de movimiento: Vector2.RIGHT rotado
		if bullet.has_method("set_direction"):
			var dir = Vector2.RIGHT.rotated(_ship.rotation)
			bullet.call("set_direction", dir)

		get_tree().current_scene.add_child(bullet)
		emit_signal("shot_fired")
