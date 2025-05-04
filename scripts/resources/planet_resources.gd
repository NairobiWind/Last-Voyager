extends Node

var BASE_TEXTURES: Array = []
var NOISE_TEXTURES: Array = []
var ILLUM_TEXTURES: Array = []

func _ready():
	load_textures()
	print("PlanetResources cargado")

func load_textures():
	# Base
	BASE_TEXTURES = [
		preload("res://assets/sprites/planets/kenney_planets/Parts/base/sphere0.png"),
		preload("res://assets/sprites/planets/kenney_planets/Parts/base/sphere1.png"),
		preload("res://assets/sprites/planets/kenney_planets/Parts/base/sphere2.png")
	]

	# Noise
	NOISE_TEXTURES.clear()
	for i in 28:
		var path = "res://assets/sprites/planets/kenney_planets/Parts/texture/noise%02d.png" % i
		NOISE_TEXTURES.append(load(path))

	# Illumination
	ILLUM_TEXTURES.clear()
	for i in 11:
		var path = "res://assets/sprites/planets/kenney_planets/Parts/illumination/light%d.png" % i
		ILLUM_TEXTURES.append(load(path))

func get_random_base(rng: RandomNumberGenerator) -> Texture2D:
	return BASE_TEXTURES[rng.randi_range(0, BASE_TEXTURES.size() - 1)]

func get_random_noise(rng: RandomNumberGenerator) -> Texture2D:
	return NOISE_TEXTURES[rng.randi_range(0, NOISE_TEXTURES.size() - 1)]

func get_random_illumination(rng: RandomNumberGenerator) -> Texture2D:
	return ILLUM_TEXTURES[rng.randi_range(0, ILLUM_TEXTURES.size() - 1)]
