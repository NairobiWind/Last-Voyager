# res://scripts/utilities/HUD.gd
extends CanvasLayer

@onready var fuel_label        = $ScreenStats/FuelLabel
@onready var iron_label        = $ScreenStats/IronLabel
@onready var nickel_label      = $ScreenStats/NickelLabel
@onready var silicon_label     = $ScreenStats/SiliconLabel
@onready var aluminum_label    = $ScreenStats/AluminumLabel
@onready var hydrogen_label    = $ScreenStats/HydrogenLabel
@onready var sodium_label      = $ScreenStats/SodiumLabel
@onready var palladium_label   = $ScreenStats/PalladiumLabel
@onready var dark_matter_label = $ScreenStats/DarkMatterLabel

# Nodos nuevos (crea estos dos Label bajo ScreenStats)
@onready var life_label        = $ScreenStats/LifeLabel
@onready var defense_label     = $ScreenStats/DefenseLabel

# Referencia a la nave para leer health/defense
@onready var player            = get_node("/root/Main/PlayerShip")  

func _process(_delta: float) -> void:
	# Fuel y loot
	fuel_label.text = "🔋 %.1f" % GameStats.fuel
	_update_loot_labels()

	# Vida y defensa
	if player:
		life_label.text    = "❤️ %d/%d"  % [player.health, player.max_health]
		defense_label.text = "🛡 %.1fx"  % player.defense_factor

func _update_loot_labels() -> void:
	var inv = GameState.inventory
	iron_label.text        = "Fe: %d"  % inv.get("iron", 0)
	nickel_label.text      = "Ni: %d"  % inv.get("nickel", 0)
	silicon_label.text     = "Si: %d"  % inv.get("silicon", 0)
	aluminum_label.text    = "Al: %d"  % inv.get("aluminum", 0)
	hydrogen_label.text    = "H: %d"   % inv.get("hydrogen", 0)
	sodium_label.text      = "Na: %d"  % inv.get("sodium", 0)
	palladium_label.text   = "Pd: %d"  % inv.get("palladium", 0)
	dark_matter_label.text = "🟪: %d" % inv.get("dark_matter", 0)
