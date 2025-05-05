extends Area2D

@onready var rect = $ColorRect
@onready var collision_shape = $CollisionShape2D

var velocity := Vector2.ZERO
var resource_name: String = ""
var amount: int = 0

func _ready():
	add_to_group("loot")
	velocity = Vector2(randf_range(-20, 20), randf_range(-60, -100))
	z_index = 10
	await get_tree().create_timer(50.0).timeout
	queue_free()

func _process(delta):
	position += velocity * delta
	velocity = velocity.move_toward(Vector2.ZERO, 30 * delta)

func setup_resource(res_name: String, amt: int = 1):
	await ready  # 🔄 Espera a que el nodo esté listo antes de acceder a rect
	resource_name = res_name
	amount = amt

	if rect and AsteroidResources.MATERIALS.has(resource_name):
		var color = AsteroidResources.MATERIALS[resource_name].color
		rect.color = color
	else:
		rect.color = Color(1, 1, 1)

func get_resource_data() -> Dictionary:
	return {
		"name": resource_name,
		"amount": amount
	}
