extends CanvasLayer

@onready var fuel_label = $ScreenStats/FuelLabel
@onready var iron_label = $ScreenStats/IronLabel
@onready var nickel_label = $ScreenStats/NickelLabel
@onready var silicon_label = $ScreenStats/SiliconLabel
@onready var aluminum_label = $ScreenStats/AluminumLabel
@onready var hydrogen_label = $ScreenStats/HydrogenLabel
@onready var sodium_label = $ScreenStats/SodiumLabel
@onready var palladium_label = $ScreenStats/PalladiumLabel
@onready var dark_matter_label = $ScreenStats/DarkMatterLabel

func _process(_delta):
	fuel_label.text = "🔋 %.1f" % GameStats.fuel
	_update_loot_labels()

func _update_loot_labels():
	var inventory = GameState.inventory
	iron_label.text = "Fe: %d" % inventory.get("iron", 0)
	nickel_label.text = "Ni: %d" % inventory.get("nickel", 0)
	silicon_label.text = "Si: %d" % inventory.get("silicon", 0)
	aluminum_label.text = "Al: %d" % inventory.get("aluminum", 0)
	hydrogen_label.text = "H: %d" % inventory.get("hydrogen", 0)
	sodium_label.text = "Na: %d" % inventory.get("sodium", 0)
	palladium_label.text = "Pd: %d" % inventory.get("palladium", 0)
	dark_matter_label.text = "🟪: %d" % inventory.get("dark_matter", 0)
