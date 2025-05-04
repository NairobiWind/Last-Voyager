extends Node

const MATERIALS := {
	"iron": {
		"durability": 100,
		"rarity": 35,
		"color": Color(0.3, 0.3, 0.3)
	},
	"nickel": {
		"durability": 120,
		"rarity": 25,
		"color": Color(0.6, 0.6, 0.6)
	},
	"silicon": {
		"durability": 80,
		"rarity": 30,
		"color": Color(0.7, 0.7, 0.7)
	},
	"aluminum": {
		"durability": 70,
		"rarity": 20,
		"color": Color(0.6, 0.7, 1.0)
	},
	"hydrogen": {
		"durability": 40,
		"rarity": 10,
		"color": Color(0.6, 0.9, 1.0)
	},
	"sodium": {
		"durability": 60,
		"rarity": 15,
		"color": Color(1.0, 1.0, 0.4)
	},
	"palladium": {
		"durability": 180,
		"rarity": 5,
		"color": Color(0.8, 0.9, 1.0)
	},
	"dark_matter": {
		"durability": 300,
		"rarity": 1,
		"color": Color(0.2, 0.0, 0.4)
	}
}

func get_random_material(rng: RandomNumberGenerator) -> Dictionary:
	var material_keys := MATERIALS.keys()
	var total_weight := 0.0
	for key in material_keys:
		total_weight += MATERIALS[key]["rarity"]

	var pick = rng.randf_range(0.0, total_weight)
	var acc := 0.0

	for key in material_keys:
		acc += MATERIALS[key]["rarity"]
		if pick <= acc:
			var material = MATERIALS[key].duplicate()
			material["name"] = key
			return material

	return MATERIALS["iron"].duplicate()
