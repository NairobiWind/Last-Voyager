extends Area2D

signal destroyed  # ✅ Señal para indicar destrucción

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

const SPRITES = [
	preload("res://assets/sprites/ship/Kenny Simple Space/PNG/Retina/meteor_detailedLarge.png"),
	preload("res://assets/sprites/ship/Kenny Simple Space/PNG/Retina/meteor_detailedSmall.png"),
	preload("res://assets/sprites/ship/Kenny Simple Space/PNG/Retina/meteor_large.png"),
	preload("res://assets/sprites/ship/Kenny Simple Space/PNG/Retina/meteor_small.png"),
	preload("res://assets/sprites/ship/Kenny Simple Space/PNG/Retina/meteor_squareDetailedLarge.png"),
	preload("res://assets/sprites/ship/Kenny Simple Space/PNG/Retina/meteor_squareDetailedSmall.png"),
	preload("res://assets/sprites/ship/Kenny Simple Space/PNG/Retina/meteor_squareLarge.png"),
	preload("res://assets/sprites/ship/Kenny Simple Space/PNG/Retina/meteor_squareSmall.png")
]

var velocity: Vector2 = Vector2.ZERO
var rotation_speed: float = 0.0
var current_chunk_coords: Vector2i
var chunk_manager: Node

@export var durability: int = 100
@export var loot: Dictionary = {}
@export var size_index: int = -1
@export var asteroid_material: Dictionary = {}

var loot_scene := preload("res://scenes/mechanics/LootDrop.tscn")

func _ready():
	if size_index == -1:
		size_index = randi() % SPRITES.size()

	sprite.texture = SPRITES[size_index]

	var shape = CircleShape2D.new()
	shape.radius = sprite.texture.get_width() * 0.4
	collision.shape = shape

	if asteroid_material.has("name"):
		durability = asteroid_material.durability
		loot = {asteroid_material.name: randi_range(10, 50)}
		sprite.modulate = asteroid_material.color
	else:
		durability = 100
		loot = {"iron": 25}
		sprite.modulate = Color(1, 1, 1)

	rotation_speed = randf_range(-1.0, 1.0)
	z_index = 10
	add_to_group("asteroids")
	connect("area_entered", Callable(self, "_on_area_entered"))

	chunk_manager = get_tree().get_root().get_node("Main/SectorChunkManager")
	current_chunk_coords = chunk_manager.get_chunk_coords(global_position)

func _process(delta):
	position += velocity * delta
	rotation += rotation_speed * delta

	var new_chunk_coords = chunk_manager.get_chunk_coords(global_position)
	if new_chunk_coords != current_chunk_coords:
		if chunk_manager.active_chunks.has(new_chunk_coords):
			chunk_manager.transfer_asteroid_to_chunk(self, new_chunk_coords)
			current_chunk_coords = new_chunk_coords

func _on_area_entered(area):
	if area.is_in_group("bullets"):
		durability -= 50
		if durability <= 0:
			destroy()

func destroy():
	# ✅ Emitimos la señal y destruimos el nodo
	emit_signal("destroyed")

	var spawn_pos := to_global(Vector2.ZERO)
	var parent := get_tree().get_root()
	for resource in loot.keys():
		var drop := loot_scene.instantiate()
		drop.global_position = spawn_pos
		drop.setup_resource(resource)
		parent.call_deferred("add_child", drop)

	queue_free()
