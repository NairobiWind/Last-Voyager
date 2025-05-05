extends Node

# Inventario de recursos por tipo
var inventory := {
	"iron": 0,
	"nickel": 0,
	"silicon": 0,
	"aluminum": 0,
	"hydrogen": 0,
	"sodium": 0,
	"palladium": 0,
	"dark_matter": 0,
}

# Estado persistente del jugador
var last_position: Vector2 = Vector2.ZERO
var last_fuel: float = 100.0

# Control de regeneración de asteroides
var active_asteroids := 0
var regeneration_threshold := 100

# Añadir loot al inventario
func add_loot(resource_name: String, amount: int = 1):
	if inventory.has(resource_name):
		inventory[resource_name] += amount
	else:
		inventory[resource_name] = amount
	print("📦 Recolectado:", resource_name, "| Total:", inventory[resource_name])

# Guardar el estado al cerrar la aplicación
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_state()


# Guardar el estado del juego
func save_state():
	var save_data := {
		"inventory": inventory,
		"last_position": last_position,
		"last_fuel": last_fuel
	}
	var file := FileAccess.open("user://savegame.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		print("💾 Estado guardado")


# Cargar el estado al iniciar
func load_state():
	if not FileAccess.file_exists("user://savegame.json"):
		print("📁 No se encontró archivo de guardado")
		return

	var file := FileAccess.open("user://savegame.json", FileAccess.READ)
	if not file:
		print("⚠️ No se pudo abrir el archivo de guardado")
		return

	var content := file.get_as_text()
	file.close()

	var save_data: Dictionary = JSON.parse_string(content)
	if typeof(save_data) == TYPE_DICTIONARY:
		inventory = save_data.get("inventory", inventory)

		# Recuperar y convertir last_position
		var pos = save_data.get("last_position", Vector2.ZERO)
		if typeof(pos) == TYPE_DICTIONARY:
			last_position = Vector2(pos.get("x", 0.0), pos.get("y", 0.0))
		elif typeof(pos) == TYPE_STRING:
			var parts = pos.strip_edges().replace("(", "").replace(")", "").split(",")
			if parts.size() == 2:
				last_position = Vector2(parts[0].to_float(), parts[1].to_float())
			else:
				last_position = Vector2.ZERO
		elif typeof(pos) == TYPE_VECTOR2:
			last_position = pos
		else:
			last_position = Vector2.ZERO

		last_fuel = save_data.get("last_fuel", 100.0)
		print("✅ Estado cargado")
	else:
		print("⚠️ Error al leer el archivo de guardado")
