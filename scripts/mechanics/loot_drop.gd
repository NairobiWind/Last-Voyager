extends Area2D

@onready var rect = $ColorRect  # Asegúrate de que se llame exactamente así

var velocity := Vector2.ZERO

func _ready():
	velocity = Vector2(randf_range(-20, 20), randf_range(-60, -100))
	z_index = 10
	await get_tree().create_timer(50.0).timeout
	queue_free()

func _process(delta):
	position += velocity * delta
	velocity = velocity.move_toward(Vector2.ZERO, 30 * delta)

func setup_resource(resource_name: String):
	await ready
	if AsteroidResources.MATERIALS.has(resource_name):
		var color = AsteroidResources.MATERIALS[resource_name]["color"]
		rect.color = color
	else:
		rect.color = Color(1, 1, 1)
