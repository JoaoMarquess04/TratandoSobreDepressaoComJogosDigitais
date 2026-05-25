extends MarginContainer

signal dialog_finished()

var texts_to_display: Array[String] = []
var current_index := 0
var typing_speed := 0.03
var is_typing := false
var waiting_input := false

@onready var text_label = $NinePatchRect/Text_Label
@onready var indicator = $Indicator

var tween: Tween


func _ready():
	pivot_offset = size / 2
	scale = Vector2.ZERO

	indicator.visible = false

	tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.25)\
		.set_trans(Tween.TRANS_BACK)


func start_dialog(texts: Array[String]):

	texts_to_display = texts
	current_index = 0

	show_text()


# MOSTRA TEXTO
func show_text():

	if current_index >= texts_to_display.size():
		close_dialog()
		return

	is_typing = true
	waiting_input = false

	text_label.text = ""
	indicator.visible = false

	_type_text(texts_to_display[current_index])


# TYPING
func _type_text(text: String):

	text_label.text = ""

	for i in range(text.length()):

		text_label.text += text[i]
		await get_tree().create_timer(typing_speed).timeout

	is_typing = false
	waiting_input = true
	indicator.visible = true


# INPUT
func _unhandled_input(event):

	if !event.is_action_pressed("interagir"):
		return

	# se ainda está digitando → completa texto
	if is_typing:

		text_label.text = texts_to_display[current_index]
		is_typing = false
		waiting_input = true
		indicator.visible = true
		return

	#  só avança se terminou de escrever
	if waiting_input:

		waiting_input = false
		current_index += 1

		show_text()


# FECHAR
func close_dialog():

	var tween = get_tree().create_tween()

	tween.tween_property(self, "scale", Vector2.ZERO, 0.25)\
		.set_trans(Tween.TRANS_BACK)

	await tween.finished

	dialog_finished.emit()
	queue_free()
