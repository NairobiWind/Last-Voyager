extends Node2D

@onready var fps_label = $CanvasLayer/FPSLabel
@onready var hud_scene := preload("res://scenes/utilities/HUD.tscn")

func _ready():
	var hud = hud_scene.instantiate()
	add_child(hud)
	var drop_scene = preload("res://scenes/mechanics/LootDrop.tscn")
	var test_drop = drop_scene.instantiate()
	test_drop.global_position = Vector2(0, 0)  # O cerca de la nave
	test_drop.setup_resource("iron")  # Usamos un material seguro
	add_child(test_drop)

	var coords = Vector2i(0, 0)
	var data = UniverseData.get_chunk_data(coords)
	print("Datos del chunk (0,0):", data)

func _process(_delta):
	var fps = Engine.get_frames_per_second()
	var nodes = get_tree().get_node_count()
	fps_label.text = "FPS: %d\nNodos: %d" % [fps, nodes]
