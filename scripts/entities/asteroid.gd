# res://scenes/entities/Asteroid.gd
extends RigidBody2D

signal destroyed

@onready var sprite: Sprite2D                         = $Sprite2D
@onready var collision_player_shape: CollisionShape2D = $CollisionPlayer

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

@export var durability        : int        = 100
@export var loot              : Dictionary = {}
@export var size_index        : int        = -1
@export var asteroid_material : Dictionary = {}

# Daño bruto al chocar con la nave
var damage: int = 1

# Chunk‐tracking
var chunk_manager: Node
var current_chunk_coords: Vector2i

const loot_scene = preload("res://scenes/mechanics/LootDrop.tscn")

func _ready() -> void:
	gravity_scale = 0
	contact_monitor = true
	max_contacts_reported = 8

	# Sprite aleatorio
	if size_index < 0:
		size_index = randi() % SPRITES.size()
	sprite.texture = SPRITES[size_index]

	# CollisionShape para la nave
	if collision_player_shape:
		if collision_player_shape.shape == null:
			var s = CircleShape2D.new()
			s.radius = sprite.texture.get_width() * 0.4
			collision_player_shape.shape = s
	else:
		push_error("Asteroid.gd: no se encontró CollisionPlayer")

	# Durabilidad, loot y color
	if asteroid_material.has("durability"):
		durability = asteroid_material.durability
	if asteroid_material.has("name"):
		loot = { asteroid_material.name: randi_range(10, 50) }
		sprite.modulate = asteroid_material.color

	# Daño según durabilidad (2–4)
	damage = clamp(durability / 50.0, 2.0, 4.0)


	# Conectamos solo la señal de choque con la nave
	connect("body_entered", Callable(self, "_on_body_entered"))

	angular_velocity = randf_range(-1.0, 1.0)
	add_to_group("asteroids")
	z_index = 10

	# Chunk manager
	chunk_manager = get_tree().get_root().get_node_or_null("Main/SectorChunkManager")
	if chunk_manager:
		current_chunk_coords = chunk_manager.get_chunk_coords(global_position)

func _physics_process(_delta: float) -> void:
	if chunk_manager:
		var nc = chunk_manager.get_chunk_coords(global_position)
		if nc != current_chunk_coords and chunk_manager.active_chunks.has(nc):
			chunk_manager.transfer_asteroid_to_chunk(self, nc)
			current_chunk_coords = nc

func _on_body_entered(body: Node) -> void:
	# Choque con la nave
	if body.is_in_group("player") and body.has_method("apply_damage"):
		body.apply_damage(damage)

func apply_bullet_damage(amount: int) -> void:
	# Llamado por la bala cuando impacta
	durability -= amount
	if durability <= 0:
		_destroy()

func _destroy() -> void:
	emit_signal("destroyed")
	var spawn_pos = to_global(Vector2.ZERO)
	for res_name in loot.keys():
		var drop = loot_scene.instantiate()
		drop.global_position = spawn_pos
		drop.setup_resource(res_name)
		get_tree().get_root().call_deferred("add_child", drop)
	queue_free()
