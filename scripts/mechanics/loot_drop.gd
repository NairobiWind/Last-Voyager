# res://scripts/loot/LootDrop.gd
extends Area2D
class_name LootDrop

@export var lifetime: float = 30.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var velocity: Vector2 = Vector2.ZERO
var resource_name: String = ""
var amount: int = 0

func _ready() -> void:
	add_to_group("loot")
	velocity = Vector2(randf_range(-20, 20), randf_range(-60, -100))
	z_index = 10
	await get_tree().create_timer(lifetime).timeout
	if is_inside_tree():
		queue_free()

func _process(delta: float) -> void:
	position += velocity * delta
	velocity = velocity.move_toward(Vector2.ZERO, 30 * delta)

func setup_resource(res_name: String, amt: int = 1) -> void:
	resource_name = res_name
	amount = amt

	# Intentar tomar la referencia al ColorRect
	var rect_node := get_node_or_null("ColorRect") as ColorRect
	if rect_node:
		if AsteroidResources.MATERIALS.has(resource_name):
			rect_node.color = AsteroidResources.MATERIALS[resource_name].color
		else:
			rect_node.color = Color(1, 1, 1)
	else:
		push_warning("LootDrop: no se encontró el nodo ColorRect para ajustar el color.")

func get_resource_data() -> Dictionary:
	return {
		"name": resource_name,
		"amount": amount,
	}
