extends Node
class_name PlayerShoot

# Parámetros internos
var ship: CharacterBody2D = null
var player_stats: Node = null
var hud: CanvasLayer = null
var bullet_scene: PackedScene = null

func try_shoot(is_touch: bool) -> void:
	#print("🔫 try_shoot llamado")
	if player_stats and player_stats.consume_shoot():
		_spawn_bullet(is_touch)
	#else:
		#print("⚠️ No se pudo disparar: sin fuel o player_stats null")
		#if hud:
			#hud.show_fuel_warning()

func _spawn_bullet(is_touch: bool) -> void:
	if bullet_scene == null or ship == null:
		push_warning("No se puede disparar: falta bullet_scene o ship")
		return

	var bullet = bullet_scene.instantiate()
	var dir := Vector2.RIGHT.rotated(ship.rotation)

	if not is_touch:
		dir = (ship.get_global_mouse_position() - ship.global_position).normalized()

	bullet.global_position = ship.global_position + dir * 60.0
	bullet.target_position = bullet.global_position + dir
	bullet.rotation = dir.angle()
	bullet.velocity = dir * bullet.speed

	ship.get_tree().current_scene.add_child(bullet)
