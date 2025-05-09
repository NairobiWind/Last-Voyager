extends Resource
class_name EnemyType

@export var scene: PackedScene
@export var cost: float = 1.0
@export var defense: float = 1.0

func get_cost() -> float:
	return cost

func get_scene() -> PackedScene:
	return scene
