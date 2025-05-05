extends Node

const STAR_TEXTURE := preload("res://assets/sprites/ship/Kenny Simple Space/PNG/Retina/star_small.png")
const MAX_POOL_SIZE := 300

var available_stars: Array[Sprite2D] = []

func get_star() -> Sprite2D:
	for i in range(available_stars.size() - 1, -1, -1):
		var star_candidate = available_stars[i]
		if is_instance_valid(star_candidate):
			available_stars.remove_at(i)
			var star: Sprite2D = star_candidate
			return star
		else:
			available_stars.remove_at(i)

	var new_star: Sprite2D = Sprite2D.new()
	new_star.texture = STAR_TEXTURE

	# 🔧 OPTIMIZACIÓN #1: desactiva procesos innecesarios
	new_star.set_process(false)
	new_star.set_physics_process(false)

	return new_star

func return_star(star: Sprite2D) -> void:
	if not is_instance_valid(star):
		return
	star.visible = false
	if available_stars.size() >= MAX_POOL_SIZE:
		star.queue_free()
	else:
		available_stars.append(star)
