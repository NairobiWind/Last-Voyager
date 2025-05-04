extends CanvasLayer

@onready var fuel_label = $ScreenStats/FuelLabel

func _process(_delta):
	fuel_label.text = "⛽ %.1f" % GameStats.fuel
