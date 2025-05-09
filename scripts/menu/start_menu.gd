# StartMenu.gd
extends Node

# Referencia al popup de “About”
@onready var about_popup := $AboutPopup

func _on_new_game_pressed() -> void:
	# 1) Reiniciamos el estado
	GameState.reset_state()
	# 2) Guardamos inmediatamente (opcional)
	GameState.save_state()
	# 3) Cambiamos a la escena de juego
	get_tree().change_scene_to_file("res://scenes/core/main.tscn")


func _on_continue_pressed() -> void:
	# Intentamos cargar la partida; si hay éxito, entramos al juego
	if GameState.load_state():
		get_tree().change_scene_to_file("res://scenes/core/main.tscn")
	else:
		# Aquí podrías mostrar un mensaje tipo “No hay partida guardada”
		print("⚠️ No se encontró partida previa para continuar.")


func _on_about_pressed() -> void:
	# Abre el popup centrado
	about_popup.popup_centered()


func _on_exit_pressed() -> void:
	# Guardamos antes de salir
	GameState.save_state()
	# Cerramos la aplicación
	get_tree().quit()


func _on_close_button_pressed() -> void:
	about_popup.hide()
