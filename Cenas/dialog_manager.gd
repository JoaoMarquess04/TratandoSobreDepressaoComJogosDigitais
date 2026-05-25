extends Node

@export var dialog_scene: PackedScene

var dialog_box = null
var is_showing_dialog := false


func start_dialog(texts: Array[String], dialog_position: Vector2):

	if is_showing_dialog:
		return

	if dialog_scene == null:
		return

	# Instancia o dialogo
	dialog_box = dialog_scene.instantiate()


	print(dialog_box)
	print(dialog_box.get_class())
	print(dialog_box.get_script())




	# Configura ANTES de adicionar na cena
	dialog_box.texts_to_display = texts
	dialog_box.global_position = dialog_position

	# Adiciona na árvore
	get_tree().current_scene.add_child(dialog_box)

	is_showing_dialog = true

	# Conecta sinal
	dialog_box.dialog_finished.connect(_on_dialog_finished)


func _on_dialog_finished():

	is_showing_dialog = false

	if dialog_box:

		dialog_box.queue_free()
		dialog_box = null
