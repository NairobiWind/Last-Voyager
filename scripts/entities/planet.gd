extends Node2D

@onready var base_sprite = $BaseSphere
@onready var terrain_sprite = $TerrainLayer
@onready var atmosphere_sprite = $AtmosphereLayer
@onready var illumination_sprite = $IlluminationLayer
@onready var name_label = $NameLabel

var planet_data: Dictionary = {}

func _ready():
	var seed_val: int = planet_data["seed"]
	var base_seed: int = planet_data["base_seed"]
	var illum_index: int = planet_data["illum_index"]
	var terrain_index: int = planet_data["terrain_index"]
	var atmo_index: int = planet_data["atmo_index"]
	var atmo_seed: int = planet_data["atmo_seed"]

	var rng = RandomNumberGenerator.new()
	rng.seed = seed_val

	# 💠 BaseSphere
	base_sprite.anchor_left = 0.5
	base_sprite.anchor_top = 0.5
	base_sprite.anchor_right = 0.5
	base_sprite.anchor_bottom = 0.5
	base_sprite.position = Vector2(-512, -512)
	base_sprite.size = Vector2(1024, 1024)

	var color_rng = RandomNumberGenerator.new()
	color_rng.seed = base_seed
	var base_color: Color = get_random_color(color_rng, 0.2, 1.0)

	var base_material := preload("res://shaders/planet_base_material.tres").duplicate()
	base_material.set_shader_parameter("planet_color", base_color)
	base_sprite.material = base_material

	# Texturas
	terrain_sprite.texture = PlanetResources.NOISE_TEXTURES[terrain_index]
	illumination_sprite.texture = PlanetResources.ILLUM_TEXTURES[illum_index]

	# Terreno
	terrain_sprite.modulate = get_random_color(rng, 0.4, 0.8)

	# 🌫️ Atmosfera sin shader, centrada manualmente
	atmosphere_sprite.texture = PlanetResources.NOISE_TEXTURES[atmo_index]

	var atmo_rng = RandomNumberGenerator.new()
	atmo_rng.seed = atmo_seed
	var atmo_color: Color = get_random_color(atmo_rng, 0.2, 0.6)
	atmo_color.a = 0.25
	atmosphere_sprite.modulate = atmo_color

	# Ajustar para que esté exactamente centrado como base_sprite
	atmosphere_sprite.centered = true
	atmosphere_sprite.offset = Vector2.ZERO
	atmosphere_sprite.position = base_sprite.position
	atmosphere_sprite.scale = base_sprite.scale * 1.08

	# 💡 Iluminación
	illumination_sprite.modulate = Color(1, 1, 1, 0.4)
	var illum_material := preload("res://shaders/illum_soft_material.tres").duplicate()
	illum_material.set_shader_parameter("blend_texture", illumination_sprite.texture)
	illum_material.set_shader_parameter("light_strength", 0.6)
	illumination_sprite.material = illum_material

	# Z-order
	base_sprite.z_index = 0
	terrain_sprite.z_index = 1
	atmosphere_sprite.z_index = 2
	illumination_sprite.z_index = 3
	name_label.z_index = 4

	# Escala y nombre
	scale = Vector2.ONE * rng.randf_range(1.2, 2.0)

	var planet_name: String = planet_data["name"]
	name_label.text = planet_name
	name_label.position = Vector2(0, -60 * scale.y)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("normal_font_size", 24)
	name_label.add_theme_color_override("font_color", Color("#c2f0ff"))
	name_label.add_theme_color_override("font_outline_color", Color.BLACK)
	name_label.add_theme_constant_override("outline_size", 2)

	# ✅ Añadir al grupo "planets" para el HUD
	add_to_group("planets")

func get_random_color(rng: RandomNumberGenerator, saturation := 0.5, value := 1.0) -> Color:
	var hue = rng.randf()
	return Color.from_hsv(hue, saturation, value)
